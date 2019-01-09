module Lia.Preprocessor exposing (run)

import Combine exposing (..)
import Lia.Helper exposing (..)
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.PState exposing (PState)


title_tag : Parser PState Int
title_tag =
    regex "#+" |> map String.length


check : Int -> Parser s ()
check c =
    if c /= 0 then
        succeed ()

    else
        fail ""


title_str : Parser PState Inlines
title_str =
    line |> ignore newline


body : Parser PState String
body =
    [ regex "(?:[^`<#]+|[\\x0D\n]+)" -- misc
    , regex "<!--[\\s\\S]*?-->" -- comment
    , regex "`{3,}[\\s\\S]*?`{3,}" -- code_block or ascii art
    , regex "<(\\w+)[\\s\\S]*?</\\1>" -- html block
    , string "`"
    , string "<"
    , withColumn check |> keep (string "#")
    ]
        |> choice
        |> many
        |> map String.concat


section : Parser PState ( Int, Inlines, String )
section =
    title_tag
        |> map (,,)
        |> andMap title_str
        |> andMap body


run : Parser PState (List ( Int, Inlines, String ))
run =
    many section
