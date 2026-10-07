module Parser.Shortcuts exposing (suite)

{-| The parser skips macros, annotations, scripts, and references early, if
the input cannot start with them (see `Lia.Parser.Helper.peek`). These cases
are right at the edges of these shortcuts.
-}

import Combine
import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Markdown.Macro.Parser as Macro
import Lia.Markdown.Parser exposing (run)
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Parser.Context as Context
import Parser.Block.Fixtures exposing (paragraph)
import Parser.Inline.Fixtures exposing (bold, chars, parse)
import Test exposing (Test, describe, test)


parseWithMacros : List ( String, String ) -> String -> Blocks
parseWithMacros macros str =
    case
        Combine.runParser run
            (List.foldl Macro.add (default "" "") macros |> Context.init Nothing Nothing)
            str
    of
        Ok ( _, _, result ) ->
            result

        Err _ ->
            []


suite : Test
suite =
    describe "parser shortcuts"
        [ test "a macro listing starts with a code block" <|
            \_ ->
                parseWithMacros [ ( "greet", "Hello @0!" ) ] "```js @greet\nWorld\n```\n"
                    |> Expect.equal [ paragraph "Hello World!" ]
        , test "a macro that results in block annotations" <|
            \_ ->
                parseWithMacros [ ( "red", "<!-- class=\"red\" -->" ) ] "  @red\nsome text\n"
                    |> Expect.equal [ Paragraph [ ( "class", "red" ) ] [ chars "some text" ] ]
        , test "inline annotations after spaces" <|
            \_ ->
                parse "**b**  <!-- class=\"x\" --> c"
                    |> Expect.equal [ Bold (chars "b") [ ( "class", "x" ) ], chars " c" ]
        , test "inline annotations after a tab" <|
            \_ ->
                parse "**b**\t<!-- class=\"x\" -->"
                    |> Expect.equal [ Bold (chars "b") [ ( "class", "x" ) ] ]
        , test "scripts are case insensitive" <|
            \_ ->
                parse "a <SCRIPT>1+1</SCRIPT>"
                    |> Expect.equal [ chars "a ", Script 0 [] ]
        , test "no annotations, no macros" <|
            \_ ->
                parse "**b** <!- c -> @ ` [x] ! ?"
                    |> Expect.equal [ bold "b", chars " <!- c ", Symbol "→" [], chars " @ ` [x] ! ?" ]
        ]
