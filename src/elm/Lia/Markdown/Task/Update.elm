module Lia.Markdown.Task.Update exposing (Msg(..), handle, update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Vector)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)


{-| Interaction associated to LiaScript task list:

  - `Toggle x y js`: toogle on boolean value, depending on the `x` and `y`
    coordinates. If set, the js code is executed after every toggle event.
  - `Handle`: event communication via ports
  - `Script`: mandatory to enable `Effect.Script` events to be executed in every
    module

-}
type Msg sub
    = Toggle Int Int (Maybe String)
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> ( Vector, List Event, Maybe (Script.Msg sub) )
update scripts msg vector =
    case msg of
        -- simple toggle
        Toggle x y Nothing ->
            ( vector
                |> Array.get x
                |> Maybe.map (\state -> Array.set x (toggle y state) vector)
                |> Maybe.withDefault vector
            , []
            , Nothing
            )
                |> store

        -- toggle and execute the code snippet
        Toggle x y (Just code) ->
            case
                vector
                    |> Array.get x
                    |> Maybe.map (toggle y)
            of
                Just state ->
                    ( Array.set x state vector
                    , [ [ state
                            |> JE.array JE.bool
                            |> JE.encode 0
                        ]
                            |> Eval.event x code (outputs scripts)
                      ]
                    , Nothing
                    )
                        |> store

                Nothing ->
                    ( vector, [], Nothing )

        Script childMsg ->
            ( vector, [], Just childMsg )

        Handle event ->
            case event.topic of
                -- currently it is only possible to restore states from the backend
                "restore" ->
                    ( event.message
                        |> Json.toVector
                        |> Result.withDefault vector
                    , []
                    , Nothing
                    )

                -- eval events are not handled at the moment
                _ ->
                    ( vector, [], Nothing )


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
store : ( Vector, List Event, Maybe (Script.Msg sub) ) -> ( Vector, List Event, Maybe (Script.Msg sub) )
store ( vector, events, sub ) =
    ( vector
    , (vector
        |> Json.fromVector
        |> Event.store
      )
        :: events
    , sub
    )


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle
