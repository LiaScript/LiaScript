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
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (newline, spaces)


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
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 options)
        |> ignore (string "]")
        |> ignore newline


options : Parser Context Inlines
options =
    or inParenthesis inBrackets


inParenthesis : Parser Context Inlines
inParenthesis =
    regex "[ \\t]*\\([ \\t]*"
        |> keep (manyTill inlines (regex "[ \\t]*\\)[ \\t]*"))


inBrackets : Parser Context Inlines
inBrackets =
    regex "[ \\t]*\\[[ \\t]*"
        |> keep (manyTill inlines (regex "[ \\t]*\\][ \\t]*"))


single : Parser Context State
single =
    spaces
        |> keep Vector.single
        |> ignore spaces
        |> many1
        |> map SingleChoice


multiple : Parser Context State
multiple =
    spaces
        |> keep Vector.multiple
        |> ignore spaces
        |> many1
        |> map MultipleChoice


rows : Parser Context ( List State, List Inlines )
rows =
    or single multiple
        |> Vector.choices
