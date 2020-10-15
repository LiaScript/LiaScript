module Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..), toString, update)

import Array
import Lia.Markdown.Effect.JavaScript as JS
import Lia.Markdown.Quiz.Matrix.Types exposing (State)
import Lia.Markdown.Quiz.Vector.Update as Vector


type Msg
    = Toggle Int Int
    | Script JS.Msg


update : Msg -> State -> ( State, Maybe JS.Msg )
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
