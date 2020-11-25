module Lia.Markdown.Survey.Update exposing (Msg(..), handle, update)

import Array
import Dict
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types exposing (State(..), Vector, toString)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)


type Msg sub
    = TextUpdate Int String
    | SelectUpdate Int Int
    | SelectChose Int
    | VectorUpdate Int String
    | MatrixUpdate Int Int String
    | Submit Int (Maybe String)
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> ( Vector, List Event, Maybe (Script.Msg sub) )
update scripts msg vector =
    case msg of
        TextUpdate idx str ->
            ( update_text vector idx str, [], Nothing )

        SelectUpdate id value ->
            ( update_select vector id value, [], Nothing )

        SelectChose id ->
            ( update_select_chose vector id, [], Nothing )

        VectorUpdate idx var ->
            ( update_vector vector idx var, [], Nothing )

        MatrixUpdate idx row var ->
            ( update_matrix vector idx row var, [], Nothing )

        Submit id Nothing ->
            if submitable vector id then
                let
                    new_vector =
                        submit vector id
                in
                ( new_vector
                , new_vector
                    |> Json.fromVector
                    |> Event.store
                    |> List.singleton
                , Nothing
                )

            else
                ( vector, [], Nothing )

        Submit id (Just code) ->
            case vector |> Array.get id of
                Just ( False, state ) ->
                    ( vector
                    , [ [ toString state ]
                            |> Eval.event id code (outputs scripts)
                      ]
                    , Nothing
                    )

                _ ->
                    ( vector, [], Nothing )

        Script sub ->
            ( vector, [], Just sub )

        Handle event ->
            case event.topic of
                "eval" ->
                    if
                        event.message
                            |> Eval.decode
                            |> .result
                            |> (==) "true"
                    then
                        update scripts (Submit event.section Nothing) vector

                    else
                        ( vector, [], Nothing )

                "restore" ->
                    ( event.message
                        |> Json.toVector
                        |> Result.withDefault vector
                    , []
                    , Nothing
                    )

                _ ->
                    ( vector, [], Nothing )


update_text : Vector -> Int -> String -> Vector
update_text vector idx str =
    case Array.get idx vector of
        Just ( False, Text_State _ ) ->
            set_state vector idx (Text_State str)

        _ ->
            vector


update_select : Vector -> Int -> Int -> Vector
update_select vector id value =
    case Array.get id vector of
        Just ( False, Select_State _ _ ) ->
            set_state vector id (Select_State False value)

        _ ->
            vector


update_select_chose : Vector -> Int -> Vector
update_select_chose vector id =
    case Array.get id vector of
        Just ( False, Select_State b value ) ->
            set_state vector id (Select_State (not b) value)

        _ ->
            vector


update_vector : Vector -> Int -> String -> Vector
update_vector vector idx var =
    case Array.get idx vector of
        Just ( False, Vector_State False element ) ->
            element
                |> Dict.map (\_ _ -> False)
                |> Dict.update var (\_ -> Just True)
                |> Vector_State False
                |> set_state vector idx

        Just ( False, Vector_State True element ) ->
            element
                |> Dict.update var (\b -> Maybe.map not b)
                |> Vector_State True
                |> set_state vector idx

        _ ->
            vector


update_matrix : Vector -> Int -> Int -> String -> Vector
update_matrix vector col_id row_id var =
    case Array.get col_id vector of
        Just ( False, Matrix_State False matrix ) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.map (\_ _ -> False) d)
                |> Maybe.map (\d -> Dict.update var (\_ -> Just True) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> Matrix_State False
                |> set_state vector col_id

        Just ( False, Matrix_State True matrix ) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> Matrix_State True
                |> set_state vector col_id

        _ ->
            vector


set_state : Vector -> Int -> State -> Vector
set_state vector idx state =
    Array.set idx ( False, state ) vector


submit : Vector -> Int -> Vector
submit vector idx =
    case Array.get idx vector of
        Just ( False, state ) ->
            Array.set idx ( True, state ) vector

        _ ->
            vector


submitable : Vector -> Int -> Bool
submitable vector idx =
    case Array.get idx vector of
        Just ( False, Text_State state ) ->
            state /= ""

        Just ( False, Select_State _ state ) ->
            state /= -1

        Just ( False, Vector_State _ state ) ->
            state
                |> Dict.values
                |> List.filter (\a -> a)
                |> List.length
                |> (\s -> s > 0)

        Just ( False, Matrix_State _ state ) ->
            state
                |> Array.toList
                |> List.map Dict.values
                |> List.map (\l -> List.filter (\a -> a) l)
                |> List.all (\a -> List.length a > 0)

        _ ->
            False


handle : Event -> Msg sub
handle =
    Handle
