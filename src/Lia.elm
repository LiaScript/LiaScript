module Lia
    exposing
        ( LiaString(..)
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
    , body : List LiaString
    }


type LiaString
    = Base String
    | Bold String
    | Italic String


comment : Parser s String
comment =
    regex "//[^\n]*"


tag : Parser s Int
tag =
    (\h -> String.length h - 2) <$> regex "#+ "


slide : Parser s Slide
slide =
    Slide <$> tag <*> title <*> body


title : Parser s String
title =
    regex "[^\n]+"


body : Parser s (List LiaString)
body =
    many element


element : Parser s LiaString
element =
    Base <$> regex "[^#]+"


stmt : Parser s Slide
stmt =
    lazy <|
        \() ->
            slide


program : Parser s (List Slide)
program =
    many stmt


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


get_headers : List Slide -> List ( Int, String )
get_headers slides =
    slides
        |> List.map (\s -> s.title)
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
