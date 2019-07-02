module Inline exposing
    ( bold_Suite
    , bold_italic_Suite
    , italic_Suite
    , strike_Suite
    , underline_Suite
    )

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Inline.Parser exposing (parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Parser.Context as Context
import LiaFuzz exposing (fuzzRegex)
import Test exposing (..)


parse : String -> List Inline
parse =
    ""
        |> default
        |> Context.init identity
        |> parse_inlines


chars : String -> Inline
chars str =
    Chars str Nothing


end : Inline
end =
    chars " "


simply str rslt =
    test str <|
        \_ ->
            parse str
                |> Expect.equal [ rslt, end ]


italic : String -> Inline
italic str =
    Italic (chars str) Nothing


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
    Bold (chars str) Nothing


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
    Bold (italic str) Nothing


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
    Strike (chars str) Nothing


strike_Suite : Test
strike_Suite =
    describe "generating striked text"
        [ simply "~test~" (strike "test")
        , simply "~test with multiple~" (strike "test with multiple")
        ]


underline : String -> Inline
underline str =
    Underline (chars str) Nothing


underline_Suite : Test
underline_Suite =
    describe "generating underlined text"
        [ simply "~~test~~" (underline "test")
        , simply "~~test with multiple~~" (underline "test with multiple")
        ]
