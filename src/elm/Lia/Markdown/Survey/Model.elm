module Lia.Markdown.Survey.Model exposing
    ( getErrorMessage
    , get_drop_state
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
    Array.get id >> Maybe.andThen .errorMsg


get_submission_state : Vector -> Int -> Bool
get_submission_state vector idx =
    vector
        |> Array.get idx
        |> Maybe.map .submitted
        |> Maybe.withDefault False


get_text_state : Vector -> Int -> String
get_text_state vector idx =
    case Array.get idx vector |> Maybe.map .state of
        Just (Text_State str) ->
            str

        _ ->
            ""


get_vector_state : Vector -> Int -> String -> Bool
get_vector_state vector idx var =
    case Array.get idx vector |> Maybe.map .state of
        Just (Vector_State _ state) ->
            state
                |> Dict.get var
                |> Maybe.withDefault False

        _ ->
            False


get_select_state : Vector -> Int -> ( Bool, Int )
get_select_state vector id =
    case Array.get id vector |> Maybe.map .state of
        Just (Select_State open value) ->
            ( open, value )

        _ ->
            ( False, -1 )


get_drop_state : Vector -> Int -> ( Bool, Bool, Int )
get_drop_state vector id =
    case Array.get id vector |> Maybe.map .state of
        Just (DragAndDrop_State highlight active value) ->
            ( highlight, active, value )

        _ ->
            ( False, False, -1 )


get_matrix_state : Vector -> Int -> Int -> String -> Bool
get_matrix_state vector idx row var =
    case Array.get idx vector |> Maybe.map .state of
        Just (Matrix_State _ matrix) ->
            matrix
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False

        _ ->
            False
