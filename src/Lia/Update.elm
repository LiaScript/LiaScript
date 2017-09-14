module Lia.Update exposing (Msg(..), update)

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


update : Msg -> Model -> ( Model, Cmd Msg )
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
            )

        PrevSlide ->
            case Effect.previous model.effect_model of
                ( effect_model, cmd, False ) ->
                    ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide - 1)) model

        NextSlide ->
            case Effect.next model.effect_model of
                ( effect_model, cmd, False ) ->
                    ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide + 1)) model

        UpdateIndex childMsg ->
            let
                ( index_model, _ ) =
                    Index.update childMsg model.index_model
            in
            ( { model | index_model = index_model }, Cmd.none )

        UpdateSurvey childMsg ->
            let
                ( model_, _ ) =
                    Survey.update childMsg model.survey_model
            in
            ( { model | survey_model = model_ }, Cmd.none )

        UpdateCode childMsg ->
            let
                ( code_model, cmd ) =
                    Code.update childMsg model.code_model
            in
            ( { model | code_model = code_model }, Cmd.none )

        UpdateEffect childMsg ->
            let
                ( effect_model, cmd, h ) =
                    Effect.update childMsg model.effect_model
            in
            ( { model | effect_model = effect_model }, Cmd.map UpdateEffect cmd )

        ToggleContentsTable ->
            ( { model | show_contents = not model.show_contents }, Cmd.none )

        UpdateQuiz quiz_msg ->
            let
                ( quiz_model, cmd ) =
                    Quiz.update quiz_msg model.quiz_model
            in
            ( { model | quiz_model = quiz_model }, Cmd.none )
