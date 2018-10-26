module Lia.Preprocessor exposing (run)

import Combine exposing (..)
import Lia.Helper exposing (..)
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.PState exposing (PState)


title_tag : Parser PState Int
title_tag =
    String.length <$> regex "#+" <?> "title tags"


check : Int -> Parser s ()
check c =
    if c /= 0 then
        succeed ()

    else
        fail "Not the beginning"


title_str : Parser PState Inlines
title_str =
    spaces *> line <* newlines1


comment : Parser PState String
comment =
    regex "<!--(.|[\\x0D\\n])*?-->" <?> "comment"


misc : Parser PState String
misc =
    regex "([^\\\\#`<\\[]|[\\x0D\\n])+" <|> (withColumn check *> string "#")


misc2 : Parser PState String
misc2 =
    regex "((\\\\.)|[<`\\[])"


link : Parser PState String
link =
    regex "\\[[^\\]]*\\]\\([^\\)]*\\)"


code_block : Parser PState String
code_block =
    regex "```[`]*(.|[\\x0D\\n])*?```[`]*" <?> "code block"


code_inline : Parser PState String
code_inline =
    regex "`.*?`" <?> "inline code"


html_block : Parser PState String
html_block =
    let
        p tag =
            (\c ->
                String.append ("<" ++ tag) c
                    ++ "</"
                    ++ tag
                    ++ ">"
            )
                <$> stringTill (string "</" *> string tag <* string ">")
    in
    whitespace *> string "<" *> regex "\\w+" >>= p


body : Parser PState String
body =
    [ misc
    , link
    , comment
    , code_block
    , code_inline
    , html_block
    , misc2
    ]
        |> choice
        |> many
        |> map String.concat


section : Parser PState ( Int, Inlines, String )
section =
    (,,) <$> title_tag <*> title_str <*> body


run : Parser PState (List ( Int, Inlines, String ))
run =
    many section
