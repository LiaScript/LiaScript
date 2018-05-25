port module Lia.Markdown.Update
    exposing
        ( Msg(..)
        , initEffect
        , nextEffect
        , previousEffect
        , subscriptions
        , update
        )

import Json.Encode as JE
import Lia.Code.Update as Code
import Lia.Effect.Update as Effect
import Lia.Quiz.Update as Quiz
import Lia.Survey.Update as Survey
import Lia.Types exposing (Section)


port footnote : (String -> msg) -> Sub msg


type Msg
    = UpdateEffect Bool Effect.Msg
    | UpdateCode Code.Msg
    | UpdateQuiz Quiz.Msg
    | UpdateSurvey Survey.Msg
    | ShowFootnote String


subscriptions : Section -> Sub Msg
subscriptions section =
    Sub.batch
        [ Sub.map (UpdateEffect False) (Effect.subscriptions section.effect_model)
        , Sub.map UpdateCode (Code.subscriptions section.code_vector)
        , footnote ShowFootnote
        ]


update : Msg -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
update msg section =
    case msg of
        UpdateEffect sound childMsg ->
            let
                ( effect_model, cmd ) =
                    Effect.update childMsg sound section.effect_model
            in
            ( { section | effect_model = effect_model }, Cmd.map (UpdateEffect sound) cmd, Nothing )

        UpdateCode childMsg ->
            let
                ( code_vector, cmd ) =
                    Code.update childMsg section.code_vector
            in
            ( { section | code_vector = code_vector }, Cmd.map UpdateCode cmd, Nothing )

        UpdateQuiz childMsg ->
            let
                ( quiz_vector, log ) =
                    Quiz.update childMsg section.quiz_vector
            in
            ( { section | quiz_vector = quiz_vector }, Cmd.none, Nothing )

        UpdateSurvey childMsg ->
            let
                ( survey_vector, log ) =
                    Survey.update childMsg section.survey_vector
            in
            ( { section | survey_vector = survey_vector }, Cmd.none, Nothing )

        ShowFootnote key ->
            let
                x =
                    Debug.log "FFFFFFFFFFFFF" key
            in
            ( section, Cmd.none, Nothing )


nextEffect : Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
nextEffect sound =
    update (UpdateEffect sound Effect.next)


previousEffect : Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
previousEffect sound =
    update (UpdateEffect sound Effect.previous)


initEffect : Bool -> Bool -> Section -> ( Section, Cmd Msg, Maybe ( String, JE.Value ) )
initEffect run_all_javascript sound =
    update (UpdateEffect sound (Effect.init run_all_javascript))


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
