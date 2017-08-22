module Lia.Update exposing (Msg(..), update)

import Lia.Effect.Model as Effect
import Lia.Effect.Update
import Lia.Helper exposing (get_slide)
import Lia.Index.Update
import Lia.Model exposing (..)
import Lia.Quiz.Update
import Tts.Tts exposing (speak)


type Msg
    = Load Int
    | PrevSlide
    | NextSlide
      --| UpdateEffect Lia.Effect.Update.Msg
    | UpdateIndex Lia.Index.Update.Msg
    | UpdateQuiz Lia.Quiz.Update.Msg
    | ContentsTable
    | Speak String
    | TTS (Result String Never)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load int ->
            --( { model | slide = int }, Cmd.none )
            update (Speak "Starting to load next slide")
                { model
                    | current_slide = int
                    , effects = Effect.init <| get_slide int model.slides
                }

        PrevSlide ->
            case Lia.Effect.Update.previous model.effects of
                ( effects, False ) ->
                    ( { model | effects = effects }, Cmd.none )

                _ ->
                    update (Load (model.current_slide - 1)) model

        NextSlide ->
            case Lia.Effect.Update.next model.effects of
                ( effects, False ) ->
                    ( { model | effects = effects }, Cmd.none )

                _ ->
                    update (Load (model.current_slide + 1)) model

        UpdateIndex childMsg ->
            let
                ( index, _ ) =
                    Lia.Index.Update.update childMsg model.index
            in
            ( { model | index = index }, Cmd.none )

        ContentsTable ->
            ( { model | contents = not model.contents }, Cmd.none )

        Speak text ->
            ( { model | error = "Speaking" }, speak TTS Nothing "en_US" text )

        TTS (Result.Ok _) ->
            ( { model | error = "" }, Cmd.none )

        TTS (Result.Err m) ->
            ( { model | error = m }, Cmd.none )

        UpdateQuiz quiz_msg ->
            let
                ( quiz, cmd ) =
                    Lia.Quiz.Update.update quiz_msg model.quiz
            in
            ( { model | quiz = quiz }, Cmd.none )
