module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Helper.Array as Array
import Lia.Markdown.Table.Types exposing (State, Vector)
import Return exposing (Return)
import Service.Event exposing (Event)


type Msg sub
    = Sort Int Int
    | Toggle Int
    | Handle Event
    | NoOp


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle


update : Msg sub -> Vector -> Return Vector msg sub
update msg vector =
    Return.val <|
        case msg of
            Sort id column ->
                Array.update id (updateSort column) vector

            Toggle id ->
                Array.update id (\state -> { state | diagram = not state.diagram }) vector

            _ ->
                vector


{-| Clicking a column header cycles through ascending, descending and
unsorted.
-}
updateSort : Int -> State -> State
updateSort column state =
    if state.column /= column then
        { state | column = column, dir = True }

    else if state.dir then
        { state | dir = False }

    else
        { state | column = -1 }
