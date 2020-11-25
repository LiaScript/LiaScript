module Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..), toString, update)

import Array
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Quiz.Matrix.Types exposing (State)
import Lia.Markdown.Quiz.Vector.Update as Vector


type Msg sub
    = Toggle Int Int
    | Script (Script.Msg sub)


update : Msg sub -> State -> ( State, Maybe (Script.Msg sub) )
update msg state =
    case msg of
        Toggle row_id column_id ->
            case
                state
                    |> Array.get row_id
                    |> Maybe.map (Vector.toggle column_id)
            of
                Just row ->
                    ( Array.set row_id row state, Nothing )

                _ ->
                    ( state, Nothing )

        Script sub ->
            ( state, Just sub )


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map Vector.toString
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")
