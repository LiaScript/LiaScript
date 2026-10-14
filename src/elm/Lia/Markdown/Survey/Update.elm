module Lia.Markdown.Survey.Update exposing
    ( DropMsg(..)
    , Msg(..)
    , SelectMsg(..)
    , handle
    , lockAnswered
    , update
    )

import Array
import Dict exposing (Dict)
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
import Service.Slide
import Task


{-| Drag and drop of an option onto the target, or a click on an option and
then on the target (keyboard):

  - `Start`: an option is dragged
  - `Enter True`/`Enter False`: the dragged option enters or leaves the target,
    leaving triggers an `Exit` shortly after
  - `Drop i`: the drag of option `i` ended (dropped on the target, if it is
    highlighted, otherwise the dropped option is removed if it was dragged out)
  - `Source i`: option `i` was clicked and is put on the target
  - `Target`: the target was clicked, the dropped option is removed

-}
type DropMsg
    = Target
    | Drop Int
    | Start
    | Enter Bool
    | Source Int
    | Exit


{-| Open or close the dropdown, or choose an option.
-}
type SelectMsg
    = Choose
    | Update Int


{-| All messages, the first `Int` is always the id of the survey.
-}
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


{-| Update the surveys of a section. `sectionID` is `Nothing` for subsections,
whose states are neither stored nor shared, `scripts` are the scripts of the
section, which can check an answer before it is submitted.
-}
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

        restore param =
            param
                |> Json.toVector
                |> Result.map (merge (\parsed stored -> { stored | scriptID = parsed.scriptID, opt = parsed.opt }) vector)
                |> Result.withDefault vector
                |> lockAnswered classroom sectionID
                |> Return.val
                |> doSync connected sectionID Nothing
                |> init (\id element -> JS.run id (toString element.state))
    in
    case msg of
        TextUpdate id str ->
            vector
                |> Array.update id (updateText str)
                |> Return.val

        SelectUpdate id event ->
            vector
                |> Array.update id (updateSelect event)
                |> Return.val

        VectorUpdate id var ->
            vector
                |> Array.update id (updateVector var)
                |> Return.val

        MatrixUpdate id row var ->
            vector
                |> Array.update id (updateMatrix row var)
                |> Return.val

        DropUpdate id event ->
            vector
                |> Array.update id (updateDrop event)
                |> Return.val
                |> Return.cmd
                    (if event == Enter False then
                        Process.sleep 1
                            |> Task.attempt (always (DropUpdate id Exit))

                     else
                        Cmd.none
                    )

        Reactivate id ->
            vector
                |> Array.update id (\element -> { element | submitted = False })
                |> Return.val

        Submit id ->
            case Array.get id vector of
                Just element ->
                    case element.scriptID of
                        Nothing ->
                            if element.opt.incompleteness_allowed || submittable element then
                                vector
                                    |> Array.update id submit
                                    |> Return.val
                                    |> doSync connected sectionID (Just id)
                                    |> store sectionID
                                    |> reveal id

                            else
                                -- an empty message shows the default error
                                vector
                                    |> Array.update id (updateError (Just ""))
                                    |> Return.val
                                    |> reveal id

                        Just scriptID ->
                            -- the script decides, its answer is handled by
                            -- the "eval" event
                            vector
                                |> Array.update id (updateError Nothing)
                                |> Return.val
                                |> Return.batchEvent
                                    (case Array.get scriptID scripts of
                                        Just { script } ->
                                            [ toString element.state ]
                                                |> Service.Script.eval Nothing script (outputs scripts)
                                                |> Event.pushWithId "eval" id

                                        Nothing ->
                                            Event.none
                                    )

                Nothing ->
                    Return.val vector

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub

        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    if Array.isEmpty vector then
                        -- Section not parsed yet (e.g. the eager sync preload
                        -- of an unvisited section), there is nothing to merge
                        -- into, but the classroom should learn about persisted
                        -- answers, so that peers see them in details mode.
                        vector
                            |> Return.val
                            |> (if connected then
                                    param
                                        |> Json.toVector
                                        |> Result.map (Array.toList >> List.indexedMap Sync.event)
                                        |> Result.withDefault []
                                        |> Return.batchEvents

                                else
                                    identity
                               )

                    else
                        restore param

                ( Just "eval", id, ( "eval", param ) ) ->
                    vector
                        |> Array.update id (evaluate param)
                        |> Return.val
                        |> store sectionID
                        |> (case Array.get id vector |> Maybe.andThen .scriptID of
                                Just scriptID ->
                                    Return.script (JS.submit scriptID event)

                                Nothing ->
                                    identity
                           )
                        |> doSync connected sectionID (Just id)
                        |> reveal id

                ( Just "restore", _, ( _, param ) ) ->
                    restore param

                _ ->
                    Return.val vector

        None ->
            Return.val vector


{-| Translate an `Event` into a message.
-}
handle : Event -> Msg sub
handle =
    Handle


