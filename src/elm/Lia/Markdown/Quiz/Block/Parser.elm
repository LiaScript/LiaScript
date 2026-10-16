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
        , many1Till
        , map
        , or
        , string
        , succeed
        , withState
        )
import Combine.Char exposing (anyChar)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)


{-| A block quiz on its own line: a text input `[[solution]]`, a selection
`[[ wrong | (right) ]]` or a drop `[->[ wrong | (right) ]]`. `parse_inlines`
parses the options.
-}
parse : (Context -> String -> opt) -> Parser Context (Quiz opt)
parse parse_inlines =
    spaces
        |> keep (pattern parse_inlines)
        |> ignore newline
        |> map Tuple.second


{-| An input within a line, also used by gap-texts. The `Int` is the length of
its content, which defines the width of the input field.
-}
pattern : (Context -> String -> opt) -> Parser Context ( Int, Quiz opt )
pattern parse_inlines =
    or
        (brackets "[[" (split parse_inlines))
        (brackets "[->[" (splitDrop parse_inlines))


{-| **private:** Pass the content between `begin` and `]]` to `fn`. The length
counts capitals as 1.5 characters, since they are wider than the average (`ch`).
-}
brackets : String -> (String -> Context -> Parser Context (Quiz opt)) -> Parser Context ( Int, Quiz opt )
brackets begin fn =
    string begin
        |> keep (string1Till (string "]]"))
        |> andThen
            (\s ->
                withState (fn s)
                    |> map (Tuple.pair (String.length s + String.length (String.filter Char.isUpper s) // 2))
            )


{-| **private:** At least one character up to `end`, `\\]` is unescaped.
-}
string1Till : Parser s p -> Parser s String
string1Till =
    many1Till
        (or
            (string "\\]" |> keep (succeed ']'))
            anyChar
        )
        >> map String.fromList


{-| **private:** Split the options at every `|` that is not escaped. Without a
regex lookbehind, old browsers (Gecko 48, KaiOS) do not support it.
-}
splitAtUnescapedPipe : String -> List String
splitAtUnescapedPipe =
    String.split "|"
        >> List.foldl
            (\part parts ->
                case parts of
                    previous :: rest ->
                        if String.endsWith "\\" previous then
                            (previous ++ "|" ++ part) :: rest

                        else
                            part :: parts

                    [] ->
                        [ part ]
            )
            []
        >> List.reverse
        >> List.map (String.replace "\\|" "|")


unescapeString : String -> String
unescapeString input =
    input
        |> String.replace "\\|" "|"
        |> String.replace "\\(" "("
        |> String.replace "\\)" ")"
        |> String.replace "\\[" "["
        |> String.replace "\\]" "]"
        |> String.replace "\\@" "@"


{-| **private:** A single option is a text input with this solution (`?`, `!`
and empty are reserved for other constructs), multiple options are a selection.
-}
split : (Context -> String -> opt) -> String -> Context -> Parser Context (Quiz opt)
split parse_inlines str state =
    case splitAtUnescapedPipe str of
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
                    |> unescapeString
                    |> Text
                    |> Quiz []
                    |> succeed

        options ->
            options
                |> List.indexedMap (check parse_inlines state)
                |> toQuiz (Select False)


{-| **private:** The options of a drop, a single option is always correct.
-}
splitDrop : (Context -> String -> opt) -> String -> Context -> Parser Context (Quiz opt)
splitDrop parse_inlines str state =
    (case splitAtUnescapedPipe str of
        [ solution ] ->
            let
                option =
                    String.trim solution
            in
            [ if String.startsWith "(" option && String.endsWith ")" option then
                option

              else
                "(" ++ option ++ ")"
            ]

        options ->
            options
    )
        |> List.indexedMap (check parse_inlines state)
        |> toQuiz (Drop False False)


{-| **private:** Parse an option, correct options `(...)` keep their `id`,
wrong ones get `-1`.
-}
check : (Context -> String -> opt) -> Context -> Int -> String -> ( Int, opt )
check parse_inlines state id str =
    let
        inlines =
            parse_inlines state

        option =
            str
                |> String.trim
    in
    if String.startsWith "(" option && String.endsWith ")" option then
        ( id
        , option
            |> String.slice 1 -1
            |> String.trim
            |> unescapeString
            |> inlines
        )

    else
        ( -1
        , option
            |> unescapeString
            |> inlines
        )


{-| **private:** The `state` holds the ids of all correct options.
-}
toQuiz : (List Int -> State) -> List ( Int, opt ) -> Parser Context (Quiz opt)
toQuiz state list =
    list
        |> List.map Tuple.first
        |> List.filter ((<=) 0)
        |> state
        |> Quiz (List.map Tuple.second list)
        |> succeed
