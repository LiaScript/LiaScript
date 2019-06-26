module Lia.Markdown.Quiz.SingleChoice.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andMap
        , ignore
        , keep
        , many
        , map
        , string
        , succeed
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.SingleChoice.Types exposing (Quiz)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.State exposing (State)


parse : Parser State Quiz
parse =
    map toQuiz unchecked
        |> andMap checked
        |> andMap unchecked


toQuiz : List Inlines -> Inlines -> List Inlines -> Quiz
toQuiz wrong1 right wrong2 =
    Quiz
        (right :: wrong2 |> List.append wrong1)
        (List.length wrong1)


checked : Parser State Inlines
checked =
    string "[(X)]"
        |> keep line
        |> ignore newline


unchecked : Parser State (List Inlines)
unchecked =
    string "[( )]"
        |> keep line
        |> ignore newline
        |> many
