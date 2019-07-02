module Lia.Markdown.Quiz.MultipleChoiceMatrix.Update exposing (Msg(..), toString, update)

import Array exposing (Array)
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Types exposing (State)


type Msg
    = Toggle Int Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle row column ->
            toggle row column state


toggle : Int -> Int -> State -> State
toggle row column state =
    case Array.get row state of
        Just rslt ->
            case Array.get column rslt of
                Just bool ->
                    Array.set row (Array.set column (not bool) rslt) state

                _ ->
                    state

        _ ->
            state


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map stringify_
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")


stringify_ : Array Bool -> String
stringify_ a =
    a
        |> Array.map
            (\s ->
                if s then
                    "1"

                else
                    "0"
            )
        |> Array.toList
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
