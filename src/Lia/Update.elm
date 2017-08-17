module Lia.Update exposing (update)

import Array
import Lia.Helper exposing (get_slide_effects)
import Lia.Model exposing (..)
import Lia.Type exposing (..)
import Tts.Tts exposing (speak)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load int ->
            --( { model | slide = int }, Cmd.none )
            update (Speak "Starting to load next slide")
                { model
                    | current_slide = int
                    , visible = 0
                    , effects = get_slide_effects int model.slides
                }

        PrevSlide ->
            if model.visible == 0 then
                update (Load (model.current_slide - 1)) model
            else
                ( { model | visible = model.visible - 1 }, Cmd.none )

        NextSlide ->
            if model.visible == model.effects then
                update (Load (model.current_slide + 1)) model
            else
                ( { model | visible = model.visible + 1 }, Cmd.none )

        CheckBox quiz_id question_id ->
            ( { model | quiz = flip_checkbox quiz_id question_id model.quiz }, Cmd.none )

        RadioButton quiz_id answer ->
            ( { model | quiz = flip_checkbox quiz_id answer model.quiz }, Cmd.none )

        Input quiz_id string ->
            ( { model | quiz = update_input quiz_id string model.quiz }, Cmd.none )

        Check quiz_id ->
            ( { model | quiz = check_answer quiz_id model.quiz }, Cmd.none )

        Search string ->
            ( model, Cmd.none )

        ContentsTable ->
            ( { model | contents = not model.contents }, Cmd.none )

        Speak text ->
            ( { model | error = "Speaking" }, speak TTS Nothing "en_US" text )

        TTS (Result.Ok _) ->
            ( { model | error = "" }, Cmd.none )

        TTS (Result.Err m) ->
            ( { model | error = m }, Cmd.none )


update_input : Int -> String -> QuizVector -> QuizVector
update_input quiz_id text vector =
    case Array.get quiz_id vector of
        Just ( Just True, _, _ ) ->
            vector

        Just ( state, Text input answer, trial_count ) ->
            Array.set quiz_id ( state, Text text answer, trial_count ) vector

        _ ->
            vector


flip_checkbox : Int -> Int -> QuizVector -> QuizVector
flip_checkbox quiz_id question_id vector =
    case Array.get quiz_id vector of
        Just ( Just True, _, _ ) ->
            vector

        Just ( state, Single c answer, trial_count ) ->
            Array.set quiz_id ( state, Single question_id answer, trial_count ) vector

        Just ( state, Multi quiz, trial_count ) ->
            case Array.get question_id quiz of
                Just question ->
                    question
                        |> (\( c, a ) -> ( not c, a ))
                        |> (\q -> Array.set question_id q quiz)
                        |> (\q -> Array.set quiz_id ( state, Multi q, trial_count ) vector)

                Nothing ->
                    vector

        _ ->
            vector


check_answer : Int -> QuizVector -> QuizVector
check_answer quiz_id vector =
    case Array.get quiz_id vector of
        Just ( Just True, _, _ ) ->
            vector

        Just ( state, Text input answer, trial_count ) ->
            Array.set quiz_id
                ( Just (input == answer)
                , Text input answer
                , trial_count + 1
                )
                vector

        Just ( state, Single input answer, trial_count ) ->
            Array.set quiz_id
                ( Just (input == answer)
                , Single input answer
                , trial_count + 1
                )
                vector

        Just ( state, Multi quiz, trial_count ) ->
            let
                f ( input, answer ) result =
                    result && (input == answer)
            in
            Array.set quiz_id
                ( Just (Array.foldr f True quiz)
                , Multi quiz
                , trial_count + 1
                )
                vector

        Nothing ->
            vector
