module Lia.Markdown.Table.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , choice
        , ignore
        , keep
        , many
        , many1
        , manyTill
        , map
        , modifyState
        , onsuccess
        , or
        , regex
        , sepEndBy
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, MultInlines)
import Lia.Markdown.Table.Types exposing (Cell, Class(..), Row, State, Table(..))
import Lia.Parser.Context exposing (Context, indentation, indentation_skip)


parse : Parser Context Table
parse =
    indentation_skip
        |> keep (or formated simple)
        |> modify_State
        |> map classify


classify : Table -> Table
classify table =
    table


cell : Inlines -> Cell
cell data =
    let
        str =
            stringify data
    in
    str
        |> String.split " "
        |> List.head
        |> Maybe.andThen String.toFloat
        |> Cell data str


row : Parser Context Row
row =
    indentation
        |> keep
            (manyTill
                (string "|" |> keep line |> map cell)
                (regex "\\|[\t ]*\\n")
            )


simple : Parser Context (Int -> Table)
simple =
    row
        |> many1
        |> map (Unformatted None)


formated : Parser Context (Int -> Table)
formated =
    row
        |> map (List.map .inlines >> Formatted None)
        |> andMap format
        |> andMap (many row)


format : Parser Context (List String)
format =
    indentation
        |> ignore (string "|")
        |> keep
            (sepEndBy (string "|")
                (choice
                    [ regex "[\t ]*:-{3,}:[\t ]*" |> onsuccess "center"
                    , regex "[\t ]*:-{3,}[\t ]*" |> onsuccess "left"
                    , regex "[\t ]*-{3,}:[\t ]*" |> onsuccess "right"
                    , regex "[\t ]*-{3,}[\t ]*" |> onsuccess "left"
                    ]
                )
            )
        |> ignore (regex "[\t ]*\\n")


modify_State : Parser Context (Int -> Table) -> Parser Context Table
modify_State =
    andMap (withState (.table_vector >> Array.length >> succeed))
        >> ignore
            (modifyState
                (\s ->
                    { s
                        | table_vector = Array.push (State -1 False False) s.table_vector
                    }
                )
            )
