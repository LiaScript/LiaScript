module Lia.Markdown.Task.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Helper.Array as Array
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Element, Vector, toString)
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script


{-| Interaction associated to LiaScript task list:

  - `Toggle x y js`: toggle on boolean value, depending on the `x` and `y`
    coordinates. If set, the js code is executed after every toggle event.
  - `Handle`: event communication via ports
  - `Script`: mandatory to enable `Effect.Script` events to be executed in every
    module

-}
type Msg sub
    = Toggle Int Int
    | Handle Event
    | Script (Script.Msg sub)


update :
    Maybe Int
    -> Scripts a
    -> Msg sub
    -> Vector
    -> Return Vector msg sub
update sectionID scripts msg vector =
    case msg of
        -- simple toggle
        Toggle x y ->
            case Array.get x vector of
                Just element ->
                    let
                        toggled =
                            { element | state = Array.update y not element.state }
                    in
                    vector
                        |> Array.set x toggled
                        |> Return.val
                        |> Return.batchEvent (eval scripts x toggled)
                        |> store sectionID

                Nothing ->
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
                        |> Result.map (merge (\sID body -> { body | scriptID = sID.scriptID }) vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init execute

                ( Just "eval", section, ( "eval", _ ) ) ->
                    case
                        vector
                            |> Array.get section
                            |> Maybe.andThen .scriptID
                    of
                        Just scriptID ->
                            vector
                                |> Return.val
                                |> Return.script (JS.submit scriptID event)

                        Nothing ->
                            Return.val vector

                _ ->
                    Return.val vector


{-| **@private:** Run the optional script attached to a task list with its new
state, `Event.none` if there is none (dropped by `Return.batchEvent`).
-}
eval : Scripts a -> Int -> Element -> Event
eval scripts x element =
    case Maybe.andThen (\id -> Array.get id scripts) element.scriptID of
        Just { script } ->
            [ toString element ]
                |> Service.Script.eval script (outputs scripts)
                |> Event.pushWithId "eval" x

        Nothing ->
            Event.none


{-| Create a store event, that will store the state of the task persistently
within the backend.
-}
store : Maybe Int -> Return Vector msg sub -> Return Vector msg sub
store sectionID return =
    case sectionID of
        Just id ->
            return
                |> Return.batchEvent
                    (return.value
                        |> Json.fromVector
                        |> Service.Database.store "task" id
                    )

        Nothing ->
            return


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle


execute : Int -> Element -> Script.Msg sub
execute id =
    toString >> JS.run id
