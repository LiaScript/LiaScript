module Lia.Markdown.Task.Update exposing (Msg(..), handle, update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Task.Json as Json
import Lia.Markdown.Task.Types exposing (Vector)
import Port.Eval as Eval
import Port.Event as Event exposing (Event)


type Msg sub
    = Toggle Int Int (Maybe String)
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> ( Vector, List Event, Maybe (Script.Msg sub) )
update scripts msg vector =
    case msg of
        Toggle id1 id2 Nothing ->
            ( vector
                |> Array.get id1
                |> Maybe.map (\state -> Array.set id1 (toggle id2 state) vector)
                |> Maybe.withDefault vector
            , []
            , Nothing
            )
                |> store

        Toggle id1 id2 (Just code) ->
            case
                vector
                    |> Array.get id1
                    |> Maybe.map (toggle id2)
            of
                Just state ->
                    ( Array.set id1 state vector
                    , [ [ state
                            |> JE.array JE.bool
                            |> JE.encode 0
                        ]
                            |> Eval.event id1 code (outputs scripts)
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
                "restore" ->
                    ( event.message
                        |> Json.toVector
                        |> Result.withDefault vector
                    , []
                    , Nothing
                    )

                _ ->
                    ( vector, [], Nothing )


toggle : Int -> Array Bool -> Array Bool
toggle id states =
    Array.set id
        (states
            |> Array.get id
            |> Maybe.map not
            |> Maybe.withDefault False
        )
        states


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


handle : Event -> Msg sub
handle =
    Handle
