module Parser.Setext exposing (suite)

{-| Setext headers (a line underlined by `===` or `---`) whose first line is
parsed beyond its line break. The parser only tries a setext header if the
underline directly follows the first line, or if the first line contains
something that might span multiple lines. The expected results are recorded
from the parser before this shortcut (see `Parser.SetextSnapshots`).
-}

import Combine
import Dict
import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Markdown.Parser exposing (run)
import Lia.Parser.Context as Context
import Parser.SetextSnapshots exposing (snapshots)
import Test exposing (Test, describe, test)


parse : String -> String
parse str =
    case
        Combine.runParser run
            (List.foldl Macro.add (default "" "") [ ( "under", "\n===" ), ( "mm", "x" ) ] |> Context.init Nothing Nothing)
            str
    of
        Ok ( _, _, result ) ->
            Debug.toString result

        Err ( _, _, err ) ->
            "Err " ++ Debug.toString err


cases : List ( String, String )
cases =
    [ ( "plain", "Title\n===\n" )
    , ( "plain dashes", "Title\n---\n" )
    , ( "no underline", "Title\ntext\n" )
    , ( "underline after blank line", "Title\n\n===\n" )
    , ( "html", "a <b>b\nc</b>\n===\n" )
    , ( "comment", "a <!-- c\nd --> e\n===\n" )
    , ( "block formula", "a $$b\nc$$\n===\n" )
    , ( "quiz input", "a [[b\nc]]\n===\n" )
    , ( "quiz inputs", "[[ 2 ]] + [[ 5 ]] = [[ 7 ]]\n===\n" )
    , ( "quiz inputs, last open", "[[ 2 ]] + [[ 5\n]]\n===\n" )
    , ( "quiz inputs, first open", "[[ 2 + [[ 5\n]]\n===\n" )
    , ( "quiz inputs, closed before", "]] [[ 2\n]]\n===\n" )
    , ( "quiz inputs, nested", "[[ 2 [[ 5 ]] 7\n]]\n===\n" )
    , ( "drop input", "[->[ 2\n]]\n===\n" )
    , ( "drop input closed", "[->[ 2 ]] [[ 3 ]]\n===\n" )
    , ( "footnote", "a [^1](b\nc)\n===\n" )
    , ( "effect", "a {1}{b\nc}\n===\n" )
    , ( "effect definition", "a {\n1}{b}\n===\n" )
    , ( "line break", "a\\\nb\n===\n" )
    , ( "macro", "Title @under\n" )
    , ( "macro listing", "Title ```@mm\nbody\n```\n===\n" )
    , ( "last line", "Title" )
    ]


suite : Test
suite =
    cases
        |> List.map
            (\( name, input ) ->
                test name <|
                    \_ ->
                        case Dict.get name snapshots of
                            Just expected ->
                                Expect.equal expected (parse input)

                            Nothing ->
                                Expect.fail ("RECORD:" ++ parse input)
            )
        |> describe "setext headers"
