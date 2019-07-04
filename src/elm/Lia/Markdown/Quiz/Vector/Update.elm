module Lia.Markdown.Quiz.Vector.Update exposing (Msg(..), toString, toggle, update)

import Array
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))


type Msg
    = Toggle Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle id ->
            toggle id state


toggle : Int -> State -> State
toggle id state =
    case state of
        SingleChoice length _ ->
            SingleChoice length id

        MultipleChoice vector ->
            case Array.get id vector of
                Just value ->
                    Array.set id (not value) vector
                        |> MultipleChoice

                Nothing ->
                    state


toString : State -> String
toString state =
    case state of
        SingleChoice _ value ->
            String.fromInt value

        MultipleChoice values ->
            values
                |> Array.toList
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
