module Lia.Preprocessor exposing (run)

import Combine exposing (..)


title_tag : Parser s Int
title_tag =
    String.length <$> regex "#+" <?> "title tags"


title_str : Parser s String
title_str =
    String.trim <$> regex ".+" <?> "section title"


comment : Parser s String
comment =
    regex "<!--(.|[\x0D\n])*?-->" <?> "comment"


misc : Parser s String
misc =
    regex "([^\\\\#`<]|[\x0D\n])+"


misc2 : Parser s String
misc2 =
    regex "((\\\\.)|[<`])"


code_block : Parser s String
code_block =
    regex "```(.|[\x0D\n])*?```" <?> "code block"


code_inline : Parser s String
code_inline =
    regex "`.*?`" <?> "inline code"


body : Parser s String
body =
    lazy <|
        \() ->
            [ misc
            , comment
            , code_block
            , code_inline
            , misc2
            ]
                |> choice
                |> many
                |> map String.concat


section : Parser s ( Int, String, String )
section =
    (\i s b -> ( i, s, b )) <$> title_tag <*> title_str <*> body


run : Parser s (List ( Int, String, String ))
run =
    many section
