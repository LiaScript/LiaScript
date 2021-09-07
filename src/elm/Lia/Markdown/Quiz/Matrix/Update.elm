module Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..), toString, update)

import Array
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Quiz.Matrix.Types exposing (State)
import Lia.Markdown.Quiz.Vector.Update as Vector
import Return exposing (Return)


type Msg sub
    = Toggle Int Int
    | Script (Script.Msg sub)


update : Msg sub -> State -> Return State Never sub
update msg state =
    case msg of
        Toggle row_id column_id ->
            Return.value <|
                case
                    state
                        |> Array.get row_id
                        |> Maybe.map (Vector.toggle column_id)
                of
                    Just row ->
                        Array.set row_id row state

                    _ ->
                        state

        Script sub ->
            state
                |> Return.value
                |> Return.script sub


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map Vector.toString
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
