module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Markdown.Table.Types exposing (Class(..), State, Vector)


type Msg sub
    = Sort Int Int
    | Toggle Int
    | NoOp


update : Msg sub -> Vector -> Vector
update msg vector =
    case msg of
        Sort id col ->
            vector
                |> Array.get id
                |> Maybe.map (\state -> Array.set id (updateSort col state) vector)
                |> Maybe.withDefault vector

        Toggle id ->
            vector
                |> Array.get id
                |> Maybe.map (\state -> Array.set id { state | diagram = not state.diagram } vector)
                |> Maybe.withDefault vector

        NoOp ->
            vector



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
