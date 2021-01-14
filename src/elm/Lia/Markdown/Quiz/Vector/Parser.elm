module Lia.Markdown.Quiz.Vector.Parser exposing
    ( checkButton
    , group
    , parse
    , radioButton
    )

import Combine
    exposing
        ( Parser
        , andMap
        , ignore
        , keep
        , many1
        , map
        , maybe
        , onsuccess
        , or
        , regex
        , string
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (newline, spaces)


parse : Parser Context Quiz
parse =
    or
        (radioButton
            |> group
            |> map (toQuiz SingleChoice)
        )
        (checkButton
            |> group
            |> map (toQuiz MultipleChoice)
        )


radioButton : Parser Context Bool
radioButton =
    elements "\\([xX]\\)" "( )"


checkButton : Parser Context Bool
checkButton =
    elements "\\[[xX]\\]" "[ ]"


group : Parser Context a -> Parser Context ( List a, List Inlines )
group parser =
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep parser
        |> map Tuple.pair
        |> ignore (string "]")
        |> andMap line
        |> ignore newline
        |> many1
        |> map List.unzip


elements : String -> String -> Parser Context Bool
elements true false =
    or
        (string false |> onsuccess False)
        (regex true |> onsuccess True)


toQuiz : (List Bool -> State) -> ( List Bool, List Inlines ) -> Quiz
toQuiz fn ( bools, inlines ) =
    fn bools
        |> Quiz inlines
