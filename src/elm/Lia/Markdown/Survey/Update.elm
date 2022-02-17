module Lia.Markdown.Survey.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Browser exposing (element)
import Dict
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types exposing (Element, State(..), Vector, toString)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script
import Translations exposing (Lang(..))


type Msg sub
    = TextUpdate Int String
    | SelectUpdate Int Int
    | SelectChose Int
    | VectorUpdate Int String
    | MatrixUpdate Int Int String
    | Submit Int
      --| KeyDown Int Int
    | Handle Event
    | Script (Script.Msg sub)


update : Maybe Int -> Scripts a -> Msg sub -> Vector -> Return Vector msg sub
update sectionID scripts msg vector =
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

        --KeyDown id char ->
        --    if char == 13 then
        --        update sectionID scripts (Submit id) vector
        --    else
        --        Return.val vector
        Submit id ->
            case vector |> Array.get id of
                Just element ->
                    case element.scriptID of
                        Nothing ->
                            if submittable vector id then
                                let
                                    new_vector =
                                        submit vector id
                                in
                                new_vector
                                    |> Return.val
                                    |> Return.doSync
                                    |> store sectionID

                            else
                                vector
                                    |> Return.val

                        Just scriptID ->
                            (if element.errorMsg == Nothing then
                                vector

                             else
                                updateError vector id Nothing
                            )
                                |> Return.val
                                |> Return.batchEvent
                                    (case
                                        scripts
                                            |> Array.get scriptID
                                            |> Maybe.map .script
                                     of
                                        Just code ->
                                            [ toString element.state ]
                                                |> Service.Script.eval code (outputs scripts)
                                                |> Event.pushWithId "eval" id

                                        Nothing ->
                                            Event.none
                                    )

                _ ->
                    Return.val vector

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub

        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    param
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> Return.doSync
                        |> init (\i s -> execute i s.state)

                ( Just "eval", section, ( "eval", param ) ) ->
                    case
                        vector
                            |> Array.get section
                            |> Maybe.andThen .scriptID
                    of
                        Just scriptID ->
                            param
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store sectionID
                                |> Return.script (JS.submit scriptID event)
                                |> Return.doSync

                        Nothing ->
                            param
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store sectionID
                                |> Return.doSync

                {- let
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
                -}
                ( Just "restore", _, ( cmd, param ) ) ->
                    param
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> Return.doSync
                        |> init (\i s -> execute i s.state)

                _ ->
                    Return.val vector


update_ :
    Int
    -> Vector
    -> (Element -> Return Element msg sub)
    -> Return Vector msg sub
update_ idx vector fn =
    case Array.get idx vector |> Maybe.map fn of
        Just ret ->
            Return.mapVal (\v -> Array.set idx v vector) ret

        _ ->
            Return.val vector


store : Maybe Int -> Return Vector msg sub -> Return Vector msg sub
store sectionID return =
    case sectionID of
        Just id ->
            return
                |> Return.batchEvent
                    (return.value
                        |> Json.fromVector
                        |> Service.Database.store "survey" id
                    )

        Nothing ->
            return


execute : Int -> State -> Script.Msg sub
execute id =
    toString >> JS.run id


evalEventDecoder : JE.Value -> Element -> Return Element msg sub
evalEventDecoder json =
    let
        eval =
            Service.Script.decode json
    in
    if eval.ok then
        if eval.result == "true" then
            \e -> Return.val { e | submitted = True }

        else
            Return.val

    else
        \e ->
            Return.val { e | errorMsg = Just eval.result }


updateError : Vector -> Int -> Maybe String -> Vector
updateError vector id message =
    case Array.get id vector |> Maybe.map (\e -> ( e.submitted, e )) of
        Just ( False, element ) ->
            set_state vector id { element | errorMsg = message }

        _ ->
            vector


update_text : Vector -> Int -> String -> Vector
update_text vector idx str =
    case Array.get idx vector |> Maybe.map (\e -> ( e.submitted, e.state, e )) of
        Just ( False, Text_State _, element ) ->
            set_state vector idx { element | state = Text_State str }

        _ ->
            vector


update_select : Vector -> Int -> Int -> Vector
update_select vector id value =
    case Array.get id vector |> Maybe.map (\e -> ( e.submitted, e.state, e )) of
        Just ( False, Select_State _ _, element ) ->
            set_state vector id { element | state = Select_State False value }

        _ ->
            vector


update_select_chose : Vector -> Int -> Vector
update_select_chose vector id =
    case Array.get id vector |> Maybe.map (\e -> ( e.submitted, e.state, e )) of
        Just ( False, Select_State b value, element ) ->
            set_state vector id { element | state = Select_State (not b) value }

        _ ->
            vector


update_vector : Vector -> Int -> String -> Vector
update_vector vector idx var =
    case Array.get idx vector |> Maybe.map (\e -> ( e.submitted, e.state, e )) of
        Just ( False, Vector_State False e, element ) ->
            { element
                | state =
                    e
                        |> Dict.map (\_ _ -> False)
                        |> Dict.update var (\_ -> Just True)
                        |> Vector_State False
            }
                |> set_state vector idx

        Just ( False, Vector_State True e, element ) ->
            { element
                | state =
                    e
                        |> Dict.update var (\b -> Maybe.map not b)
                        |> Vector_State True
            }
                |> set_state vector idx

        _ ->
            vector


update_matrix : Vector -> Int -> Int -> String -> Vector
update_matrix vector col_id row_id var =
    case Array.get col_id vector |> Maybe.map (\e -> ( e.submitted, e.state, e )) of
        Just ( False, Matrix_State False matrix, element ) ->
            let
                row =
                    Array.get row_id matrix
            in
            { element
                | state =
                    row
                        |> Maybe.map (\d -> Dict.map (\_ _ -> False) d)
                        |> Maybe.map (\d -> Dict.update var (\_ -> Just True) d)
                        |> Maybe.map (\d -> Array.set row_id d matrix)
                        |> Maybe.withDefault matrix
                        |> Matrix_State False
            }
                |> set_state vector col_id

        Just ( False, Matrix_State True matrix, element ) ->
            let
                row =
                    Array.get row_id matrix
            in
            { element
                | state =
                    row
                        |> Maybe.map (\d -> Dict.update var (\b -> Maybe.map not b) d)
                        |> Maybe.map (\d -> Array.set row_id d matrix)
                        |> Maybe.withDefault matrix
                        |> Matrix_State True
            }
                |> set_state vector col_id

        _ ->
            vector


set_state : Vector -> Int -> Element -> Vector
set_state vector id element =
    Array.set id element vector


submit : Vector -> Int -> Vector
submit vector idx =
    case Array.get idx vector of
        Just element ->
            Array.set idx { element | submitted = True } vector

        _ ->
            vector


submittable : Vector -> Int -> Bool
submittable vector idx =
    case
        vector
            |> Array.get idx
            |> Maybe.map (\e -> ( e.submitted, e.state ))
    of
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
