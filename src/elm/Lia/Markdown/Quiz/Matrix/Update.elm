module Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..), toString, update)

import Array exposing (Array)
import Lia.Markdown.Quiz.Matrix.Types exposing (State)
import Lia.Markdown.Quiz.Vector.Update as Vector


type Msg
    = Toggle Int Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle row_id column_id ->
            case
                state
                    |> Array.get row_id
                    |> Maybe.map (Vector.toggle column_id)
            of
                Just row ->
                    Array.set row_id row state

                _ ->
                    state


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map Vector.toString
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
