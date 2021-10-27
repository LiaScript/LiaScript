module Lia.Markdown.Task.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Browser exposing (element)
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Element, Vector, toString)
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
    = Toggle Int Int
    | Handle Event
    | Script (Script.Msg sub)


update :
    Scripts a
    -> Msg sub
    -> Vector
    -> Return Vector msg sub
update scripts msg vector =
    case msg of
        -- simple toggle
        Toggle x y ->
            case
                vector
                    |> Array.get x
                    |> Maybe.map (toggle y)
            of
                Just element ->
                    case element.scriptID of
                        Nothing ->
                            vector
                                |> Array.set x element
                                |> Return.val
                                |> store

                        Just scriptID ->
                            vector
                                |> Array.set x element
                                |> Return.val
                                |> Return.batchEvents
                                    (case
                                        Array.get scriptID scripts
                                            |> Maybe.map .script
                                     of
                                        Just code ->
                                            [ [ toString element ]
                                                |> Eval.event x code (outputs scripts)
                                            ]

                                        Nothing ->
                                            []
                                    )
                                |> store

                --|> Return.script (execute id state)
                Nothing ->
                    Return.val vector

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub

        Handle event ->
            case Event.destructure event of
                ( Just ( "restore", _ ), message ) ->
                    message
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init execute

                ( Just ( "eval", Just section ), message ) ->
                    case
                        vector
                            |> Array.get section
                            |> Maybe.andThen .scriptID
                    of
                        Just scriptID ->
                            vector
                                |> Return.val
                                |> Return.script
                                    (message
                                        |> Event.initWithId "code" scriptID
                                        |> JS.handle
                                    )

                        Nothing ->
                            Return.val vector

                _ ->
                    Return.val vector


toggle : Int -> Element -> Element
toggle y element =
    { element
        | state =
            Array.set y
                (element.state
                    |> Array.get y
                    |> Maybe.map not
                    |> Maybe.withDefault False
                )
                element.state
    }


{-| Create a store event, that will store the state of the task persistently
within the backend.
-}
store : Return Vector msg sub -> Return Vector msg sub
store return =
    return
        |> Return.batchEvent
            (return.value
                |> Json.fromVector
                |> Event.store
            )


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle


execute : Int -> Element -> Script.Msg sub
execute id =
    toString >> JS.run id
