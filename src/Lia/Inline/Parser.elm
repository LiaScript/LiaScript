module Lia.Inline.Parser
    exposing
        ( combine
        , comments
        , inlines
        , line
        , newline
        , newlines
        , spaces
        )

import Combine exposing (..)
import Combine.Char exposing (..)
import Lia.Inline.Type exposing (..)


comments : Parser s ()
comments =
    skip (many (string "<!--" *> manyTill anyChar (string "-->")))


html : Parser s Inline
html =
    html_void <|> html_block


html_void : Parser s Inline
html_void =
    lazy <|
        \() ->
            HTML
                <$> choice
                        [ regex "<area[^>\\n]*>"
                        , regex "<base[^>\\n]*>"
                        , regex "<br[^>\\n]*>"
                        , regex "<col[^>\\n]*>"
                        , regex "<embed[^>\\n]*>"
                        , regex "<hr[^>\\n]*>"
                        , regex "<img[^>\\n]*>"
                        , regex "<input[^>\\n]*>"
                        , regex "<keygen[^>\\n]*>"
                        , regex "<link[^>\\n]*>"
                        , regex "<menuitem[^>\\n]*>"
                        , regex "<meta[^>\\n]*>"
                        , regex "<param[^>\\n]*>"
                        , regex "<source[^>\\n]*>"
                        , regex "<track[^>\\n]*>"
                        , regex "<wbr[^>\\n]*>"
                        ]


html_block : Parser s Inline
html_block =
    let
        p tag =
            (\c ->
                (c
                    |> String.fromList
                    |> String.append ("<" ++ tag)
                )
                    ++ "</"
                    ++ tag
                    ++ ">"
            )
                <$> manyTill anyChar (string "</" *> string tag <* string ">")
    in
    HTML <$> (whitespace *> string "<" *> regex "[a-zA-Z]+" >>= p)


combine : List Inline -> List Inline
combine list =
    case list of
        [] ->
            []

        [ xs ] ->
            [ xs ]

        x1 :: x2 :: xs ->
            case ( x1, x2 ) of
                ( Chars str1, Chars str2 ) ->
                    combine (Chars (str1 ++ str2) :: xs)

                _ ->
                    x1 :: combine (x2 :: xs)


line : Parser s (List Inline)
line =
    (\list -> combine <| List.append list [ Chars " " ]) <$> many1 inlines


newline : Parser s ()
newline =
    skip (char '\n' <|> eol)


newlines : Parser s ()
newlines =
    skip (many newline)


spaces : Parser s String
spaces =
    regex "[ \t]*"


inlines : Parser s Inline
inlines =
    lazy <|
        \() ->
            let
                p =
                    choice
                        [ html
                        , code
                        , reference
                        , formula
                        , strings
                        ]
            in
            comments *> p


formula : Parser s Inline
formula =
    let
        p1 =
            Formula False <$> (string "$" *> regex "[^\\n$]+" <* string "$")

        p2 =
            (\c -> Formula True <| String.fromList c) <$> (string "$$" *> manyTill anyChar (string "$$"))
    in
    choice [ p2, p1 ]


reference : Parser s Inline
reference =
    lazy <|
        \() ->
            let
                info =
                    brackets (regex "[^\\]\n]*")

                url =
                    parens (regex "[^\\)\n]*")

                link =
                    Link <$> info <*> url

                image =
                    Image <$> (string "!" *> info) <*> url

                movie =
                    Movie <$> (string "!!" *> info) <*> url
            in
            Ref <$> choice [ movie, image, link ]


arrows : Parser s Inline
arrows =
    lazy <|
        \() ->
            choice
                [ string "<-->" $> Symbol "&#10231;" --"⟷"
                , string "<--" $> Symbol "&#10229;" --"⟵"
                , string "-->" $> Symbol "&#10230;" --"⟶"
                , string "<<-" $> Symbol "&#8606;" --"↞"
                , string "->>" $> Symbol "&#8608;" --"↠"
                , string "<->" $> Symbol "&#8596;" --"↔"
                , string ">->" $> Symbol "&#8611;" --"↣"
                , string "<-<" $> Symbol "&#8610;" --"↢"
                , string "->" $> Symbol "&#8594;" --"→"
                , string "<-" $> Symbol "&#8592;" --"←"
                , string "<~" $> Symbol "&#8604;" --"↜"
                , string "~>" $> Symbol "&#8605;" --"↝"
                , string "<==>" $> Symbol "&#10234;" --"⟺"
                , string "==>" $> Symbol "&#10233;" --"⟹"
                , string "<==" $> Symbol "&#10232;" --"⟸"
                , string "<=>" $> Symbol "&#8660;" --"⇔"
                , string "=>" $> Symbol "&#8658;" --"⇒"
                , string "<=" $> Symbol "&#8656;" --"⇐"
                ]


smileys : Parser s Inline
smileys =
    lazy <|
        \() ->
            choice
                [ string ":-)" $> Symbol "&#x1f600;" --"🙂"
                , string ";-)" $> Symbol "&#x1f609;" --"😉"
                , string ":-D" $> Symbol "&#x1f600;" --"😀"
                , string ":-O" $> Symbol "&#128558;" --"😮"
                , string ":-(" $> Symbol "&#128542;" --"🙁"
                , string ":-|" $> Symbol "&#128528;" --"😐"
                , string ":-/" $> Symbol "&#128533;" --"😕"
                , string ":-P" $> Symbol "&#128539;" --"😛"
                , string ";-P" $> Symbol "&#128540;" --"😜"
                , string ":-*" $> Symbol "&#128535;" --"😗"
                , string ":')" $> Symbol "&#128514;" --"😂"
                , string ":'(" $> Symbol "&#128554;" --"😢"😪
                ]


between_ : String -> Parser s e -> Parser s e
between_ str p =
    spaces *> string str *> p <* string str


strings : Parser s Inline
strings =
    lazy <|
        \() ->
            let
                base =
                    Chars <$> regex "[^#*~_:;`!\\^\\[\\|{}\\\\\\n\\-<>=|$]+" <?> "base string"

                escape =
                    Chars <$> (spaces *> string "\\" *> regex "[\\^#*_~`\\\\\\|$]") <?> "escape string"

                bold =
                    Bold <$> between_ "*" inlines <?> "bold string"

                italic =
                    Italic <$> between_ "~" inlines <?> "italic string"

                underline =
                    Underline <$> between_ "_" inlines <?> "underline string"

                superscript =
                    Superscript <$> between_ "^" inlines <?> "superscript string"

                characters =
                    Chars <$> regex "[*~_:;\\-<>=${}]"

                base2 =
                    Chars <$> regex "[^#\\n|]+" <?> "base string"
            in
            choice
                [ base
                , html
                , arrows
                , smileys
                , escape
                , bold
                , italic
                , underline
                , superscript
                , characters
                , base2
                ]


code : Parser s Inline
code =
    Code <$> (string "`" *> regex "[^`]+" <* string "`") <?> "inline code"
