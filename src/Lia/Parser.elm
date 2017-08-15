module Lia.Parser exposing (run)

--import Combine.Num

import Combine exposing (..)
import Combine.Char exposing (..)
import Lia.Type exposing (..)


type alias PState =
    { quiz : Int
    , section : List Int
    , indentation : List Int
    }


init_pstate : PState
init_pstate =
    PState 0 [] [ 0 ]


comments : Parser s ()
comments =
    skip (many (string "{-" *> manyTill anyChar (string "-}")))


blocks : Parser PState Block
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ table
                        , code_block
                        , quote_block
                        , horizontal_line
                        , quiz

                        --  , list
                        , paragraph
                        ]
            in
            comments *> b <* newlines


quiz : Parser PState Block
quiz =
    let
        counter =
            let
                pp par =
                    succeed par.quiz

                increment_counter c =
                    { c | quiz = c.quiz + 1 }
            in
            withState pp <* modifyState increment_counter
    in
    Quiz <$> multiple_choice <*> counter


multiple_choice : Parser s Quiz
multiple_choice =
    let
        unchecked =
            (\l -> ( False, l )) <$> (string "[ ]" *> line <* newline)

        checked =
            (\l -> ( True, l )) <$> (string "[X]" *> line <* newline)
    in
    MultipleChoice <$> many1 (choice [ checked, unchecked ])


html : Parser s Inline
html =
    html_void <|> html_block


html_void : Parser s Inline
html_void =
    lazy <|
        \() ->
            HTML
                <$> choice
                        [ regex "<area[^>]*>"
                        , regex "<base[^>]*>"
                        , regex "<br[^>]*>"
                        , regex "<col[^>]*>"
                        , regex "<embed[^>]*>"
                        , regex "<hr[^>]*>"
                        , regex "<img[^>]*>"
                        , regex "<input[^>]*>"
                        , regex "<keygen[^>]*>"
                        , regex "<link[^>]*>"
                        , regex "<menuitem[^>]*>"
                        , regex "<meta[^>]*>"
                        , regex "<param[^>]*>"
                        , regex "<source[^>]*>"
                        , regex "<track[^>]*>"
                        , regex "<wbr[^>]*>"
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
    HTML <$> (whitespace *> string "<" *> regex "[a-z]+" >>= p)



--<* newlines
-- list : Parser s E
-- list =
--     let
--         p1 =
--             string "* " *> line <* newline
--
--         p2 =
--             string "  " *> line <* newline
--     in
--     EList
--         <$> many1
--                 (p1
--                     |> map (::)
--                     |> andMap (many p2)
--                     |> map List.concat
--                 )


horizontal_line : Parser s Block
horizontal_line =
    HorizontalLine <$ regex "--[\\-]+"


paragraph : Parser s Block
paragraph =
    (\l -> Paragraph <| combine <| List.concat l) <$> many (spaces *> line <* newline)


table : Parser s Block
table =
    let
        ending =
            string "|" <* (spaces <* newline)

        row =
            string "|" *> sepBy1 (string "|") (many1 inlines) <* ending

        format =
            string "|"
                *> sepBy1 (string "|")
                    (choice
                        [ regex ":--[\\-]+:" $> "center"
                        , regex ":--[\\-]+" $> "left"
                        , regex "--[\\-]+:" $> "right"
                        , regex "--[\\-]+" $> "left"
                        ]
                    )
                <* ending

        simple_table =
            Table [] [] <$> many1 row <* newline

        format_table =
            Table <$> row <*> format <*> many row <* newline
    in
    choice [ format_table, simple_table ]


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
    (\list -> combine <| List.append list [ Chars "\n" ]) <$> many1 inlines


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
                        , code_
                        , reference_
                        , formula_
                        , strings_
                        ]
            in
            comments *> p


formula_ : Parser s Inline
formula_ =
    let
        p1 =
            Formula False <$> (string "$" *> regex "[^\\n$]+" <* string "$")

        p2 =
            (\c -> Formula True <| String.fromList c) <$> (string "$$" *> manyTill anyChar (string "$$"))
    in
    choice [ p2, p1 ]


reference_ : Parser s Inline
reference_ =
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


arrows_ : Parser s Inline
arrows_ =
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


smileys_ : Parser s Inline
smileys_ =
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


strings_ : Parser s Inline
strings_ =
    lazy <|
        \() ->
            let
                base =
                    Chars <$> regex "[^#*~_:;`!\\^\\[\\|{\\\\\\n\\-<>=|$]+" <?> "base string"

                escape =
                    Chars <$> (spaces *> string "\\" *> regex "[\\^#*_~`{\\\\\\|$]") <?> "escape string"

                bold =
                    Bold <$> between_ "*" inlines <?> "bold string"

                italic =
                    Italic <$> between_ "~" inlines <?> "italic string"

                underline =
                    Underline <$> between_ "_" inlines <?> "underline string"

                superscript =
                    Superscript <$> between_ "^" inlines <?> "superscript string"

                characters =
                    Chars <$> regex "[*~_:;\\-<>=$]"

                base2 =
                    Chars <$> regex "[^#\\n|]+" <?> "base string"
            in
            choice
                [ base
                , html
                , arrows_
                , smileys_
                , escape
                , bold
                , italic
                , underline
                , superscript
                , characters
                , base2
                ]


code_block : Parser s Block
code_block =
    let
        lang =
            string "```" *> spaces *> regex "([a-z,A-Z,0-9])*" <* spaces <* newline

        block =
            String.fromList <$> manyTill anyChar (string "```")
    in
    CodeBlock <$> lang <*> block


quote_block : Parser s Block
quote_block =
    let
        p =
            regex "^" *> string ">" *> optional [ Chars "" ] line <* newline
    in
    (\q -> Quote <| combine <| List.concat q) <$> many1 p


code_ : Parser s Inline
code_ =
    Code <$> (string "`" *> regex "[^`]+" <* string "`") <?> "inline code"


parse : Parser PState (List Slide)
parse =
    let
        tag =
            String.length <$> (newlines *> regex "#+" <* whitespace)

        title =
            String.trim <$> regex ".+" <* many1 newline

        body =
            many blocks
    in
    comments *> many1 (Slide <$> tag <*> title <*> body)


run : String -> Result String (List Slide)
run script =
    case Combine.runParser parse init_pstate script of
        Ok ( _, _, es ) ->
            Ok es

        Err ( _, stream, ms ) ->
            Err <| formatError ms stream


formatError : List String -> InputStream -> String
formatError ms stream =
    let
        location =
            currentLocation stream

        separator =
            "|> "

        expectationSeparator =
            "\n  * "

        lineNumberOffset =
            floor (logBase 10 (toFloat location.line)) + 1

        separatorOffset =
            String.length separator

        padding =
            location.column + separatorOffset + 2
    in
    "Parse error around line:\n\n"
        ++ toString location.line
        ++ separator
        ++ location.source
        ++ "\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\nI expected one of the following:\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator ms
