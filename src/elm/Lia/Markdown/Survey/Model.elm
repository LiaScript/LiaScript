module Lia.Markdown.Survey.Model exposing
    ( getErrorMessage
    , get_matrix_state
    , get_select_state
    , get_submission_state
    , get_text_state
    , get_vector_state
    )

import Array
import Dict
import Lia.Markdown.Survey.Types exposing (State(..), Vector)


getErrorMessage : Int -> Vector -> Maybe String
getErrorMessage id =
    Array.get id >> Maybe.andThen (Tuple.first >> (\( _, _, message ) -> message))


get_submission_state : Vector -> Int -> Bool
get_submission_state vector idx =
    case Array.get idx vector |> Maybe.map Tuple.first of
        Just ( True, _, _ ) ->
            True

        _ ->
            False


get_text_state : Vector -> Int -> String
get_text_state vector idx =
    case Array.get idx vector |> Maybe.map Tuple.first of
        Just ( _, Text_State str, _ ) ->
            str

        _ ->
            ""


get_vector_state : Vector -> Int -> String -> Bool
get_vector_state vector idx var =
    case Array.get idx vector |> Maybe.map Tuple.first of
        Just ( _, Vector_State _ state, _ ) ->
            state
                |> Dict.get var
                |> Maybe.withDefault False

        _ ->
            False


get_select_state : Vector -> Int -> ( Bool, Int )
get_select_state vector id =
    case Array.get id vector |> Maybe.map Tuple.first of
        Just ( _, Select_State open value, _ ) ->
            ( open, value )

        _ ->
            ( False, -1 )


get_matrix_state : Vector -> Int -> Int -> String -> Bool
get_matrix_state vector idx row var =
    case Array.get idx vector |> Maybe.map Tuple.first of
        Just ( _, Matrix_State _ matrix, _ ) ->
            matrix
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False

        _ ->
            False
