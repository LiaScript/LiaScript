port module Lia.Markdown.Update exposing
    ( Msg(..)
    , handle
    , initEffect
    , nextEffect
    , previousEffect
    , subscriptions
    , update
    , updateScript
    )

import Json.Encode as JE
import Lia.Markdown.Code.Update as Code
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Quiz.Update as Quiz
import Lia.Markdown.Survey.Update as Survey
import Lia.Markdown.Table.Update as Table
import Lia.Section exposing (Section)
import Port.Event as Event exposing (Event)


port footnote : (String -> msg) -> Sub msg


type Msg
    = UpdateEffect Bool (Effect.Msg Msg)
    | UpdateCode Code.Msg
    | UpdateQuiz (Quiz.Msg Msg)
    | UpdateSurvey (Survey.Msg Msg)
    | UpdateTable (Table.Msg Msg)
    | FootnoteHide
    | FootnoteShow String
    | Script (Script.Msg Msg)



--  | Speak String String


subscriptions : Section -> Sub Msg
subscriptions _ =
    footnote FootnoteShow


send : String -> List JE.Value -> List ( String, JE.Value )
send name =
    List.map (Tuple.pair name)


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
                |> List.map Event.encode
                |> send "effect"
            )

        UpdateCode childMsg ->
            case Code.update section.effect_model.javascript childMsg section.code_vector of
                ( vector, [] ) ->
                    ( { section | code_vector = vector }, Cmd.none, [] )

                ( vector, events ) ->
                    ( { section | code_vector = vector }
                    , Cmd.none
                    , events
                        |> List.map Event.encode
                        |> send "code"
                    )

        UpdateQuiz childMsg ->
            let
                ( vector, event, sub ) =
                    Quiz.update section.effect_model.javascript childMsg section.quiz_vector
            in
            ( { section | quiz_vector = vector }
            , Cmd.none
            , event
                |> List.map Event.encode
                |> send "quiz"
            )
                |> updateScript sub

        UpdateSurvey childMsg ->
            let
                ( vector, event, sub ) =
                    Survey.update section.effect_model.javascript childMsg section.survey_vector
            in
            ( { section | survey_vector = vector }
            , Cmd.none
            , event
                |> List.map Event.encode
                |> send "survey"
            )
                |> updateScript sub

        UpdateTable childMsg ->
            let
                ( vector, sub ) =
                    Table.update childMsg section.table_vector
            in
            ( { section | table_vector = vector }
            , Cmd.none
            , []
            )
                |> updateScript sub

        FootnoteShow key ->
            ( { section | footnote2show = Just key }, Cmd.none, [] )

        FootnoteHide ->
            ( { section | footnote2show = Nothing }, Cmd.none, [] )

        Script childMsg ->
            updateScript (Just childMsg) ( section, Cmd.none, [] )


updateScript : Maybe (Script.Msg Msg) -> ( Section, Cmd Msg, List ( String, JE.Value ) ) -> ( Section, Cmd Msg, List ( String, JE.Value ) )
updateScript msg ( section, cmd, events ) =
    case msg of
        Nothing ->
            ( section, cmd, events )

        Just sub ->
            let
                ( effect_model, cmd2, event ) =
                    Effect.updateSub sub section.effect_model
            in
            ( { section | effect_model = effect_model }
            , Cmd.batch [ cmd, Cmd.map (UpdateEffect True) cmd2 ]
            , event
                |> List.map Event.encode
                |> send "effect"
            )


nextEffect : Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
nextEffect sound =
    update (UpdateEffect sound Effect.next)


previousEffect : Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
previousEffect sound =
    update (UpdateEffect sound Effect.previous)


initEffect : Bool -> Bool -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
initEffect run_all_javascript sound =
    update (UpdateEffect sound (Effect.init run_all_javascript))


handle : String -> Event -> Section -> ( Section, Cmd Msg, List ( String, JE.Value ) )
handle topic event section =
    case topic of
        "code" ->
            update (UpdateCode (Code.handle event)) section

        "quiz" ->
            update (UpdateQuiz (Quiz.handle event)) section

        "survey" ->
            update (UpdateSurvey (Survey.handle event)) section

        "effect" ->
            update (UpdateEffect True (Effect.handle event)) section

        _ ->
            ( section, Cmd.none, [] )
