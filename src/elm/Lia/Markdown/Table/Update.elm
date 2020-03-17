module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , update
    )

import Array exposing (Array)
import Lia.Markdown.Table.Types exposing (Class(..), State, Vector)


type Msg
    = Sort Int Int
    | Toggle Int


update : Msg -> Vector -> Vector
update msg vector =
    Maybe.withDefault vector <|
        case msg of
            Sort id col ->
                vector
                    |> Array.get id
                    |> Maybe.map (\state -> Array.set id (updateSort col state) vector)

            Toggle id ->
                vector
                    |> Array.get id
                    |> Maybe.map (\state -> Array.set id { state | diagram = not state.diagram } vector)



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
