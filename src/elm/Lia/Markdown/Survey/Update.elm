module Lia.Markdown.Survey.Update exposing (Msg(..), handle, update)

import Array
import Dict
import Json.Decode as JD
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types exposing (Element(..), State(..), Sync, Vector, toString)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)
import Return exposing (Return)


type Msg sub
    = TextUpdate Int String
    | SelectUpdate Int Int
    | SelectChose Int
    | VectorUpdate Int String
    | MatrixUpdate Int Int String
    | Submit Int (Maybe String)
    | KeyDown Int (Maybe String) Int
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

        KeyDown id javascript char ->
            if char == 13 then
                update scripts (Submit id javascript) vector

            else
                Return.val vector

        Submit id Nothing ->
            if submittable vector id then
                case submit vector id of
                    ( Just state, new_vector ) ->
                        new_vector
                            |> Return.val
                            |> Return.batchEvent
                                (new_vector
                                    |> Json.fromVector
                                    |> Event.store
                                )
                            |> Return.sync
                                (state
                                    |> Json.fromState
                                    |> Event "submit" id
                                )

                    _ ->
                        Return.val vector

            else
                Return.val vector

        Submit id (Just code) ->
            case vector |> Array.get id of
                Just (Element False state error _) ->
                    (if error == Nothing then
                        vector

                     else
                        updateError vector id Nothing
                    )
                        |> Return.val
                        |> Return.batchEvent
                            ([ toString state ]
                                |> Eval.event id code (outputs scripts)
                            )
                        |> Return.sync
                            (state
                                |> Json.fromState
                                |> Event "submit" id
                            )

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
                        update scripts (Submit event.section Nothing) vector

                    else if eval.result /= "" && not eval.ok then
                        Just eval.result
                            |> updateError vector event.section
                            |> Return.val

                    else
                        Return.val vector

                "restore" ->
                    event.message
                        |> Json.toVector
                        |> Result.withDefault vector
                        |> Return.val

                "sync" ->
                    event.message
                        |> Event.decode
                        |> Result.map (updateSync vector)
                        |> Result.withDefault vector
                        |> Return.val

                _ ->
                    Return.val vector


updateSync : Vector -> Event -> Vector
updateSync vector event =
    case ( event.topic, JD.decodeValue Json.toState event.message ) of
        ( "submit", Ok state ) ->
            case Array.get event.section vector of
                Just (Element a b c (Just sync)) ->
                    Array.set
                        event.section
                        (Element a b c (Just (state :: sync)))
                        vector

                Just (Element a b c Nothing) ->
                    Array.set
                        event.section
                        (Element a b c (Just [ state ]))
                        vector

                _ ->
                    vector

        _ ->
            vector


updateError : Vector -> Int -> Maybe String -> Vector
updateError vector id message =
    case Array.get id vector of
        Just (Element False state _ sync) ->
            set_state vector id message sync state

        _ ->
            vector


update_text : Vector -> Int -> String -> Vector
update_text vector idx str =
    case Array.get idx vector of
        Just (Element False (Text_State _) error sync) ->
            set_state vector idx error sync (Text_State str)

        _ ->
            vector


update_select : Vector -> Int -> Int -> Vector
update_select vector id value =
    case Array.get id vector of
        Just (Element False (Select_State _ _) error sync) ->
            set_state vector id error sync (Select_State False value)

        _ ->
            vector


update_select_chose : Vector -> Int -> Vector
update_select_chose vector id =
    case Array.get id vector of
        Just (Element False (Select_State b value) error sync) ->
            set_state vector id error sync (Select_State (not b) value)

        _ ->
            vector


update_vector : Vector -> Int -> String -> Vector
update_vector vector idx var =
    case Array.get idx vector of
        Just (Element False (Vector_State False element) error sync) ->
            element
                |> Dict.map (\_ _ -> False)
                |> Dict.update var (\_ -> Just True)
                |> Vector_State False
                |> set_state vector idx error sync

        Just (Element False (Vector_State True element) error sync) ->
            element
                |> Dict.update var (\b -> Maybe.map not b)
                |> Vector_State True
                |> set_state vector idx error sync

        _ ->
            vector


update_matrix : Vector -> Int -> Int -> String -> Vector
update_matrix vector col_id row_id var =
    case Array.get col_id vector of
        Just (Element False (Matrix_State False matrix) error sync) ->
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
                |> set_state vector col_id error sync

        Just (Element False (Matrix_State True matrix) error sync) ->
            let
                row =
                    Array.get row_id matrix
            in
            row
                |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                |> Maybe.map (\d -> Array.set row_id d matrix)
                |> Maybe.withDefault matrix
                |> Matrix_State True
                |> set_state vector col_id error sync

        _ ->
            vector


set_state : Vector -> Int -> Maybe String -> Maybe Sync -> State -> Vector
set_state vector idx error sync state =
    Array.set idx (Element False state error sync) vector


submit : Vector -> Int -> ( Maybe State, Vector )
submit vector idx =
    case Array.get idx vector of
        Just (Element False state error sync) ->
            ( Just state, Array.set idx (Element True state error sync) vector )

        _ ->
            ( Nothing, vector )


submittable : Vector -> Int -> Bool
submittable vector idx =
    case Array.get idx vector of
        Just (Element False (Text_State state) _ _) ->
            state /= ""

        Just (Element False (Select_State _ state) _ _) ->
            state /= -1

        Just (Element False (Vector_State _ state) _ _) ->
            state
                |> Dict.values
                |> List.filter (\a -> a)
                |> List.length
                |> (\s -> s > 0)

        Just (Element False (Matrix_State _ state) _ _) ->
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
