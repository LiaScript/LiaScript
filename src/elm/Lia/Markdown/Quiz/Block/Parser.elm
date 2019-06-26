module Lia.Markdown.Quiz.Block.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andThen
        , fail
        , ignore
        , keep
        , many1
        , map
        , or
        , regex
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Helper exposing (newline, stringTill)
import Lia.Parser.State exposing (State)


parse : Parser State Quiz
parse =
    regex "[\t ]*\\[\\["
        |> keep (stringTill (string "]]"))
        |> ignore newline
        |> map split
        |> andThen withState


split : String -> State -> Parser State Quiz
split str state =
    case String.split "|" str of
        [ solution ] ->
            solution
                |> Text
                |> Quiz []
                |> succeed

        options ->
            options
                |> List.indexedMap (check state)
                |> toSelect


check : State -> Int -> String -> ( Int, Inlines )
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


toSelect : List ( Int, Inlines ) -> Parser State Quiz
toSelect list =
    case
        list
            |> List.filter (Tuple.first >> (<=) 0)
            |> List.head
            |> Maybe.map Tuple.first
    of
        Just id ->
            Select False id
                |> Quiz (List.map Tuple.second list)
                |> succeed

        Nothing ->
            fail "no solution provided"
