module Lia.Update exposing (update)

import Array
import Lia.Helper exposing (get_slide_effects)
import Lia.Index
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

        ShowHint quiz_id ->
            ( { model | quiz = update_hint quiz_id model.quiz }, Cmd.none )

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


update_input : Int -> String -> QuizVector -> QuizVector
update_input idx text vector =
    case Array.get idx vector of
        Just elem ->
            if elem.solved == Just True then
                vector
            else
                case elem.state of
                    Text input answer ->
                        Array.set idx { elem | state = Text text answer } vector

                    _ ->
                        vector

        _ ->
            vector


update_hint : Int -> QuizVector -> QuizVector
update_hint idx vector =
    case Array.get idx vector of
        Just elem ->
            if elem.solved == Just True then
                vector
            else
                Array.set idx { elem | hint = elem.hint + 1 } vector

        _ ->
            vector


flip_checkbox : Int -> Int -> QuizVector -> QuizVector
flip_checkbox idx question_id vector =
    case Array.get idx vector of
        Just elem ->
            if elem.solved == Just True then
                vector
            else
                case elem.state of
                    Single c answer ->
                        Array.set idx { elem | state = Single question_id answer } vector

                    Multi quiz ->
                        case Array.get question_id quiz of
                            Just question ->
                                question
                                    |> (\( c, a ) -> ( not c, a ))
                                    |> (\q -> Array.set question_id q quiz)
                                    |> (\q -> Array.set idx { elem | state = Multi q } vector)

                            Nothing ->
                                vector

                    _ ->
                        vector

        _ ->
            vector


check_answer : Int -> QuizVector -> QuizVector
check_answer idx vector =
    let
        ccheck state =
            case state of
                Multi quiz ->
                    let
                        f ( input, answer ) result =
                            result && (input == answer)
                    in
                    Just (Array.foldr f True quiz)

                Single input answer ->
                    Just (input == answer)

                Text input answer ->
                    Just (input == answer)
    in
    case Array.get idx vector of
        Just elem ->
            if elem.solved == Just True then
                vector
            else
                Array.set idx { elem | solved = ccheck elem.state, trial = elem.trial + 1 } vector

        Nothing ->
            vector
