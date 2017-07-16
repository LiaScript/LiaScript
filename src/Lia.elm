module Lia
    exposing
        ( E(..)
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
    , body : List E
    }


type E
    = Base String
    | Code String
    | CodeBlock String String
    | Bold E
    | Unicode String
    | Italic E
    | Underline E
    | Link String String
    | Image String String
    | Movie String String
    | Paragraph (List E)
    | Quote (List E)
    | Line
    | EList (List (List E))


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


tag : Parser s Int
tag =
    String.length <$> (newlines *> regex "#+" <* whitespace)


title : Parser s String
title =
    String.trim <$> regex ".+" <* many1 newline


body : Parser s (List E)
body =
    many blocks


blocks : Parser s E
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ code
                        , quote
                        , horizontal_line
                        , list
                        , paragraph
                        ]
            in
            skip comments *> b <* newlines



--<* newlines


list : Parser s E
list =
    let
        p1 =
            string "* " *> line <* newline

        p2 =
            string "  " *> line <* newline
    in
    EList
        <$> many1
                (p1
                    |> map (::)
                    |> andMap (many p2)
                    |> map List.concat
                )


horizontal_line : Parser s E
horizontal_line =
    Line <$ regex "--[\\-]+"


paragraph : Parser s E
paragraph =
    (\l -> Paragraph <| List.concat l) <$> many (spaces *> line <* newline)


line : Parser s (List E)
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
    regex "[ |\t]*"


inlines : Parser s E
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


reference_ : Parser s E
reference_ =
    lazy <|
        \() ->
            let
                info =
                    brackets (regex "[^\\]|\n]*")

                url =
                    parens (regex "[^\\)|\n]*")

                link =
                    Link <$> info <*> url

                image =
                    Image <$> (string "!" *> info) <*> url

                movie =
                    Movie <$> (string "!!" *> info) <*> url
            in
            choice [ movie, image, link ]


arrows_ : Parser s E
arrows_ =
    lazy <|
        \() ->
            choice
                [ string "<-->" $> Unicode "⟷"
                , string "<--" $> Unicode "⟵"
                , string "-->" $> Unicode "⟶"
                , string "<<-" $> Unicode "↞"
                , string "->>" $> Unicode "↠"
                , string "<->" $> Unicode "↔"
                , string ">->" $> Unicode "↣"
                , string "<-<" $> Unicode "↢"
                , string "->" $> Unicode "→"
                , string "<-" $> Unicode "←"
                , string "<~" $> Unicode "↜"
                , string "~>" $> Unicode "↝"
                , string "<==>" $> Unicode "⟺"
                , string "==>" $> Unicode "⟹"
                , string "<==" $> Unicode "⟸"
                , string "<=>" $> Unicode "⇔"
                , string "=>" $> Unicode "⇒"
                , string "<=" $> Unicode "⇐"
                ]


smileys : Parser s E
smileys =
    lazy <|
        \() ->
            choice
                [ string ":)" $> Unicode "😃" --"☺"
                , string ";)" $> Unicode "😉"

                --, string "B)" $> Unicode "😎"
                ]


between_ : String -> Parser s E -> Parser s E
between_ str p =
    spaces *> string str *> p <* string str


strings_ : Parser s E
strings_ =
    lazy <|
        \() ->
            let
                base =
                    Base <$> regex "[^#|*|~|_|:|;|`|!|\\[|{|\\\\|\n|\\-|<|>|=]+" <?> "base string"

                escape =
                    Base <$> (spaces *> string "\\" *> regex "[*_~`{\\\\]") <?> "escape string"

                bold =
                    Bold <$> between_ "*" inlines <?> "bold string"

                italic =
                    Italic <$> between_ "~" inlines <?> "italic string"

                underline =
                    Underline <$> between_ "_" inlines <?> "underline string"

                characters =
                    Base <$> regex "[*|~|_|:|;|\\-|<|>|=]"

                base2 =
                    Base <$> regex "[^#|\n]+" <?> "base string"
            in
            choice
                [ base
                , arrows_
                , smileys
                , escape
                , bold
                , italic
                , underline
                , characters
                , base2
                ]


code : Parser s E
code =
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


quote : Parser s E
quote =
    let
        p =
            regex "^" *> string ">" *> line <* newline
    in
    (\q -> Quote <| List.concat q) <$> many1 p


code_ : Parser s E
code_ =
    Code <$> (string "`" *> regex "[^`]+" <* string "`") <?> "inline code"


program : Parser s (List Slide)
program =
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
