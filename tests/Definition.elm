module Definition exposing (formulaMacro_Suite)

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
import Lia.Definition.Types exposing (default)
import Lia.Parser.Context as Context
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
