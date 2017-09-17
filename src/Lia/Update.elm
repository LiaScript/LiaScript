module Lia.Update exposing (Msg(..), update)

import Json.Encode as JE
import Lia.Code.Update as Code
import Lia.Effect.Model as EffectModel
import Lia.Effect.Update as Effect
import Lia.Helper exposing (get_slide)
import Lia.Index.Update as Index
import Lia.Model exposing (..)
import Lia.Quiz.Update as Quiz
import Lia.Survey.Update as Survey


type Msg
    = Load Int
    | PrevSlide
    | NextSlide
    | ToggleContentsTable
    | UpdateIndex Index.Msg
    | UpdateQuiz Quiz.Msg
    | UpdateCode Code.Msg
    | UpdateSurvey Survey.Msg
    | UpdateEffect Effect.Msg


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
update msg model =
    case msg of
        Load int ->
            let
                ( effect_model, cmd, _ ) =
                    get_slide int model.slides
                        |> EffectModel.init model.narator
                        |> Effect.init
            in
            ( { model
                | current_slide = int
                , effect_model = effect_model
              }
            , Cmd.map UpdateEffect cmd
            , Nothing
            )

        PrevSlide ->
            case Effect.previous model.effect_model of
                ( effect_model, cmd, False ) ->
                    ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )

                _ ->
                    update (Load (model.current_slide - 1)) model

        NextSlide ->
            case Effect.next model.effect_model of
                ( effect_model, cmd, False ) ->
                    ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )

                _ ->
                    update (Load (model.current_slide + 1)) model

        UpdateIndex childMsg ->
            let
                index_model =
                    Index.update childMsg model.index_model
            in
            ( { model | index_model = index_model }, Cmd.none, Nothing )

        UpdateSurvey childMsg ->
            let
                ( model_, info ) =
                    Survey.update childMsg model.survey_model
            in
            ( { model | survey_model = model_ }, Cmd.none, log "survey" info )

        UpdateCode childMsg ->
            let
                code_model =
                    Code.update childMsg model.code_model
            in
            ( { model | code_model = code_model }, Cmd.none, Nothing )

        UpdateEffect childMsg ->
            let
                ( effect_model, cmd, h ) =
                    Effect.update childMsg model.effect_model
            in
            ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd, Nothing )

        ToggleContentsTable ->
            ( { model | show_contents = not model.show_contents }, Cmd.none, Nothing )

        UpdateQuiz quiz_msg ->
            let
                ( quiz_model, info ) =
                    Quiz.update quiz_msg model.quiz_model
            in
            ( { model | quiz_model = quiz_model }, Cmd.none, log "quiz" info )


log : String -> Maybe JE.Value -> Maybe ( String, JE.Value )
log topic msg =
    case msg of
        Just m ->
            Just ( topic, m )

        _ ->
            Nothing
