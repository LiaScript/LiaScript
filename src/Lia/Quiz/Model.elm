module Lia.Quiz.Model
    exposing
        ( Model
        , get_hint_counter
        , init
        , question_state
        , question_state_text
        , quiz_state
        )

import Array
import Lia.Quiz.Type exposing (..)
import Lia.Type exposing (Block(..), Slide)


type alias Model =
    QuizVector


init : List Slide -> Model
init slides =
    slides
        |> List.map .body
        |> List.concat
        |> List.filterMap filter
        |> List.map element
        |> Array.fromList


filter : Block -> Maybe QuizBlock
filter block =
    case block of
        Quiz quiz ->
            Just quiz

        _ ->
            Nothing


element : QuizBlock -> QuizElement
element quiz =
    let
        m =
            case quiz.quiz of
                TextInput str ->
                    Text "" str

                SingleChoice a _ ->
                    Single -1 a

                MultipleChoice q ->
                    q
                        |> List.map (\( b, _ ) -> ( False, b ))
                        |> Array.fromList
                        |> Multi
    in
    { solved = Nothing, state = m, trial = 0, hint = 0 }


get_hint_counter : Int -> QuizVector -> Int
get_hint_counter idx vector =
    case Array.get idx vector of
        Just e ->
            e.hint

        Nothing ->
            0


question_state_text : Int -> QuizVector -> String
question_state_text quiz_id vector =
    case
        Array.get quiz_id vector
            |> Maybe.map .state
    of
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
    case
        Array.get quiz_id vector
            |> Maybe.map .state
    of
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
