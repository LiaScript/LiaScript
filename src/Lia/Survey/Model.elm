module Lia.Survey.Model
    exposing
        ( Model
        , get_matrix_state
        , get_submission_state
        , get_text_state
        , get_vector_state
        )

import Array
import Dict
import Lia.Survey.Types exposing (..)


type alias Model =
    SurveyVector


get_submission_state : Model -> Int -> Bool
get_submission_state model idx =
    case Array.get idx model of
        Just ( True, _ ) ->
            True

        _ ->
            False


get_text_state : Model -> Int -> String
get_text_state model idx =
    case Array.get idx model of
        Just ( _, TextState str ) ->
            str

        _ ->
            ""


get_vector_state : Model -> Int -> String -> Bool
get_vector_state model idx var =
    let
        bool s =
            s
                |> Dict.get var
                |> Maybe.withDefault False
    in
    case Array.get idx model of
        Just ( _, SingleChoiceState s ) ->
            bool s

        Just ( _, MultiChoiceState s ) ->
            bool s

        _ ->
            False


get_matrix_state : Model -> Int -> Int -> String -> Bool
get_matrix_state model idx row var =
    let
        bool s =
            s
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False
    in
    case Array.get idx model of
        Just ( _, SingleChoiceBlockState matrix ) ->
            bool matrix

        Just ( _, MultiChoiceBlockState matrix ) ->
            bool matrix

        _ ->
            False
