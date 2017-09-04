module Lia.Quiz.Model
    exposing
        ( Model
        , get_hint_counter
        , question_state
        , question_state_text
        , quiz_state
        )

import Array
import Lia.Quiz.Types exposing (..)


type alias Model =
    QuizVector


get_hint_counter : Int -> QuizVector -> Int
get_hint_counter idx vector =
    case Array.get idx vector of
        Just e ->
            e.hint

        Nothing ->
            0


question_state_text : Int -> QuizVector -> String
question_state_text quiz_id vector =
    case get_state quiz_id vector of
        Just (Text input answer) ->
            input

        _ ->
            ""


quiz_state : Int -> QuizVector -> ( Maybe Bool, Int )
quiz_state quiz_id vector =
    vector
        |> Array.get quiz_id
        |> Maybe.andThen (\q -> Just ( q.solved, q.trial ))
        |> Maybe.withDefault ( Nothing, 0 )


question_state : Int -> Int -> QuizVector -> Bool
question_state quiz_id question_id vector =
    case get_state quiz_id vector of
        Just (Single input answer) ->
            question_id == input

        Just (Multi questions) ->
            case Array.get question_id questions of
                Just ( c, _ ) ->
                    c

                Nothing ->
                    False

        _ ->
            False


get_state : Int -> QuizVector -> Maybe QuizState
get_state idx vector =
    vector
        |> Array.get idx
        |> Maybe.map .state
