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
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces, stringTill)



--parse : Parser Context (Quiz Inlines)


parse parse_inlines =
    spaces
        |> keep (pattern parse_inlines)
        |> ignore newline


pattern parse_inlines =
    string "[["
        |> keep (stringTill (string "]]"))
        |> map (split parse_inlines)
        |> andThen withState



--split : String -> Context -> Parser Context (Quiz Inlines)


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
                    |> Text
                    |> Quiz []
                    |> succeed

        options ->
            options
                |> List.indexedMap (check parse_inlines state)
                |> toSelect



--check : Context -> Int -> String -> ( Int, opt )


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


toSelect : List ( Int, Inlines ) -> Parser Context (Quiz Inlines)
toSelect list =
    list
        |> List.filter (Tuple.first >> (<=) 0)
        |> List.map Tuple.first
        |> Select False
        |> Quiz (List.map Tuple.second list)
        |> succeed
