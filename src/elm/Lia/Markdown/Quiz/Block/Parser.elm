module Lia.Markdown.Quiz.Block.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andThen
        , fail
        , ignore
        , keep
        , map
        , regex
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, stringTill)


parse : Parser Context Quiz
parse =
    regex "[\t ]*\\[\\["
        |> keep (stringTill (string "]]"))
        |> ignore newline
        |> map split
        |> andThen withState


split : String -> Context -> Parser Context Quiz
split str state =
    case String.split "|" str of
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
                    |> Text
                    |> Quiz []
                    |> succeed

        options ->
            options
                |> List.indexedMap (check state)
                |> toSelect


check : Context -> Int -> String -> ( Int, Inlines )
check state id str =
    let
        inlines =
            parse_inlines state

        option =
            String.trim str
    in
    if String.startsWith "(" option && String.endsWith ")" option then
        ( id
        , option
            |> String.slice 1 -1
            |> String.trim
            |> inlines
        )

    else
        ( -1, inlines option )


toSelect : List ( Int, Inlines ) -> Parser Context Quiz
toSelect list =
    list
        |> List.filter (Tuple.first >> (<=) 0)
        |> List.map Tuple.first
        |> Select False
        |> Quiz (List.map Tuple.second list)
        |> succeed
