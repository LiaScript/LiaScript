module Lia.Update exposing (Msg(..), update)

import Lia.Effect.Model as EffectModel
import Lia.Effect.Update as Effect
import Lia.Helper exposing (get_slide)
import Lia.Index.Update as Index
import Lia.Model exposing (..)
import Lia.Quiz.Update as Quiz


type Msg
    = Load Int
    | PrevSlide
    | NextSlide
    | ToggleContentsTable
    | UpdateIndex Index.Msg
    | UpdateQuiz Quiz.Msg
    | UpdateEffect Effect.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load int ->
            --( { model | slide = int }, Cmd.none )
            ( { model
                | current_slide = int
                , effects = EffectModel.init <| get_slide int model.slides
              }
            , Cmd.none
            )

        PrevSlide ->
            case Effect.previous model.effects of
                ( effects, cmd, False ) ->
                    ( { model | effects = effects, error = toString cmd }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide - 1)) model

        NextSlide ->
            case Effect.next model.effects of
                ( effects, cmd, False ) ->
                    ( { model | effects = effects, error = toString cmd }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide + 1)) model

        UpdateIndex childMsg ->
            let
                ( index, _ ) =
                    Index.update childMsg model.index
            in
            ( { model | index = index }, Cmd.none )

        UpdateEffect childMsg ->
            let
                ( effects, cmd, h ) =
                    Effect.update childMsg model.effects
            in
            ( { model | effects = effects, error = toString cmd }, Cmd.map UpdateEffect cmd )

        ToggleContentsTable ->
            ( { model | contents = not model.contents }, Cmd.none )

        UpdateQuiz quiz_msg ->
            let
                ( quiz, cmd ) =
                    Quiz.update quiz_msg model.quiz
            in
            ( { model | quiz = quiz }, Cmd.none )
