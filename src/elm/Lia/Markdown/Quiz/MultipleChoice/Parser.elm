module Lia.Markdown.Quiz.MultipleChoice.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , ignore
        , keep
        , many1
        , map
        , or
        , string
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.MultipleChoice.Types exposing (Quiz)
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)


parse : Parser Context Quiz
parse =
    spaces
        |> keep (or checked unchecked)
        |> many1
        |> map unzip


checked : Parser Context ( Bool, Inlines )
checked =
    string "[[X]]"
        |> keep line
        |> ignore newline
        |> map (Tuple.pair True)


unchecked : Parser Context ( Bool, Inlines )
unchecked =
    string "[[ ]]"
        |> keep line
        |> ignore newline
        |> map (Tuple.pair False)


unzip : List ( Bool, Inlines ) -> Quiz
unzip list =
    let
        ( bools, options ) =
            List.unzip list
    in
    Quiz options bools
