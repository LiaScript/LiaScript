module Lia.Preprocessor exposing (run)

import Combine exposing (..)
import Lia.Markdown.Inline.Parser exposing (line, stringTill)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.PState exposing (PState)


title_tag : Parser PState Int
title_tag =
    String.length <$> regex "^#+" <?> "title tags"


title_str : Parser PState Inlines
title_str =
    regex "[ \\t]*" *> line <* regex "[\x0D\n]+"


comment : Parser PState String
comment =
    regex "<!--(.|[\x0D\n])*?-->" <?> "comment"


misc : Parser PState String
misc =
    regex "([^\\\\#`<\\[]|[\x0D\n])+"


misc2 : Parser PState String
misc2 =
    regex "((\\\\.)|[<`\\[])"


link : Parser PState String
link =
    regex "\\[[^\\]]*\\]\\([^\\)]*\\)"


code_block : Parser PState String
code_block =
    regex "```(.|[\x0D\n])*?```" <?> "code block"


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
    whitespace *> string "<" *> regex "[a-zA-Z0-9]+" >>= p


body : Parser PState String
body =
    lazy <|
        \() ->
            [ misc
            , link
            , comment
            , html_block
            , code_block
            , code_inline
            , misc2
            ]
                |> choice
                |> many
                |> map String.concat


section : Parser PState ( Int, Inlines, String )
section =
    (\i s b -> ( i, s, b )) <$> title_tag <*> title_str <*> body


run : Parser PState (List ( Int, Inlines, String ))
run =
    many section
