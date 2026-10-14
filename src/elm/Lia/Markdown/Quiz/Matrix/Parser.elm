module Lia.Markdown.Quiz.Matrix.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , ignore
        , keep
        , many1
        , manyTill
        , map
        , maybe
        , or
        , regex
        , string
        )
import Lia.Markdown.Inline.Parser exposing (inlines)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Matrix.Types exposing (Quiz)
import Lia.Markdown.Quiz.Vector.Parser exposing (checkButton, group, radioButton)
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


{-| A matrix quiz starts with a header of column titles in brackets or
parentheses, followed by rows of radio buttons or check boxes:

    [ [ a ] b [ c ] ]

    [ X () () ] row 1

    [ () X () ] row 2

-}
parse : Parser Context Quiz
parse =
    header
        |> map quiz
        |> andMap rows


quiz : List Inlines -> ( List State, List Inlines ) -> Quiz
quiz main ( vector, inline ) =
    vector
        |> Array.fromList
        |> Quiz main inline


header : Parser Context (List Inlines)
header =
    maybe Indent.check
        |> ignore spaces
        |> ignore (regex "(?:(\\-|\\+|\\*)[\t ]*)?\\[")
        |> keep (many1 options)
        |> ignore (string "]")
        |> ignore newline


{-| **private:** A column title.
-}
options : Parser Context Inlines
options =
    or inParenthesis inBrackets


inParenthesis : Parser Context Inlines
inParenthesis =
    regex "[ \t]*\\([ \t]*"
        |> keep (manyTill inlines (regex "[ \t]*\\)[ \t]*"))


inBrackets : Parser Context Inlines
inBrackets =
    regex "[ \t]*\\[[ \t]*"
        |> keep (manyTill inlines (regex "[ \t]*\\][ \t]*"))


{-| **private:** Every row is either a single or a multiple choice, followed
by its text.
-}
rows : Parser Context ( List State, List Inlines )
rows =
    or (choices radioButton SingleChoice) (choices checkButton MultipleChoice)
        |> group


choices : Parser Context Bool -> (List Bool -> State) -> Parser Context State
choices button state =
    spaces
        |> keep button
        |> ignore spaces
        |> many1
        |> map state
