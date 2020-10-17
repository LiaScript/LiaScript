module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Table.Types exposing (Class(..), State, Vector)


type Msg
    = Sort Int Int
    | Toggle Int
    | Script Script.Msg
    | NoOp


update : Msg -> Vector -> ( Vector, Maybe Script.Msg )
update msg vector =
    case msg of
        Sort id col ->
            vector
                |> Array.get id
                |> Maybe.map (\state -> Array.set id (updateSort col state) vector)
                |> Maybe.withDefault vector
                |> Script.none

        Toggle id ->
            vector
                |> Array.get id
                |> Maybe.map (\state -> Array.set id { state | diagram = not state.diagram } vector)
                |> Maybe.withDefault vector
                |> Script.none

        Script sub ->
            ( vector, Just sub )

        NoOp ->
            Script.none vector



--case Array.get id vector of
--  Just (col, dir, )


updateSort : Int -> State -> State
updateSort column state =
    if state.column /= column then
        { state | column = column, dir = True }

    else if state.dir then
        { state | dir = False }

    else
        { state | column = -1 }
