module Parser.Block.Macro exposing
    ( inlineUsage_Suite
    , parameterized_Suite
    , simple_Suite
    , undefined_Suite
    )

{-| Macro substitution (`@name`, `@name(param, ...)`), as described in the
docs' "Macros" section. A macro is defined by adding an entry to the
`Definition`'s `macro` dict (normally populated by parsing `<!-- name: body
-->` lines in the document header - see `Lia.Markdown.Macro.Parser.add`,
which we call directly here to set up each case) and then referenced with a
leading `@` anywhere text is parsed; the reference is textually replaced by
the macro's body before the surrounding block/inline syntax is parsed.
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
import Parser.Inline.Fixtures exposing (bold)
import Test exposing (Test, describe, test)


{-| Parse `str` with one or more macro definitions already loaded into the
document's `Definition`, as if they'd been declared in the header comment.
-}
parseWithMacros : List ( String, String ) -> String -> Blocks
parseWithMacros macros str =
    let
        state =
            List.foldl Macro.add (default "" "") macros
                |> Context.init Nothing Nothing
    in
    case Combine.runParser run state str of
        Ok ( _, _, result ) ->
            result

        Err _ ->
            []


simple_Suite : Test
simple_Suite =
    describe "a parameter-less macro is substituted by its body before further parsing"
        [ test "@hello expands to its defined body, which is then parsed as markdown" <|
            \_ ->
                parseWithMacros [ ( "hello", "**world**" ) ] "@hello\n"
                    |> Expect.equal [ Paragraph [] [ bold "world" ] ]
        , test "plain text macros expand to plain text" <|
            \_ ->
                parseWithMacros [ ( "greeting", "Hi there" ) ] "@greeting\n"
                    |> Expect.equal [ paragraph "Hi there" ]
        ]


parameterized_Suite : Test
parameterized_Suite =
    describe "a macro's parameters (@0, @1, ...) are substituted positionally"
        [ test "a single parameter is substituted into the body" <|
            \_ ->
                parseWithMacros [ ( "greet", "Hello @0!" ) ] "@greet(World)\n"
                    |> Expect.equal [ paragraph "Hello World!" ]
        , test "multiple parameters are substituted by index" <|
            \_ ->
                parseWithMacros [ ( "combine", "@0 and @1" ) ] "@combine(foo,bar)\n"
                    |> Expect.equal [ paragraph "foo and bar" ]
        ]


inlineUsage_Suite : Test
inlineUsage_Suite =
    describe "a macro reference is expanded no matter where it occurs in the text"
        [ test "a macro used mid-sentence is expanded in place" <|
            \_ ->
                parseWithMacros [ ( "name", "LiaScript" ) ] "Hello @name, welcome!\n"
                    |> Expect.equal [ paragraph "Hello LiaScript, welcome!" ]
        ]


undefined_Suite : Test
undefined_Suite =
    describe "an undefined macro reference is left untouched, as literal text"
        [ test "@doesNotExist isn't replaced when no such macro is defined" <|
            \_ ->
                parseWithMacros [] "@doesNotExist\n"
                    |> Expect.equal [ paragraph "@doesNotExist" ]
        ]
