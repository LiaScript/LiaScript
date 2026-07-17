module Parser.Inline.Emphasis exposing
    ( annotation_Suite
    , bold_Suite
    , bold_fuzz_Suite
    , bold_italic_Suite
    , bold_italic_fuzz_Suite
    , formula_Suite
    , italic_Suite
    , italic_fuzz_Suite
    , nested_Suite
    , strike_Suite
    , strike_fuzz_Suite
    , superscript_Suite
    , superscript_fuzz_Suite
    , underline_Suite
    , underline_fuzz_Suite
    , verbatim_Suite
    , verbatim_fuzz_Suite
    )

import Expect
import Lia.Markdown.Inline.Types exposing (Inline(..))
import LiaFuzz exposing (words)
import Parser.Inline.Fixtures
    exposing
        ( bold
        , bold_italic
        , chars
        , formula
        , italic
        , link
        , parse
        , strike
        , superscript
        , toTests
        , underline
        , verbatim
        )
import Test exposing (Test, describe, fuzz)


italic_Suite : Test
italic_Suite =
    describe "generating italic text" <|
        toTests
            [ ( "*test*", italic "test" )
            , ( "_test_", italic "test" )
            , ( "*test with multiple*", italic "test with multiple" )
            , ( "_test with multiple_", italic "test with multiple" )
            ]


bold_Suite : Test
bold_Suite =
    describe "generating bold text" <|
        toTests
            [ ( "**test**", bold "test" )
            , ( "**test with multiple**", bold "test with multiple" )
            , ( "__test__", bold "test" )
            , ( "__test with multiple__", bold "test with multiple" )
            ]


bold_italic_Suite : Test
bold_italic_Suite =
    describe "generating bold and italic text" <|
        toTests
            [ ( "***test***", bold_italic "test" )
            , ( "***test with multiple***", bold_italic "test with multiple" )
            , ( "___test___", bold_italic "test" )
            , ( "___test with multiple___", bold_italic "test with multiple" )
            ]


strike_Suite : Test
strike_Suite =
    describe "generating striked text" <|
        toTests
            [ ( "~test~", strike "test" )
            , ( "~test with multiple~", strike "test with multiple" )
            ]


underline_Suite : Test
underline_Suite =
    describe "generating underlined text" <|
        toTests
            [ ( "~~test~~", underline "test" )
            , ( "~~test with multiple~~", underline "test with multiple" )
            ]


superscript_Suite : Test
superscript_Suite =
    describe "generating superscripted text" <|
        toTests
            [ ( "^test^", superscript "test" )
            , ( "^test with multiple^", superscript "test with multiple" )
            ]


verbatim_Suite : Test
verbatim_Suite =
    describe "generating verbatim text" <|
        toTests
            [ ( "`test`", verbatim "test" )
            , ( "`test with multiple`", verbatim "test with multiple" )
            ]


italic_fuzz_Suite : Test
italic_fuzz_Suite =
    describe "generating italic text from arbitrary content"
        [ fuzz words "wrapped in *...*" <|
            {- *example text* -} \content -> parse ("*" ++ content ++ "*") |> Expect.equal [ italic content ]
        , fuzz words "wrapped in _..._" <|
            {- _example text_ -} \content -> parse ("_" ++ content ++ "_") |> Expect.equal [ italic content ]
        ]


bold_fuzz_Suite : Test
bold_fuzz_Suite =
    describe "generating bold text from arbitrary content"
        [ fuzz words "wrapped in **...**" <|
            {- **example text** -} \content -> parse ("**" ++ content ++ "**") |> Expect.equal [ bold content ]
        , fuzz words "wrapped in __...__" <|
            {- __example text__ -} \content -> parse ("__" ++ content ++ "__") |> Expect.equal [ bold content ]
        ]


bold_italic_fuzz_Suite : Test
bold_italic_fuzz_Suite =
    describe "generating bold and italic text from arbitrary content"
        [ fuzz words "wrapped in ***...***" <|
            {- ***example text*** -} \content -> parse ("***" ++ content ++ "***") |> Expect.equal [ bold_italic content ]
        , fuzz words "wrapped in ___..___" <|
            {- ___example text___ -} \content -> parse ("___" ++ content ++ "___") |> Expect.equal [ bold_italic content ]
        ]


strike_fuzz_Suite : Test
strike_fuzz_Suite =
    describe "generating striked text from arbitrary content"
        [ fuzz words "wrapped in ~...~" <|
            {- ~example text~ -} \content -> parse ("~" ++ content ++ "~") |> Expect.equal [ strike content ]
        ]


underline_fuzz_Suite : Test
underline_fuzz_Suite =
    describe "generating underlined text from arbitrary content"
        [ fuzz words "wrapped in ~~...~~" <|
            {- ~~example text~~ -} \content -> parse ("~~" ++ content ++ "~~") |> Expect.equal [ underline content ]
        ]


superscript_fuzz_Suite : Test
superscript_fuzz_Suite =
    describe "generating superscripted text from arbitrary content"
        [ fuzz words "wrapped in ^...^" <|
            {- ^example text^ -} \content -> parse ("^" ++ content ++ "^") |> Expect.equal [ superscript content ]
        ]


verbatim_fuzz_Suite : Test
verbatim_fuzz_Suite =
    describe "generating verbatim text from arbitrary content"
        [ fuzz words "wrapped in `...`" <|
            {- `example text` -} \content -> parse ("`" ++ content ++ "`") |> Expect.equal [ verbatim content ]
        ]


formula_Suite : Test
formula_Suite =
    describe "generating formula text" <|
        toTests
            [ ( "$inline$", formula False "inline" )
            , ( "$$inline$$", formula True "inline" )
            ]


nested_Suite : Test
nested_Suite =
    describe "generating nested/combined emphasis" <|
        toTests
            [ ( "**~test~**", Bold (Strike (chars "test") []) [] )
            , ( "*__test__*", Italic (Bold (chars "test") []) [] )
            , ( "~~*test*~~", Underline (Italic (chars "test") []) [] )
            , ( "^[text](http://example.com)^"
              , Superscript (link "text" "http://example.com") []
              )
            ]


annotation_Suite : Test
annotation_Suite =
    describe "attaching HTML-comment annotations to emphasis" <|
        toTests
            [ ( "**test**<!-- data-x=\"1\" -->"
              , Bold (chars "test") [ ( "data-x", "1" ) ]
              )
            , ( "*test*<!-- data-x=\"1\" -->"
              , Italic (chars "test") [ ( "data-x", "1" ) ]
              )
            ]
