module Lia.Markdown.Quiz.Multi.Update exposing (..)

import Array
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Multi.Types exposing (State)
import Return exposing (Return)


type Msg sub
    = Script (Script.Msg sub)
    | Block_Update Int (Block.Msg sub)


update : Msg sub -> State -> Return State msg sub
update msg state =
    case msg of
        Block_Update id childMsg ->
            case
                Array.get id state
                    |> Maybe.map (Block.update childMsg)
            of
                Just ret ->
                    ret
                        |> Return.mapVal (\s -> Array.set id s state)

                _ ->
                    state
                        |> Return.val

        Script sub ->
            state
                |> Return.val
                |> Return.script sub


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map Block.toString
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
