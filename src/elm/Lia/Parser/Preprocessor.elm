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
    [ regex "(?:[^`<#]+|[\\x0D\n]+)" -- misc
    , regex "<!--[\\s\\S]*?-->" -- comment
    , regex "`{3,}[\\s\\S]*?`{3,}" -- code_block or ascii art
    , regex "<((\\w+|-)+)[\\s\\S]*?</\\1>" -- html block
    , string "`"
    , string "<"
    , withColumn check |> keep (string "#")
    ]
        |> choice
        |> many
        |> map String.concat


section : Parser State ( Int, Inlines, String )
section =
    title_tag
        |> map (\a b c -> ( a, b, c ))
        |> andMap title_str
        |> andMap body


run : Parser State (List ( Int, Inlines, String ))
run =
    many section
