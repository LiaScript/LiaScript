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
        , map
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces, string1Till)


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


split : (Context -> String -> opt) -> String -> Context -> Parser Context (Quiz opt)
split parse_inlines str state =
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
                    |> String.trim
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


toSelect : List ( Int, opt ) -> Parser Context (Quiz opt)
toSelect list =
    list
        |> List.filter (Tuple.first >> (<=) 0)
        |> List.map Tuple.first
        |> Select False
        |> Quiz (List.map Tuple.second list)
        |> succeed
