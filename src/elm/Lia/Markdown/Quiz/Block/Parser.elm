module Lia.Markdown.Quiz.Block.Parser exposing
    ( parse
    , pattern
    )

import Combine
    exposing
        ( Parser
        , andThen
        , fail
        , ignore
        , keep
        , many1Till
        , map
        , or
        , string
        , succeed
        , withState
        )
import Combine.Char exposing (anyChar)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Regex


parse : (Context -> String -> opt) -> Parser Context (Quiz opt)
parse parse_inlines =
    spaces
        |> keep (pattern parse_inlines)
        |> ignore newline
        |> map Tuple.second


pattern : (Context -> String -> opt) -> Parser Context ( Int, Quiz opt )
pattern parse_inlines =
    string "[["
        |> keep (string1Till (string "]]"))
        |> map
            (\s context ->
                split parse_inlines s context
                    |> map (Tuple.pair (String.length s))
            )
        |> andThen withState


string1Till : Parser s p -> Parser s String
string1Till =
    many1Till
        (or
            (string "\\]" |> keep (succeed ']'))
            anyChar
        )
        >> map String.fromList


splitAtUnescapedPipe : String -> List String
splitAtUnescapedPipe input =
    let
        -- This regex matches a pipe that's not preceded by a backslash
        regex =
            Maybe.withDefault Regex.never <|
                Regex.fromString "(?<!\\\\)\\|"
    in
    input
        |> Regex.split regex
        |> List.map (String.replace "\\|" "|")


unescapeString : String -> String
unescapeString input =
    input
        |> String.replace "\\|" "|"
        |> String.replace "\\(" "("
        |> String.replace "\\)" ")"
        |> String.replace "\\[" "["
        |> String.replace "\\]" "]"
        |> String.replace "\\@" "@"


split : (Context -> String -> opt) -> String -> Context -> Parser Context (Quiz opt)
split parse_inlines str state =
    case splitAtUnescapedPipe str of
        [ solution ] ->
            let
                str_ =
                    solution
                        |> String.replace "_" " "
                        |> String.trim
            in
            if str_ == "?" || str_ == "!" || str_ == "" then
                fail ""

            else
                solution
                    |> String.trim
                    |> unescapeString
                    |> Text
                    |> Quiz []
                    |> succeed

        options ->
            options
                |> List.indexedMap (check parse_inlines state)
                |> toSelect


check : (Context -> String -> opt) -> Context -> Int -> String -> ( Int, opt )
check parse_inlines state id str =
    let
        inlines =
            parse_inlines state

        option =
            str
                |> String.trim
    in
    if String.startsWith "(" option && String.endsWith ")" option then
        ( id
        , option
            |> String.slice 1 -1
            |> String.trim
            |> unescapeString
            |> inlines
        )

    else
        ( -1
        , option
            |> unescapeString
            |> inlines
        )


toSelect : List ( Int, opt ) -> Parser Context (Quiz opt)
toSelect list =
    list
        |> List.filter (Tuple.first >> (<=) 0)
        |> List.map Tuple.first
        |> Select False
        |> Quiz (List.map Tuple.second list)
        |> succeed
