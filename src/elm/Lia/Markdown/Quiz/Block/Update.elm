module Lia.Markdown.Quiz.Block.Update exposing
    ( Msg(..)
    , toString
    , update
    )

import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Process
import Return exposing (Return)
import Task


type Msg sub
    = Toggle
    | Choose Int
    | Input String
    | Script (Script.Msg sub)
    | DropStart
    | DropData Int
    | DropEnter Bool
    | DropExit
    | DropTarget
    | DropSource Int
    | None


update : Msg sub -> State -> Return State (Msg sub) sub
update msg state =
    case ( msg, state ) of
        ( Choose option, Select _ _ ) ->
            Select True [ option ]
                |> Return.val

        ( Toggle, Select open id ) ->
            Select (not open) id
                |> Return.val

        ( Input str, Text _ ) ->
            Text str
                |> Return.val

        ( Script sub, _ ) ->
            state
                |> Return.val
                |> Return.script sub

        ( DropStart, Drop allowed _ value ) ->
            Drop allowed True value
                |> Return.val

        ( DropData id, Drop highlight _ value ) ->
            Return.val <|
                if highlight then
                    Drop False False [ id ]

                else if not highlight && [ id ] == value then
                    Drop False False []

                else
                    Drop highlight False value

        ( DropEnter True, Drop _ active value ) ->
            Drop True active value
                |> Return.val

        ( DropEnter False, _ ) ->
            state
                |> Return.val
                |> Return.cmd
                    (Process.sleep 1
                        |> Task.attempt (always DropExit)
                    )

        ( DropExit, Drop _ active value ) ->
            Drop False active value
                |> Return.val

        ( DropTarget, Drop highlight _ _ ) ->
            Drop highlight False []
                |> Return.val

        ( DropSource id, Drop _ _ _ ) ->
            Drop False False [ id ]
                |> Return.val

        _ ->
            state
                |> Return.val


toString : Bool -> State -> String
toString withQuotes state =
    case state of
        Text str ->
            if withQuotes then
                "\"" ++ str ++ "\""

            else
                str

        Select _ [ i ] ->
            String.fromInt i

        Drop _ _ [ i ] ->
            String.fromInt i

        _ ->
            "-1"
