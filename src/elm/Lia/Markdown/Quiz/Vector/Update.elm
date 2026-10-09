module Lia.Markdown.Quiz.Vector.Update exposing
    ( Msg(..)
    , toString
    , toggle
    , update
    )

import Json.Encode as JE
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import List.Extra


{-| Click on the option with the given index.
-}
type Msg
    = Toggle Int


{-| -}
update : Msg -> State -> State
update (Toggle id) =
    toggle id


{-| Toggle the option `id`. A single choice allows only one selected option,
selecting it again clears the selection.
-}
toggle : Int -> State -> State
toggle id state =
    case state of
        SingleChoice list ->
            list
                |> List.indexedMap (\i value -> i == id && not value)
                |> SingleChoice

        MultipleChoice list ->
            list
                |> List.indexedMap
                    (\i value ->
                        if i == id then
                            not value

                        else
                            value
                    )
                |> MultipleChoice


{-| The input as passed to a checking script: the index of the selected option
(`-1` if none) or a list of `0` and `1`.
-}
toString : State -> String
toString state =
    case state of
        SingleChoice list ->
            list
                |> List.Extra.findIndex identity
                |> Maybe.withDefault -1
                |> String.fromInt

        MultipleChoice values ->
            values
                |> List.map
                    (\s ->
                        if s then
                            1

                        else
                            0
                    )
                |> JE.list JE.int
                |> JE.encode 0
