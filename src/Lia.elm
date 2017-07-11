module Lia exposing (Lia(..), parse)

import Combine exposing (..)
import Combine.Char exposing (..)
import Combine.Num


type alias Section =
    { title : String
    , body : Body
    }


type alias Body =
    String


type Lia
    = LiaTitle String
    | LiaText String


comment : Parser s String
comment =
    regex "//[^\n]*"


tag : Parser s String
tag =
    regex "#+ "


title : Parser s Lia
title =
    LiaTitle <$> (tag *> regex "[^\n]+")


text : Parser s Lia
text =
    LiaText <$> regex "[^\n]+"


stmt : Parser s Lia
stmt =
    lazy <|
        \() ->
            let
                parsers =
                    [ title, text ]
            in
            whitespace *> choice parsers <* whitespace


program : Parser s (List Lia)
program =
    many stmt


parse : String -> Result String (List Lia)
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
