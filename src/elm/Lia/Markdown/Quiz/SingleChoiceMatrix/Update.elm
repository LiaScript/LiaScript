module Lia.Markdown.Quiz.SingleChoiceMatrix.Update exposing (Msg(..), toString, update)

import Array exposing (Array)
import Lia.Markdown.Quiz.SingleChoiceMatrix.Types exposing (State)


type Msg
    = Toggle Int Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle row value ->
            Array.set row value state


toString : State -> String
toString state =
    state
        |> Array.map String.fromInt
        |> Array.toList
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
