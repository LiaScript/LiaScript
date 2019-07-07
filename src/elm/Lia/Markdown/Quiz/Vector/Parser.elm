module Lia.Markdown.Quiz.Vector.Parser exposing
    ( choices
    , multiple
    , parse
    , single
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
        (single
            |> choices
            |> map (toQuiz SingleChoice)
        )
        (multiple
            |> choices
            |> map (toQuiz MultipleChoice)
        )


single : Parser Context Bool
single =
    elements "(X)" "( )"


multiple : Parser Context Bool
multiple =
    elements "[X]" "[ ]"


choices : Parser Context a -> Parser Context ( List a, List Inlines )
choices parser =
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
        (string true |> onsuccess True)
        (string false |> onsuccess False)


toQuiz : (List Bool -> State) -> ( List Bool, List Inlines ) -> Quiz
toQuiz fn ( bools, inlines ) =
    fn bools
        |> Quiz inlines
