module Lia.Markdown.Task.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Update exposing (init, merge)
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Vector)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)
import Return exposing (Return, script)


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
                    |> Maybe.map (Tuple.mapFirst (toggle y))
            of
                Just ( state, Nothing ) ->
                    vector
                        |> Array.set x ( state, Nothing )
                        |> Return.val
                        |> store

                -- toggle and execute the code snippet
                Just ( state, Just id ) ->
                    vector
                        |> Array.set x ( state, Just id )
                        |> Return.val
                        |> Return.batchEvents
                            (case
                                Array.get id scripts
                                    |> Maybe.map .script
                             of
                                Just code ->
                                    [ [ state
                                            |> JE.array JE.bool
                                            |> JE.encode 0
                                      ]
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
            case event.topic of
                "restore" ->
                    event.message
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init execute

                "eval" ->
                    case
                        vector
                            |> Array.get event.section
                            |> Maybe.andThen Tuple.second
                    of
                        Just id ->
                            vector
                                |> Return.val
                                |> Return.script (JS.handle { event | topic = "code", section = id })

                        Nothing ->
                            Return.val vector

                _ ->
                    Return.val vector


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


execute : Int -> Array Bool -> Script.Msg sub
execute id =
    JE.array JE.bool >> JE.encode 0 >> JS.run id
