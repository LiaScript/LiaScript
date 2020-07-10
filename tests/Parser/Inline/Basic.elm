module Parser.Inline.Basic exposing
    ( bold_Suite
    , bold_italic_Suite
    , formula_Suite
    , italic_Suite
    , strike_Suite
    , superscript_Suite
    , underline_Suite
    , verbatim_Suite
    )

--import LiaFuzz exposing (fuzzRegex)

import Expect
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Inline.Parser exposing (parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Parser.Context as Context
import Test exposing (Test, describe, test)


parse : String -> List Inline
parse =
    ""
        |> default
        |> Context.init identity
        |> parse_inlines


chars : String -> Inline
chars str =
    Chars str []


end : Inline
end =
    chars " "


simply : String -> Inline -> Test
simply str rslt =
    test str <|
        \_ ->
            parse str
                |> Expect.equal [ rslt, end ]


italic : String -> Inline
italic str =
    Italic (chars str) []


italic_Suite : Test
italic_Suite =
    describe "generating italic text"
        [ simply "*test*" (italic "test")
        , simply "_test_" (italic "test")
        , simply "*test with multiple*" (italic "test with multiple")
        , simply "_test with multiple_" (italic "test with multiple")
        ]


bold : String -> Inline
bold str =
    Bold (chars str) []


bold_Suite : Test
bold_Suite =
    describe "generating bold text"
        [ simply "**test**" (bold "test")
        , simply "**test with multiple**" (bold "test with multiple")
        , simply "__test__" (bold "test")
        , simply "__test with multiple__" (bold "test with multiple")
        ]


bold_italic : String -> Inline
bold_italic str =
    Bold (italic str) []


bold_italic_Suite : Test
bold_italic_Suite =
    describe "generating bold and italic text"
        [ simply "***test***" (bold_italic "test")
        , simply "***test with multiple***" (bold_italic "test with multiple")
        , simply "___test___" (bold_italic "test")
        , simply "___test with multiple___" (bold_italic "test with multiple")
        ]


strike : String -> Inline
strike str =
    Strike (chars str) []


strike_Suite : Test
strike_Suite =
    describe "generating striked text"
        [ simply "~test~" (strike "test")
        , simply "~test with multiple~" (strike "test with multiple")
        ]


underline : String -> Inline
underline str =
    Underline (chars str) []


underline_Suite : Test
underline_Suite =
    describe "generating underlined text"
        [ simply "~~test~~" (underline "test")
        , simply "~~test with multiple~~" (underline "test with multiple")
        ]


superscript : String -> Inline
superscript str =
    Superscript (chars str) []


superscript_Suite : Test
superscript_Suite =
    describe "generating superscripted text"
        [ simply "^test^" (superscript "test")
        , simply "^test with multiple^" (superscript "test with multiple")
        ]


verbatim : String -> Inline
verbatim str =
    Verbatim str []


verbatim_Suite : Test
verbatim_Suite =
    describe "generating verbatim text"
        [ simply "`test`" (verbatim "test")
        , simply "`test with multiple`" (verbatim "test with multiple")
        ]


formula : Bool -> String -> Inline
formula mode str =
    Formula
        (if mode then
            "true"

         else
            "false"
        )
        str
        []


formula_Suite : Test
formula_Suite =
    describe "generating formula text"
        [ simply "$inline$" (formula False "inline")
        , simply "$$inline$$" (formula True "inline")
        ]
