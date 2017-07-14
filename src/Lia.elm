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
    | Italic E
    | Underline E
    | Link String String
    | Image String String
    | Movie String String
    | Paragraph (List E)
    | Quote (List E)


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)


comment : Parser s String
comment =
    regex "//[^\n]*"


tag : Parser s Int
tag =
    String.length <$> (regex "#+" <* whitespace)


slide : Parser s Slide
slide =
    Slide <$> tag <*> title <*> body


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
                        , paragraph
                        ]
            in
            b <* many newline


paragraph : Parser s E
paragraph =
    (\lines -> Paragraph <| List.concat lines) <$> many (spaces *> line <* newline)


line : Parser s (List E)
line =
    many1 inlines


newline : Parser s String
newline =
    string "\n"


spaces : Parser s String
spaces =
    regex "[ |\t]*"


inlines : Parser s E
inlines =
    lazy <|
        \() ->
            choice
                [ code_
                , reference_
                , strings_
                ]


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


strings_ : Parser s E
strings_ =
    lazy <|
        \() ->
            let
                base =
                    Base <$> regex "[^#|*|~|_|`|!|\\[|\n]+" <?> "base string"

                bold =
                    Bold <$> (string "*" *> inlines <* string "*") <?> "bold string"

                italic =
                    Italic <$> (string "~" *> inlines <* string "~") <?> "italic string"

                underline =
                    Underline <$> (string "_" *> inlines <* string "_") <?> "underline string"

                base2 =
                    Base <$> regex "[^#|\n]+" <?> "base string"
            in
            choice [ base, bold, italic, underline, base2 ]


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


slides : Parser s Slide
slides =
    lazy <|
        \() ->
            slide


program : Parser s (List Slide)
program =
    many slides


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
