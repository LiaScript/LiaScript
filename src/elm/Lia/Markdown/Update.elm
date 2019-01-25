port module Lia.Markdown.Update exposing
    ( Msg(..)
    , handle
    , initEffect
    , nextEffect
    , previousEffect
    , subscriptions
    , update
    )

import Json.Encode as JE
import Lia.Code.Update as Code
import Lia.Event exposing (Event, eventToJson)
import Lia.Markdown.Effect.Update as Effect
import Lia.Quiz.Update as Quiz
import Lia.Survey.Update as Survey
import Lia.Types exposing (Section)


port footnote : (String -> msg) -> Sub msg


type Msg
    = UpdateEffect Bool Effect.Msg
    | UpdateCode Code.Msg
    | UpdateQuiz Quiz.Msg
    | UpdateSurvey Survey.Msg
    | FootnoteHide
    | FootnoteShow String


subscriptions : Section -> Sub Msg
subscriptions section =
    footnote FootnoteShow


send : String -> List JE.Value -> List ( String, JE.Value )
send name values =
    List.map (Tuple.pair name) values


update : Msg -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
update msg section =
    case msg of
        UpdateEffect sound childMsg ->
            let
                ( effect_model, cmd, event ) =
                    Effect.update sound childMsg section.effect_model
            in
            ( { section | effect_model = effect_model }
            , Cmd.map (UpdateEffect sound) cmd
            , event
                |> List.map eventToJson
                |> send "effect"
            )

        UpdateCode childMsg ->
            case Code.update childMsg section.code_vector of
                ( vector, [] ) ->
                    ( { section | code_vector = vector }, Cmd.none, [] )

                ( vector, events ) ->
                    ( { section | code_vector = vector }
                    , Cmd.none
                    , events
                        |> List.map eventToJson
                        |> send "code"
                    )

        UpdateQuiz childMsg ->
            let
                ( vector, event ) =
                    Quiz.update childMsg section.quiz_vector
            in
            ( { section | quiz_vector = vector }
            , Cmd.none
            , event
                |> List.map eventToJson
                |> send "quiz"
            )

        UpdateSurvey childMsg ->
            let
                ( vector, event ) =
                    Survey.update childMsg section.survey_vector
            in
            ( { section | survey_vector = vector }
            , Cmd.none
            , event
                |> List.map eventToJson
                |> send "survey"
            )

        FootnoteShow key ->
            ( { section | footnote2show = Just key }, Cmd.none, [] )

        FootnoteHide ->
            ( { section | footnote2show = Nothing }, Cmd.none, [] )


nextEffect : Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
nextEffect sound =
    update (UpdateEffect sound Effect.next)


previousEffect : Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
previousEffect sound =
    update (UpdateEffect sound Effect.previous)


initEffect : Bool -> Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
initEffect run_all_javascript sound =
    update (UpdateEffect sound (Effect.init run_all_javascript))


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing


handle : String -> Event -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
handle topic event section =
    case topic of
        "code" ->
            update (UpdateCode (Code.handle event)) section

        "effect" ->
            update (UpdateEffect False (Effect.handle event)) section

        "quiz" ->
            update (UpdateQuiz (Quiz.handle event)) section

        "survey" ->
            update (UpdateSurvey (Survey.handle event)) section

        _ ->
            ( section, Cmd.none, [] )


restore : Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
restore section =
    ( section, Cmd.none, Nothing )
