module Lia.Survey.Update exposing (Msg(..), update)

import Array
import Dict
import Json.Encode as JE
import Lia.Helper exposing (ID)
import Lia.Survey.Model exposing (vector2json)
import Lia.Survey.Types exposing (..)


type Msg
    = TextUpdate ID String
    | VectorUpdate ID String
    | MatrixUpdate ID ID String
    | Submit ID


update : Msg -> Vector -> ( Vector, Maybe JE.Value )
update msg vector =
    case msg of
        TextUpdate idx str ->
            ( update_text vector idx str, Nothing )

        VectorUpdate idx var ->
            ( update_vector vector idx var, Nothing )

        MatrixUpdate idx row var ->
            ( update_matrix vector idx row var, Nothing )

        Submit idx ->
            if submitable vector idx then
                let
                    new_vector =
                        submit vector idx
                in
                ( new_vector, Just <| vector2json new_vector )
            else
                ( vector, Nothing )


update_text : Vector -> ID -> String -> Vector
update_text vector idx str =
    case Array.get idx vector of
        Just ( False, TextState _ ) ->
            set_state vector idx (TextState str)

        _ ->
            vector


update_vector : Vector -> ID -> String -> Vector
update_vector vector idx var =
    case Array.get idx vector of
        Just ( False, VectorState False element ) ->
            element
                |> Dict.map (\_ _ -> False)
                |> Dict.update var (\_ -> Just True)
                |> VectorState False
                |> set_state vector idx

        Just ( False, VectorState True element ) ->
            element
                |> Dict.update var (\b -> Maybe.map not b)
                |> VectorState True
                |> set_state vector idx

        _ ->
            vector


update_matrix : Vector -> ID -> ID -> String -> Vector
update_matrix vector col_id row_id var =
    case Array.get col_id vector of
        Just ( False, MatrixState False matrix ) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.map (\_ _ -> False) d)
                |> Maybe.map (\d -> Dict.update var (\_ -> Just True) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> MatrixState False
                |> set_state vector col_id

        Just ( False, MatrixState True matrix ) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> MatrixState True
                |> set_state vector col_id

        _ ->
            vector


set_state : Vector -> ID -> State -> Vector
set_state vector idx state =
    Array.set idx ( False, state ) vector


submit : Vector -> ID -> Vector
submit vector idx =
    case Array.get idx vector of
        Just ( False, state ) ->
            Array.set idx ( True, state ) vector

        _ ->
            vector


submitable : Vector -> ID -> Bool
submitable vector idx =
    case Array.get idx vector of
        Just ( False, TextState state ) ->
            state /= ""

        Just ( False, VectorState _ state ) ->
            state
                |> Dict.values
                |> List.filter (\a -> a)
                |> List.length
                |> (\s -> s > 0)

        Just ( False, MatrixState _ state ) ->
            state
                |> Array.toList
                |> List.map Dict.values
                |> List.map (\l -> List.filter (\a -> a) l)
                |> List.all (\a -> List.length a > 0)

        _ ->
            False
