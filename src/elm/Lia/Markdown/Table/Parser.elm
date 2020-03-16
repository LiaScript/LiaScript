module Lia.Markdown.Table.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , lazy
        , many
        , many1
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , or
        , regex
        , sepBy1
        , sepEndBy
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Dict
import Lia.Markdown.Chart.Parser as Chart
import Lia.Markdown.Code.Parser as Code
import Lia.Markdown.Effect.Model exposing (set_annotation)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.HTML.Parser as HTML
import Lia.Markdown.Inline.Parser exposing (attribute, combine, comment, line)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, MultInlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Parser as Quiz
import Lia.Markdown.Survey.Parser as Survey
import Lia.Markdown.Table.Types exposing (Table(..))
import Lia.Parser.Context exposing (Context, indentation, indentation_append, indentation_pop, indentation_skip)
import Lia.Parser.Helper exposing (c_frame, debug, newline, newlines, spaces)


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
