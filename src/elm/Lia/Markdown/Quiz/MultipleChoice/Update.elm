module Lia.Markdown.Quiz.MultipleChoice.Update exposing (Msg(..), toString, update)

import Array
import Lia.Markdown.Quiz.MultipleChoice.Types exposing (State)


type Msg
    = Toggle Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle id ->
            toggle id state


toggle : Int -> List Bool -> List Bool
toggle id state =
    case ( id, state ) of
        ( 0, x :: xs ) ->
            not x :: xs

        ( _, x :: xs ) ->
            x :: toggle (id - 1) xs

        ( _, [] ) ->
            state


toString : State -> String
toString state =
    state
        |> List.map
            (\s ->
                if s then
                    "1"

                else
                    "0"
            )
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
