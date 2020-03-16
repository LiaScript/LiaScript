module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , update
    )

import Array exposing (Array)
import Lia.Markdown.Table.Types exposing (Vector)


type Msg
    = Sort Int Int


update : Msg -> Vector -> Vector
update msg vector =
    case msg of
        Sort table_id column_id ->
            updateSort vector table_id column_id


updateSort : Array ( Int, Bool ) -> Int -> Int -> Array ( Int, Bool )
updateSort tables table_id column_id =
    case Array.get table_id tables of
        Just ( col, True ) ->
            if col == column_id then
                Array.set table_id ( column_id, False ) tables

            else
                Array.set table_id ( column_id, True ) tables

        Just ( col, False ) ->
            if col == column_id then
                Array.set table_id ( -1, False ) tables

            else
                Array.set table_id ( column_id, True ) tables

        _ ->
            Array.set table_id ( column_id, True ) tables
