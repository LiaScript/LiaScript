module Lia.Update exposing (Msg(..), update)

import Lia.Effect.Model as Effect
import Lia.Helper exposing (get_slide)
import Lia.Index
import Lia.Model exposing (..)
import Lia.Quiz.Update
import Tts.Tts exposing (speak)


type Msg
    = Load Int
    | PrevSlide
    | NextSlide
    | ScanIndex String
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
            if model.effects.visible == 0 then
                update (Load (model.current_slide - 1)) model
            else
                let
                    effects =
                        model.effects
                in
                ( { model | effects = { effects | visible = effects.visible - 1 } }, Cmd.none )

        NextSlide ->
            if model.effects.visible == model.effects.effects then
                update (Load (model.current_slide + 1)) model
            else
                let
                    effects =
                        model.effects
                in
                ( { model | effects = { effects | visible = effects.visible + 1 } }, Cmd.none )

        ScanIndex pattern ->
            let
                results =
                    if pattern == "" then
                        Nothing
                    else
                        Just (Lia.Index.scan model.index pattern)
            in
            ( { model | search = pattern, search_results = results }, Cmd.none )

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