{-| Lock all surveys that have already been answered in the classroom, see
`Lia.Markdown.Survey.Sync.lockAnswered`.
-}
lockAnswered : { sync | state : Classroom.State, data : Classroom.Data } -> Maybe Int -> Vector -> Vector
lockAnswered classroom sectionID =
    Sync.lockAnswered (Classroom.id classroom.state) classroom.data.survey sectionID


{-| Scroll the feedback and the solution of a survey into the visible area, if
they are not already.
-}
reveal : Int -> Return Vector msg sub -> Return Vector msg sub
reveal id =
    -- ports dispatch in reverse order, the solution (below the feedback) has to win
    Return.batchEvents
        [ Service.Slide.reveal ("lia-survey-solution-" ++ String.fromInt id)
        , Service.Slide.reveal ("lia-survey-feedback-" ++ String.fromInt id)
        ]


{-| Store the states of all surveys of a section.
-}
store : Maybe Int -> Return Vector msg sub -> Return Vector msg sub
store sectionID return =
    case sectionID of
        Just id ->
            Return.batchEvent
                (return.value
                    |> Json.fromVector
                    |> Service.Database.store "survey" id
                )
                return

        Nothing ->
            return


{-| Share the answer of survey `id` or, for `Nothing`, of all surveys of the
section with the classroom.
-}
doSync : Bool -> Maybe Int -> Maybe Int -> Return Vector msg sub -> Return Vector msg sub
doSync connected sectionID id return =
    case ( connected, sectionID, id ) of
        ( True, Just _, Nothing ) ->
            Return.batchEvents
                (return.value
                    |> Array.toList
                    |> List.indexedMap Sync.event
                )
                return

        ( True, Just _, Just i ) ->
            Return.batchEvent
                (return.value
                    |> Array.get i
                    |> Maybe.map (Sync.event i)
                    |> Maybe.withDefault Event.none
                )
                return

        _ ->
            return


{-| Apply the result of a script, `true` submits the survey and an error is
shown as feedback.
-}
evaluate : JE.Value -> Element -> Element
evaluate json element =
    let
        eval =
            Service.Script.decode json
    in
    if not eval.ok then
        { element | errorMsg = Just eval.result }

    else if eval.result == "true" then
        { element | submitted = True }

    else
        element


updateError : Maybe String -> Element -> Element
updateError message element =
    if element.submitted then
        element

    else
        { element | errorMsg = message }


updateText : String -> Element -> Element
updateText str element =
    case ( element.submitted, element.state ) of
        ( False, Text_State _ ) ->
            { element | state = Text_State str }

        _ ->
            element


updateSelect : SelectMsg -> Element -> Element
updateSelect event element =
    case ( element.submitted, element.state, event ) of
        ( False, Select_State open value, Choose ) ->
            { element | state = Select_State (not open) value }

        ( False, Select_State _ _, Update value ) ->
            { element | state = Select_State False value }

        _ ->
            element


updateDrop : DropMsg -> Element -> Element
updateDrop event element =
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
                                -- the dropped option was dragged out
                                DragAndDrop_State False False -1

                            else
                                DragAndDrop_State highlight False value

                        Enter True ->
                            DragAndDrop_State True active value

                        Enter False ->
                            element.state

                        Exit ->
                            DragAndDrop_State False False -1

                        Target ->
                            DragAndDrop_State highlight False -1

                        Source idx ->
                            DragAndDrop_State False False idx
            }

        _ ->
            element


updateVector : String -> Element -> Element
updateVector var element =
    case ( element.submitted, element.state ) of
        ( False, Vector_State checkbox dict ) ->
            { element | state = Vector_State checkbox (check checkbox var dict) }

        _ ->
            element


updateMatrix : Int -> String -> Element -> Element
updateMatrix row var element =
    case ( element.submitted, element.state ) of
        ( False, Matrix_State checkbox matrix ) ->
            { element | state = Matrix_State checkbox (Array.update row (check checkbox var) matrix) }

        _ ->
            element


{-| Toggle a checkbox (only known variables) or select a radio button, which
deselects all others.
-}
check : Bool -> String -> Dict String Bool -> Dict String Bool
check checkbox var dict =
    if checkbox then
        Dict.update var (Maybe.map not) dict

    else
        dict
            |> Dict.map (\_ _ -> False)
            |> Dict.insert var (not (Dict.get var dict |> Maybe.withDefault False))


submit : Element -> Element
submit element =
    { element | submitted = True, errorMsg = Nothing }


{-| An open survey can be submitted, if it is answered completely, i.e. every
row of a matrix is answered.
-}
submittable : Element -> Bool
submittable element =
    case ( element.submitted, element.state ) of
        ( False, Text_State state ) ->
            state /= ""

        ( False, Select_State _ state ) ->
            state /= -1

        ( False, DragAndDrop_State _ _ state ) ->
            state /= -1

        ( False, Vector_State _ state ) ->
            List.any identity (Dict.values state)

        ( False, Matrix_State _ state ) ->
            state
                |> Array.toList
                |> List.all (Dict.values >> List.any identity)

        _ ->
            False
