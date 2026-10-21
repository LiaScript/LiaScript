module Definition exposing (cases_Suite, formulaMacro_Suite)

{-| The document-header (`<!-- ... -->` main comment) definitions parsed by
`Lia.Definition.Parser`, as opposed to section-body content parsed by
`Lia.Markdown.Parser` (see `tests/Parser/`). Currently only covers the docs'
"Formula-Macros" section: a `formula: name {body}` header line - the first
whitespace-separated word is the macro name (the leading backslash is
optional and gets added if missing, since KaTeX macro names are always
backslash-prefixed), the rest of the line is the macro body, verbatim. These
end up in `Definition.formulas`, later passed to KaTeX as global macros for
every formula in the document - they don't get textually substituted into
any `Formula` inline by the parser itself (unlike `@name`-style macros, see
`Parser.Block.Macro`).
-}

import Combine
import Dict exposing (Dict)
import Expect
import Lia.Definition.Parser as Definition
import Lia.Definition.Types as Types exposing (Definition, Resource(..), default)
import Lia.Markdown.Inline.Types as Inline
import Lia.Parser.Context as Context
import Lia.Parser.Parser exposing (parse_definition)
import Test exposing (Test, describe, test)


formulas : String -> Dict String String
formulas str =
    let
        state =
            default "" "" |> Context.init Nothing Nothing
    in
    case Combine.runParser Definition.parse state str of
        Ok ( resultState, _, _ ) ->
            resultState.defines.formulas

        Err _ ->
            Dict.empty


formulaMacro_Suite : Test
formulaMacro_Suite =
    describe "a formula: header line defines a global KaTeX macro"
        [ test "a bare name gets a backslash prepended" <|
            \_ ->
                formulas "<!--\nformula:  foo   {x^2}\n-->\n"
                    |> Expect.equal (Dict.fromList [ ( "\\foo", "{x^2}" ) ])
        , test "a name that already starts with a backslash is left as-is" <|
            \_ ->
                formulas "<!--\nformula:  \\bar  {#1^2}\n-->\n"
                    |> Expect.equal (Dict.fromList [ ( "\\bar", "{#1^2}" ) ])
        , test "several formula: lines all get collected" <|
            \_ ->
                formulas "<!--\nformula:  foo   {x^2}\nformula:  \\bar  {#1^2}\n-->\n"
                    |> Expect.equal
                        (Dict.fromList
                            [ ( "\\foo", "{x^2}" )
                            , ( "\\bar", "{#1^2}" )
                            ]
                        )
        ]


{-| The header of a course, parsed relative to `https://x.org/` with the
query `q=1`.
-}
header : String -> Definition
header body =
    case parse_definition "https://x.org/" "q=1" ("<!--\n" ++ body ++ "\n-->\n# Title\n") of
        Ok ( def, _ ) ->
            def

        Err _ ->
            default "" ""


{-| Cases that do not occur in the LiaBooks and LiaTemplates corpora, which are
otherwise used as a golden master.
-}
cases_Suite : Test
cases_Suite =
    describe "header cases missing in the corpora"
        [ test "a multi-line value ends only at a line starting with @end" <|
            \_ ->
                header "@mac\nmail@end.de\n@end"
                    |> .macro
                    |> Dict.get "mac"
                    |> Expect.equal (Just "mail@end.de")
        , test "spaces after a key without colon start a multi-line value" <|
            \_ ->
                header "@mac  \nline one\n  line two\n@end"
                    |> .macro
                    |> Dict.get "mac"
                    |> Expect.equal (Just "line one\n  line two")
        , test "spaces before the colon are allowed" <|
            \_ ->
                header "author : Some One"
                    |> .author
                    |> Expect.equal "Some One"
        , test "a multi-line attribute becomes a single line" <|
            \_ ->
                header "attribute\nfirst\nsecond\n@end"
                    |> .attributes
                    |> Expect.equal [ [ Inline.Chars "first second" [] ] ]
        , test "a multi-line comment is reduced to single spaces" <|
            \_ ->
                header "comment\nsome   text\n  over lines\n@end"
                    |> .macro
                    |> Dict.get "comment"
                    |> Expect.equal (Just "some text over lines")
        , test "a multi-line formula keeps inner spaces but is trimmed" <|
            \_ ->
                header "formula\nbar  {y}\n@end"
                    |> .formulas
                    |> Expect.equal (Dict.fromList [ ( "\\bar", "{y}" ) ])
        , test "imports from GitHub are turned into raw URLs" <|
            \_ ->
                header "import: https://github.com/LiaScript/CodeRunner"
                    |> .imports
                    |> Expect.equal [ "https://raw.githubusercontent.com/LiaScript/CodeRunner/master/README.md" ]
        , test "relative resources get the base and query" <|
            \_ ->
                header "script: a.js https://cdn.org/b.js\nSCRIPT: m.js"
                    |> .resources
                    |> Expect.equal [ Script "https://x.org/a.js?q=1", Script "https://cdn.org/b.js", Module "https://x.org/m.js?q=1" ]
        , test "the course wins over imported macros and formulas" <|
            \_ ->
                Types.add_macros (header "@m: course\nformula: f {c}") (header "@m: import\nformula: f {i}\n@n: import")
                    |> (\d -> ( Dict.toList d.macro, Dict.toList d.formulas ))
                    |> Expect.equal ( [ ( "m", "course" ), ( "n", "import" ) ], [ ( "\\f", "{c}" ) ] )
        , test "a section wins over the course macros" <|
            \_ ->
                Types.merge (header "@m: course\nauthor: A") (Just (header "@m: section"))
                    |> (\d -> ( d.author, Dict.get "m" d.macro ))
                    |> Expect.equal ( "A", Just "section" )
        , test "debug does not become a macro" <|
            \_ ->
                header "debug: true"
                    |> .macro
                    |> Expect.equal Dict.empty
        ]
