module Lia.Markdown.Task.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Vector)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)
import Return exposing (Return)


{-| Interaction associated to LiaScript task list:

  - `Toggle x y js`: toggle on boolean value, depending on the `x` and `y`
    coordinates. If set, the js code is executed after every toggle event.
  - `Handle`: event communication via ports
  - `Script`: mandatory to enable `Effect.Script` events to be executed in every
    module

-}
type Msg sub
    = Toggle Int Int (Maybe String)
    | Handle Event
    | Script (Script.Msg sub)


update :
    Scripts a
    -> Msg sub
    -> Vector
    -> Return Vector Never sub
update scripts msg vector =
    case msg of
        -- simple toggle
        Toggle x y Nothing ->
            vector
                |> Array.get x
                |> Maybe.map (\state -> Array.set x (toggle y state) vector)
                |> Maybe.withDefault vector
                |> Return.value
                |> store

        -- toggle and execute the code snippet
        Toggle x y (Just code) ->
            case
                vector
                    |> Array.get x
                    |> Maybe.map (toggle y)
            of
                Just state ->
                    vector
                        |> Array.set x state
                        |> Return.value
                        |> Return.event
                            ([ state
                                |> JE.array JE.bool
                                |> JE.encode 0
                             ]
                                |> Eval.event x code (outputs scripts)
                            )
                        |> store

                Nothing ->
                    Return.value vector

        Script sub ->
            vector
                |> Return.value
                |> Return.script sub

        Handle event ->
            Return.value <|
                case event.topic of
                    -- currently it is only possible to restore states from the backend
                    "restore" ->
                        event.message
                            |> Json.toVector
                            |> Result.withDefault vector

                    -- eval events are not handled at the moment
                    _ ->
                        vector


toggle : Int -> Array Bool -> Array Bool
toggle y states =
    Array.set y
        (states
            |> Array.get y
            |> Maybe.map not
            |> Maybe.withDefault False
        )
        states


{-| Create a store event, that will store the state of the task persistently
within the backend.
-}
store : Return Vector Never sub -> Return Vector Never sub
store return =
    return
        |> Return.event
            (return.value
                |> Json.fromVector
                |> Event.store
            )


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle
