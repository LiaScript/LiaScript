module Lia.Markdown.Quiz.Vector.Update exposing (Msg(..), toString, toggle, update)

import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))


type Msg sub
    = Toggle Int
    | Script (Script.Msg sub)


update : Msg sub -> State -> ( State, Maybe (Script.Msg sub) )
update msg state =
    case msg of
        Toggle id ->
            ( toggle id state, Nothing )

        Script sub ->
            ( state, Just sub )


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
toggleSingle id list =
    case list of
        [] ->
            []

        _ :: xs ->
            (id == 0) :: toggleSingle (id - 1) xs


toggleMultiple : Int -> List Bool -> List Bool
toggleMultiple id list =
    case list of
        [] ->
            []

        x :: xs ->
            (if id == 0 then
                not x

             else
                x
            )
                :: toggleMultiple (id - 1) xs


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
