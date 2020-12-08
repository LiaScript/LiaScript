module Lia.Parser.Preprocessor exposing (section)

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
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces1)
import Lia.Section as Section


title_tag : Parser Context Int
title_tag =
    regex "#+"
        |> map String.length
        |> ignore spaces1


check : Int -> Parser s ()
check c =
    if c == 0 then
        fail ""

    else
        succeed ()


title_str : Parser Context Inlines
title_str =
    line |> ignore newline


body : Parser Context String
body =
    [ regex "(?:[^#`<]+|[\\x0D\n]+|<!--[\\S\\s]{0,1000}?-->)" -- comment
    , regex "(`{3,})[\\S\\s]*?\\1" -- code_block or ascii art
    , regex "`.+?`" -- code_block or ascii art
    , regex "(?:<([\\w+\\-]+)[\\S\\s]*?</\\2>|`|<)"
    , regex "#+(\\w|[^\\u0000-\\u007F]|[ \t]*\n)"
    , withColumn check |> keep (string "#")
    ]
        |> choice
        |> many
        |> map String.concat


section : Parser Context Section.Base
section =
    title_tag
        |> map Section.Base
        |> andMap title_str
        |> andMap body
