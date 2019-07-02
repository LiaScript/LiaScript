module Lia.Markdown.Quiz.MultipleChoiceMatrix.Parser exposing (parse)

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
        , onsuccess
        , or
        , regex
        , string
        )
import Lia.Markdown.Inline.Parser exposing (inlines, line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Types exposing (Quiz)
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (newline, spaces)


parse : Parser Context Quiz
parse =
    map quiz header
        |> andMap (many1 row)


quiz : List Inlines -> List ( List Bool, Inlines ) -> Quiz
quiz main body =
    let
        ( rows, opt ) =
            List.unzip body
    in
    rows
        |> List.map Array.fromList
        |> Array.fromList
        |> Quiz main opt


header : Parser Context (List Inlines)
header =
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (options inlines))
        |> ignore (string "]")
        |> ignore newline


options : Parser Context x -> Parser Context (List x)
options p =
    regex "[ \\t]*\\[[ \\t]*"
        |> keep (manyTill p (regex "[ \\t]*\\][ \\t]*"))


row : Parser Context ( List Bool, Inlines )
row =
    maybe indentation
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (or unchecked checked))
        |> ignore (string "]")
        |> map Tuple.pair
        |> andMap line
        |> ignore newline


checked : Parser Context Bool
checked =
    spaces
        |> keep (string "[X]")
        |> ignore spaces
        |> onsuccess True


unchecked : Parser Context Bool
unchecked =
    spaces
        |> keep (string "[ ]")
        |> ignore spaces
        |> onsuccess False
