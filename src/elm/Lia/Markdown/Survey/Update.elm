module Lia.Markdown.Survey.Update exposing
    ( DropMsg(..)
    , Msg(..)
    , SelectMsg(..)
    , handle
    , lockAnswered
    , update
    )

import Array
import Browser exposing (element)
import Dict
import Helper.Array as Array
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Sync as Sync
import Lia.Markdown.Survey.Types exposing (Element, State(..), Vector, toString)
import Lia.Sync.Types as Classroom
import Process
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script
import Task


type DropMsg
    = Target
    | Drop Int
    | Start
    | Enter Bool
    | Source Int
    | Exit


type SelectMsg
    = Choose
    | Update Int


type Msg sub
    = TextUpdate Int String
    | SelectUpdate Int SelectMsg
    | DropUpdate Int DropMsg
    | VectorUpdate Int String
    | MatrixUpdate Int Int String
    | Submit Int
    | Reactivate Int
    | Handle Event
    | Script (Script.Msg sub)
    | None


update :
    { sync | state : Classroom.State, data : Classroom.Data }
    -> Maybe Int
    -> Scripts a
    -> Msg sub
    -> Vector
    -> Return Vector (Msg sub) sub
update classroom sectionID scripts msg vector =
    let
        connected =
            Classroom.isConnected classroom.state
    in
    case msg of
        TextUpdate id str ->
            vector
                |> Array.update id (update_text str)
                |> Return.val

        SelectUpdate id event ->
            vector
                |> Array.update id (update_select event)
                |> Return.val

        VectorUpdate id var ->
            vector
                |> Array.update id (update_vector var)
                |> Return.val

        MatrixUpdate id row var ->
            vector
                |> Array.update id (update_matrix row var)
                |> Return.val

        DropUpdate id event ->
            vector
                |> Array.update id (update_drop event)
                |> Return.val
                |> Return.cmd
                    (case event of
                        Enter False ->
                            Process.sleep 1
                                |> Task.attempt (always <| DropUpdate id Exit)

                        _ ->
                            Cmd.none
                    )

        --KeyDown id char ->
        --    if char == 13 then
        --        update sectionID scripts (Submit id) vector
        --    else
        --        Return.val vector
        Reactivate id ->
            vector
                |> Array.update id (\element -> { element | submitted = False })
                |> Return.val

        Submit id ->
            case vector |> Array.get id of
                Just element ->
                    case element.scriptID of
                        Nothing ->
                            if element.opt.incompleteness_allowed || submittable vector id then
                                let
                                    new_vector =
                                        Array.update id submit vector
                                in
                                new_vector
                                    |> Return.val
                                    |> doSync connected sectionID (Just id)
                                    |> store sectionID

                            else
                                -- this is a hack to trigger the error message for empty answers
                                vector
                                    |> Array.update id (updateError (Just ""))
                                    |> Return.val

                        Just scriptID ->
                            (if element.errorMsg == Nothing then
                                vector

                             else
                                vector
                                    |> Array.update id (updateError Nothing)
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
                    if Array.isEmpty vector then
                        -- Section not parsed yet (no survey blocks known
                        -- locally, e.g. this is the eager sync preload for
                        -- an unvisited section) - nothing local to merge
                        -- into, but the CRDT should still learn about
                        -- persisted answers so peers see them in "details
                        -- mode" before this section is ever visited.
                        vector
                            |> Return.val
                            |> (if connected then
                                    Return.batchEvents
                                        (param
                                            |> Json.toVector
                                            |> Result.map (Array.toList >> List.indexedMap Sync.event >> List.filter Event.notNone)
                                            |> Result.withDefault []
                                        )

                                else
                                    identity
                               )

                    else
                        param
                            |> Json.toVector
                            |> Result.map (merge (\sID body -> { body | scriptID = sID.scriptID }) vector)
                            |> Result.withDefault vector
                            |> lockAnswered classroom sectionID
                            |> Return.val
                            |> doSync connected sectionID Nothing
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
                                |> doSync connected sectionID (Just section)

                        Nothing ->
                            param
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store sectionID
                                |> doSync connected sectionID (Just section)

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
                        |> Result.map (merge (\sID body -> { body | scriptID = sID.scriptID }) vector)
                        |> Result.withDefault vector
                        |> lockAnswered classroom sectionID
                        |> Return.val
                        |> doSync connected sectionID Nothing
                        |> init (\i s -> execute i s.state)

                _ ->
                    Return.val vector

        None ->
            Return.val vector


lockAnswered : { sync | state : Classroom.State, data : Classroom.Data } -> Maybe Int -> Vector -> Vector
lockAnswered classroom sectionID =
    Sync.lockAnswered (Classroom.id classroom.state) classroom.data.survey sectionID


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


updateError : Maybe String -> Element -> Element
updateError message element =
    if element.submitted then
        element

    else
        { element | errorMsg = message }


update_text : String -> Element -> Element
update_text str element =
    case ( element.submitted, element.state ) of
        ( False, Text_State _ ) ->
            { element | state = Text_State str }

        _ ->
            element


update_select : SelectMsg -> Element -> Element
update_select event element =
    case ( element.submitted, element.state, event ) of
        ( False, Select_State b value, Choose ) ->
            { element | state = Select_State (not b) value }

        ( False, Select_State _ _, Update newValue ) ->
            { element | state = Select_State False newValue }

        _ ->
            element


update_drop : DropMsg -> Element -> Element
update_drop event element =
    case ( element.submitted, element.state ) of
        ( False, DragAndDrop_State highlight active value ) ->
            { element
                | state =
                    case event of
                        Start ->
                            DragAndDrop_State highlight True value

                        Drop idx ->
                            if highlight then
                                DragAndDrop_State False False idx

                            else if idx == value then
                                DragAndDrop_State False False -1

                            else
                                DragAndDrop_State highlight False value

                        Enter True ->
                            DragAndDrop_State True active value

                        Exit ->
                            DragAndDrop_State False False -1

                        Target ->
                            DragAndDrop_State highlight False -1

                        Source idx ->
                            DragAndDrop_State False False idx

                        _ ->
                            element.state
            }

        _ ->
            element


update_vector : String -> Element -> Element
update_vector var element =
    case ( element.submitted, element.state ) of
        ( False, Vector_State True dict ) ->
            { element | state = Vector_State True (Dict.update var (Maybe.map not) dict) }

        ( False, Vector_State False dict ) ->
            { element
                | state =
                    dict
                        |> Dict.map (\_ _ -> False)
                        |> Dict.insert var (not (Dict.get var dict |> Maybe.withDefault False))
                        |> Vector_State False
            }

        _ ->
            element


update_matrix : Int -> String -> Element -> Element
update_matrix row_id var element =
    case ( element.submitted, element.state ) of
        ( False, Matrix_State True matrix ) ->
            { element
                | state =
                    matrix
                        |> Array.update row_id (Dict.update var (Maybe.map not))
                        |> Matrix_State True
            }

        ( False, Matrix_State False matrix ) ->
            { element
                | state =
                    matrix
                        |> Array.update row_id
                            (\row ->
                                row
                                    |> Dict.map (\_ _ -> False)
                                    |> Dict.insert var (not (Dict.get var row |> Maybe.withDefault False))
                            )
                        |> Matrix_State False
            }

        _ ->
            element


submit : Element -> Element
submit element =
    { element | submitted = True, errorMsg = Nothing }


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

        Just ( False, DragAndDrop_State _ _ state ) ->
            state /= -1

        Just ( False, Vector_State _ state ) ->
            state
                |> Dict.values
                |> List.filter identity
                |> List.length
                |> (\s -> s > 0)

        Just ( False, Matrix_State _ state ) ->
            state
                |> Array.toList
                |> List.map Dict.values
                |> List.map (List.filter identity)
                |> List.all (List.isEmpty >> not)

        _ ->
            False


handle : Event -> Msg sub
handle =
    Handle


doSync : Bool -> Maybe Int -> Maybe Int -> Return Vector msg sub -> Return Vector msg sub
doSync sync sectionID vectorID ret =
    if not sync then
        ret

    else
        case ( sectionID, vectorID ) of
            ( Nothing, _ ) ->
                ret

            ( Just _, Nothing ) ->
                ret
                    |> Return.batchEvents
                        (ret.value
                            |> Array.toList
                            |> List.indexedMap Sync.event
                        )

            ( Just _, Just id ) ->
                ret
                    |> Return.batchEvent
                        (ret.value
                            |> Array.get id
                            |> Maybe.map (Sync.event id)
                            |> Maybe.withDefault Event.none
                        )
