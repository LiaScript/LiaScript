module Parser.Block.Macro exposing
    ( expansion_Suite
    , inlineUsage_Suite
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


{-| Expand the macros at the start of `str` and return the resulting input,
with `indentation` as the current block indentation.
-}
expand : List ( String, String ) -> List String -> String -> String
expand macros indentation str =
    let
        state =
            List.foldl Macro.add (default "https://example.com/course/" "") macros
                |> (\def -> { def | section = 2 })
                |> Context.init Nothing Nothing
    in
    case Combine.runParser (Macro.macro |> Combine.keep (Combine.regex "[\\s\\S]*")) { state | indentation = indentation } str of
        Ok ( _, _, result ) ->
            result

        Err _ ->
            "ERR"


expansion_Suite : Test
expansion_Suite =
    describe "the expanded input"
        [ test "escape @'name as JS string" <|
            \_ ->
                expand [ ( "str", "a\"b\nc" ) ] [] "@'str|"
                    |> Expect.equal "a\\\"b\\nc|"
        , test "escape @'0 inserts the parameter as JS string" <|
            \_ ->
                expand [ ( "fn", "x(@'0)" ) ] [] "@fn(a\"b)|"
                    |> Expect.equal "x(a\\\"b)|"
        , test "escaped \\@ is neither a parameter nor a macro" <|
            \_ ->
                expand [ ( "fn", "\\@0 @0" ), ( "aa", "A" ) ] [] "@fn(\\@aa)|"
                    |> Expect.equal "\\@0 \\@aa|"
        , test "@@name shows the body in a debug box" <|
            \_ ->
                expand [ ( "fn", "*b* <i> @x\n@input" ) ] [] "@@fn|"
                    |> Expect.equal "<lia-keep><pre id='ls'><code style='background: #CCCCCC; white-space: pre;'>\\*b\\* \\<i\\> @-@x<br id='ls'>@input</code></pre></lia-keep>|"
        , test "@-@name shows the body as inline debug text" <|
            \_ ->
                expand [ ( "fn", "*b* `c` @x \\`d" ) ] [] "@-@fn|"
                    |> Expect.equal "\\*b\\* \\`c\\` @-@x `d|"
        , test "@uid counts up on every call" <|
            \_ ->
                expand [ ( "fn", "@0 @1" ) ] [] "@fn(@uid,@uid)@uid|"
                    |> Expect.equal "2_0 2_1@uid|"
        , test "built-in values come from the definition" <|
            \_ ->
                expand [ ( "fn", "@0" ) ] [] "@fn(@section;@author;@uid;@version)|"
                    |> Expect.equal "2;;2_0;0.0.1|"
        , test "reference macro appends the resolved url" <|
            \_ ->
                expand [ ( "img", "@0-@1" ) ] [] "@[img(p)](pic.png \"title\")|"
                    |> Expect.equal "p-https://example.com/course/pic.png|"
        , test "escaped reference macro" <|
            \_ ->
                expand [ ( "img", "@0" ) ] [] "@'[img](a\"b.png)|"
                    |> Expect.equal "https://example.com/course/a\\\"b.png|"
        , test "macro listing appends the block content" <|
            \_ ->
                expand [ ( "run", "@0:@1" ) ] [] "```js @run(a)\nline1\nline2\n```|"
                    |> Expect.equal "a:line1\nline2|"
        , test "longer listing frames may contain ```" <|
            \_ ->
                expand [ ( "run", "@0" ) ] [] "```` @run\n```\nx\n````|"
                    |> Expect.equal "```\nx|"
        , test "parameters may be inline code or code blocks" <|
            \_ ->
                expand [ ( "fn", "@0;@1;@2" ) ] [] "@fn(`a,b`,```c)```,d)|"
                    |> Expect.equal "a,b;c);d|"
        , test "@input is kept within parameters" <|
            \_ ->
                expand [ ( "fn", "@0" ), ( "aa", "A" ) ] [] "@fn(x @input y @aa)|"
                    |> Expect.equal "x @input y A|"
        , test "an unknown macro within a parameter is kept as text" <|
            \_ ->
                expand [ ( "fn", "@0" ), ( "aa", "A" ) ] [] "@fn(@aa x@unknown @aa)|"
                    |> Expect.equal "A x@unknown A|"
        , test "chained macros expand one after the other" <|
            \_ ->
                expand [ ( "aa", "@bb x" ), ( "bb", "B" ) ] [] "@aa|"
                    |> Expect.equal "B x|"
        , test "a self-referential macro terminates" <|
            \_ ->
                expand [ ( "aa", "@aa" ) ] [] "@aa|"
                    |> Expect.equal "@aa|"
        , test "the body gets the current indentation" <|
            \_ ->
                expand [ ( "fn", "a\nb\nc" ) ] [ "  ", "?* " ] "@fn|"
                    |> Expect.equal "a\n   b\n   c|"
        , test "listings ignore the indentation" <|
            \_ ->
                expand [ ( "fn", "a\n@0" ) ] [ "  " ] "```@fn\nx\n```|"
                    |> Expect.equal "a\nx|"
        , test "@10 is the eleventh parameter, not @1 followed by 0" <|
            \_ ->
                expand [ ( "fn", "@10@1" ) ] [] "@fn(a,b,c,d,e,f,g,h,i,j,k)|"
                    |> Expect.equal "kb|"
        , test "inserted values are not searched for parameters again" <|
            \_ ->
                expand [ ( "fn", "@0 @1" ) ] [] "@fn(@1,b)|"
                    |> Expect.equal "@1 b|"
        , test "a macro expanding to nothing at the end of a parameter" <|
            \_ ->
                expand [ ( "fn", "[@0]" ), ( "aa", "" ) ] [] "@fn(x @aa)|"
                    |> Expect.equal "[x ]|"
        , test "a recursive macro within a parameter terminates" <|
            \_ ->
                expand [ ( "fn", "[@0]" ), ( "aa", "x@aa" ) ] [] "@fn(@aa)|"
                    |> Expect.equal "[x@aa]|"
        , test "names need two characters" <|
            \_ ->
                expand [ ( "a", "A" ) ] [] "@a|"
                    |> Expect.equal "@a|"
        , test "macro with dots and digits in its name" <|
            \_ ->
                expand [ ( "a.b1", "X" ) ] [] "@a.b1|"
                    |> Expect.equal "X|"
        ]
