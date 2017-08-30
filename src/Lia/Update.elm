module Lia.Update exposing (Msg(..), update)

import Lia.Code.Update as Code
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
    | UpdateCode Code.Msg
    | UpdateEffect Effect.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load int ->
            let
                ( effects, cmd, _ ) =
                    get_slide int model.slides
                        |> EffectModel.init
                        |> Effect.init
            in
            ( { model
                | current_slide = int
                , effects = effects
              }
            , Cmd.map UpdateEffect cmd
            )

        PrevSlide ->
            case Effect.previous model.effects of
                ( effects, cmd, False ) ->
                    ( { model | effects = effects }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide - 1)) model

        NextSlide ->
            case Effect.next model.effects of
                ( effects, cmd, False ) ->
                    ( { model | effects = effects }, Cmd.map UpdateEffect cmd )

                _ ->
                    update (Load (model.current_slide + 1)) model

        UpdateIndex childMsg ->
            let
                ( index, _ ) =
                    Index.update childMsg model.index
            in
            ( { model | index = index }, Cmd.none )

        UpdateCode childMsg ->
            let
                ( code, cmd ) =
                    Code.update childMsg model.code
            in
            ( { model | code = code }, Cmd.none )

        UpdateEffect childMsg ->
            let
                ( effects, cmd, h ) =
                    Effect.update childMsg model.effects
            in
            ( { model | effects = effects }, Cmd.map UpdateEffect cmd )

        ToggleContentsTable ->
            ( { model | contents = not model.contents }, Cmd.none )

        UpdateQuiz quiz_msg ->
            let
                ( quiz, cmd ) =
                    Quiz.update quiz_msg model.quiz
            in
            ( { model | quiz = quiz }, Cmd.none )
