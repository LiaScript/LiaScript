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
import Lia.Markdown.Inline.Types exposing (Inline(..), MultInlines)
import Lia.Markdown.Table.Types exposing (Table(..))
import Lia.Parser.Context exposing (Context, indentation, indentation_skip)


parse : Parser Context Table
parse =
    indentation_skip
        |> keep (or formated_table simple_table)


table_row : Parser Context MultInlines
table_row =
    indentation
        |> keep
            (manyTill
                (string "|" |> keep line)
                (regex "\\|[\t ]*\\n")
            )


simple_table : Parser Context Table
simple_table =
    table_row
        |> many1
        |> map Unformatted
        |> modify_StateTable


formated_table : Parser Context Table
formated_table =
    table_row
        |> map Formatted
        |> andMap format
        |> andMap (many table_row)
        |> modify_StateTable


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


modify_StateTable : Parser Context (Int -> Table) -> Parser Context Table
modify_StateTable =
    andMap (withState (.table_vector >> Array.length >> succeed))
        >> ignore (modifyState (\s -> { s | table_vector = Array.push ( -1, False ) s.table_vector }))
