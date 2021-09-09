module Lia.Markdown.Quiz.Vector.Update exposing
    ( Msg(..)
    , toString
    , toggle
    , update
    )

import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Return exposing (Return)


type Msg sub
    = Toggle Int
    | Script (Script.Msg sub)


update : Msg sub -> State -> Return State msg sub
update msg state =
    case msg of
        Toggle id ->
            state
                |> toggle id
                |> Return.value

        Script sub ->
            state
                |> Return.value
                |> Return.script sub


toggle : Int -> State -> State
toggle id state =
    case state of
        SingleChoice list ->
            list
                |> toggleSingle id
                |> SingleChoice

        MultipleChoice list ->
            list
                |> toggleMultiple id
                |> MultipleChoice


toggleSingle : Int -> List Bool -> List Bool
toggleSingle id =
    List.indexedMap (\i _ -> i == id)


toggleMultiple : Int -> List Bool -> List Bool
toggleMultiple id =
    List.indexedMap
        (\i b ->
            if i == id then
                not b

            else
                b
        )


toString : State -> String
toString state =
    case state of
        SingleChoice list ->
            list
                |> List.indexedMap Tuple.pair
                |> List.filter Tuple.second
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault -1
                |> String.fromInt

        MultipleChoice values ->
            values
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
