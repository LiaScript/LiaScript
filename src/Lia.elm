module Lia
    exposing
        ( Block(..)
        , Inline(..)
        , Reference(..)
        , Slide
        , get_headers
        , get_slide
        , parse
        )

import Combine exposing (..)
import Combine.Char exposing (..)
import Combine.Num


type alias Slide =
    { indentation : Int
    , title : String
    , body : List Block
    }


type Block
    = HorizontalLine
    | CodeBlock String String
    | Quote (List Inline)
    | Paragraph (List Inline)
    | Table (List (List Inline)) (List (List (List Inline)))



--    | Bullet List Block


type Inline
    = Chars String
    | Symbol String
    | Bold Inline
    | Italic Inline
    | Underline Inline
    | Code String
    | Ref Reference


type Reference
    = Link String String
    | Image String String
    | Movie String String


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)


comments : Parser s ()
comments =
    let
        p =
            many (choice [ regex "[^-]*", regex "-[^}]+" ])
    in
    skip (many (string "{-" *> p <* string "-}"))


blocks : Parser s Block
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

                        --  , list
                        , paragraph
                        ]
            in
            skip comments *> b <* newlines



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
    (\l -> Paragraph <| List.concat l) <$> many (spaces *> line <* newline)


table : Parser s Block
table =
    let
        ending =
            string "|" <* (spaces <* newline)

        row =
            string "|" *> sepBy1 (string "|") (many1 inlines) <* ending

        header =
            string "|" *> sepBy1 (string "|") (many1 (regex "--[\\-]+")) <* ending

        simple_table =
            (\l -> Table [] l) <$> many1 row <* newline

        format_table =
            Table <$> (row <* header) <*> many row <* newline
    in
    choice [ format_table, simple_table ]


line : Parser s (List Inline)
line =
    many1 inlines


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
                        [ code_
                        , reference_
                        , strings_
                        ]
            in
            skip comments *> p


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
                [ string "<-->" $> Symbol "⟷"
                , string "<--" $> Symbol "⟵"
                , string "-->" $> Symbol "⟶"
                , string "<<-" $> Symbol "↞"
                , string "->>" $> Symbol "↠"
                , string "<->" $> Symbol "↔"
                , string ">->" $> Symbol "↣"
                , string "<-<" $> Symbol "↢"
                , string "->" $> Symbol "→"
                , string "<-" $> Symbol "←"
                , string "<~" $> Symbol "↜"
                , string "~>" $> Symbol "↝"
                , string "<==>" $> Symbol "⟺"
                , string "==>" $> Symbol "⟹"
                , string "<==" $> Symbol "⟸"
                , string "<=>" $> Symbol "⇔"
                , string "=>" $> Symbol "⇒"
                , string "<=" $> Symbol "⇐"
                ]


smileys_ : Parser s Inline
smileys_ =
    lazy <|
        \() ->
            choice
                [ string ":)" $> Symbol "😃"
                , string ";)" $> Symbol "😉"
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
                    Chars <$> regex "[^#*~_:;`!\\[\\|{\\\\\\n\\-<>=|]+" <?> "base string"

                escape =
                    Chars <$> (spaces *> string "\\" *> regex "[*_~`{\\\\\\|]") <?> "escape string"

                bold =
                    Bold <$> between_ "*" inlines <?> "bold string"

                italic =
                    Italic <$> between_ "~" inlines <?> "italic string"

                underline =
                    Underline <$> between_ "_" inlines <?> "underline string"

                characters =
                    Chars <$> regex "[*~_:;\\-<>=]"

                base2 =
                    Chars <$> regex "[^#\\n|]+" <?> "base string"
            in
            choice
                [ base
                , arrows_
                , smileys_
                , escape
                , bold
                , italic
                , underline
                , characters
                , base2
                ]


code_block : Parser s Block
code_block =
    let
        lang =
            string "```" *> spaces *> regex "([a-z,A-Z,0-9])*" <* spaces <* newline

        block =
            String.concat
                <$> many
                        (choice
                            [ regex "[^`]+"
                            , regex "`[^`]+"
                            , regex "``[^`]+"
                            ]
                        )
                <* string "```"
    in
    CodeBlock <$> lang <*> block



-- <$>


quote_block : Parser s Block
quote_block =
    let
        p =
            regex "^" *> string ">" *> line <* newline
    in
    (\q -> Quote <| List.concat q) <$> many1 p


code_ : Parser s Inline
code_ =
    Code <$> (string "`" *> regex "[^`]+" <* string "`") <?> "inline code"


program : Parser s (List Slide)
program =
    let
        tag =
            String.length <$> (newlines *> regex "#+" <* whitespace)

        title =
            String.trim <$> regex ".+" <* many1 newline

        body =
            many blocks
    in
    skip comments *> many (Slide <$> tag <*> title <*> body)


parse : String -> Result String (List Slide)
parse script =
    case Combine.parse program script of
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


get_headers : List Slide -> List ( Int, ( String, Int ) )
get_headers slides =
    slides
        |> List.map (\s -> ( s.title, s.indentation ))
        |> List.indexedMap (,)


get_slide : Int -> List Slide -> Maybe Slide
get_slide i slides =
    case ( i, slides ) of
        ( _, [] ) ->
            Nothing

        ( 0, x :: xs ) ->
            Just x

        ( n, _ :: xs ) ->
            get_slide (n - 1) xs
