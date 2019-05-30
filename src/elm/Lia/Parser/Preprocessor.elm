module Lia.Parser.Preprocessor exposing (run)

import Combine
    exposing
        ( Parser
        , andMap
        , choice
        , fail
        , ignore
        , keep
        , many
        , map
        , regex
        , string
        , succeed
        , withColumn
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Parser.Helper exposing (newline)
import Lia.Parser.State exposing (State)
import Lia.Types exposing (SectionBase)


title_tag : Parser State Int
title_tag =
    regex "#+" |> map String.length


check : Int -> Parser s ()
check c =
    if c /= 0 then
        succeed ()

    else
        fail ""


title_str : Parser State Inlines
title_str =
    line |> ignore newline


body : Parser State String
body =
    [ regex "(?:[^#`<]+|[\\x0D\n]+|<!--[\\S\\s]*?-->)" -- comment
    , regex "(`{3,})[\\S\\s]*?\\1" -- code_block or ascii art
    , regex "`.+?`" -- code_block or ascii art
    , regex "(?:<((\\w+|-)+)[\\S\\s]*?</\\2>|`|<)"
    , withColumn check |> keep (string "#")
    ]
        |> choice
        |> many
        |> map String.concat


section : Parser State SectionBase
section =
    title_tag
        |> map SectionBase
        |> andMap title_str
        |> andMap body


run : Parser State (List SectionBase)
run =
    many section
