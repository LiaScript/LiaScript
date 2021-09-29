module Lia.Markdown.Survey.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Dict
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts)
import Lia.Markdown.Effect.Script.Update exposing (run)
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types exposing (State(..), Vector, toString)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)
import Return exposing (Return)


type Msg sub
    = TextUpdate Int String
    | SelectUpdate Int Int
    | SelectChose Int
    | VectorUpdate Int String
    | MatrixUpdate Int Int String
    | Submit Int
    | KeyDown Int Int
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> Return Vector msg sub
update scripts msg vector =
    case msg of
        TextUpdate idx str ->
            update_text vector idx str
                |> Return.val

        SelectUpdate id value ->
            update_select vector id value
                |> Return.val

        SelectChose id ->
            update_select_chose vector id
                |> Return.val

        VectorUpdate idx var ->
            update_vector vector idx var
                |> Return.val

        MatrixUpdate idx row var ->
            update_matrix vector idx row var
                |> Return.val

        KeyDown id char ->
            if char == 13 then
                update scripts (Submit id) vector

            else
                Return.val vector

        Submit id ->
            case vector |> Array.get id of
                Just ( _, Nothing ) ->
                    if submittable vector id then
                        let
                            new_vector =
                                submit vector id
                        in
                        new_vector
                            |> Return.val
                            |> Return.batchEvent
                                (new_vector
                                    |> Json.fromVector
                                    |> Event.store
                                )

                    else
                        vector
                            |> Return.val

                Just ( ( False, state, error ), Just scriptID ) ->
                    (if error == Nothing then
                        vector

                     else
                        updateError vector id Nothing
                    )
                        |> Return.val
                        |> Return.script (execute scriptID state)

                --|> Return.batchEvent
                --    ([ toString state ]
                --        |> Eval.event id code (outputs scripts)
                --    )
                _ ->
                    Return.val vector

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub

        Handle event ->
            case event.topic of
                "eval" ->
                    let
                        eval =
                            Eval.decode event.message
                    in
                    if eval.result == "true" && eval.ok then
                        update scripts (Submit event.section) vector

                    else if eval.result /= "" && not eval.ok then
                        Just eval.result
                            |> updateError vector event.section
                            |> Return.val

                    else
                        Return.val vector

                "restore" ->
                    event.message
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val

                --|> init execute
                _ ->
                    Return.val vector


execute : Int -> State -> Script.Msg sub
execute id =
    toString >> run id


updateError : Vector -> Int -> Maybe String -> Vector
updateError vector id message =
    case Array.get id vector of
        Just ( ( False, state, _ ), js ) ->
            set_state vector id message js state

        _ ->
            vector


update_text : Vector -> Int -> String -> Vector
update_text vector idx str =
    case Array.get idx vector of
        Just ( ( False, Text_State _, error ), js ) ->
            set_state vector idx error js (Text_State str)

        _ ->
            vector


update_select : Vector -> Int -> Int -> Vector
update_select vector id value =
    case Array.get id vector of
        Just ( ( False, Select_State _ _, error ), js ) ->
            set_state vector id error js (Select_State False value)

        _ ->
            vector


update_select_chose : Vector -> Int -> Vector
update_select_chose vector id =
    case Array.get id vector of
        Just ( ( False, Select_State b value, error ), js ) ->
            set_state vector id error js (Select_State (not b) value)

        _ ->
            vector


update_vector : Vector -> Int -> String -> Vector
update_vector vector idx var =
    case Array.get idx vector of
        Just ( ( False, Vector_State False element, error ), js ) ->
            element
                |> Dict.map (\_ _ -> False)
                |> Dict.update var (\_ -> Just True)
                |> Vector_State False
                |> set_state vector idx error js

        Just ( ( False, Vector_State True element, error ), js ) ->
            element
                |> Dict.update var (\b -> Maybe.map not b)
                |> Vector_State True
                |> set_state vector idx error js

        _ ->
            vector


update_matrix : Vector -> Int -> Int -> String -> Vector
update_matrix vector col_id row_id var =
    case Array.get col_id vector of
        Just ( ( False, Matrix_State False matrix, error ), js ) ->
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
                |> set_state vector col_id error js

        Just ( ( False, Matrix_State True matrix, error ), js ) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> Matrix_State True
                |> set_state vector col_id error js

        _ ->
            vector


set_state : Vector -> Int -> Maybe String -> Maybe Int -> State -> Vector
set_state vector idx error js state =
    Array.set idx ( ( False, state, error ), js ) vector


submit : Vector -> Int -> Vector
submit vector idx =
    case Array.get idx vector of
        Just ( ( False, state, error ), js ) ->
            Array.set idx ( ( True, state, error ), js ) vector

        _ ->
            vector


submittable : Vector -> Int -> Bool
submittable vector idx =
    case Array.get idx vector |> Maybe.map Tuple.first of
        Just ( False, Text_State state, _ ) ->
            state /= ""

        Just ( False, Select_State _ state, _ ) ->
            state /= -1

        Just ( False, Vector_State _ state, _ ) ->
            state
                |> Dict.values
                |> List.filter (\a -> a)
                |> List.length
                |> (\s -> s > 0)

        Just ( False, Matrix_State _ state, _ ) ->
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
