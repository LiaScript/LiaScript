module Parser.Block.Headers exposing
    ( atx_Suite
    , atx_fuzz_Suite
    , setext_fuzz_Suite
    )

import Expect
import LiaFuzz exposing (fuzzRegex, words)
import Parser.Block.Fixtures exposing (header, parse, toTests)
import Test exposing (Test, describe, fuzz2)


atx_Suite : Test
atx_Suite =
    describe "generating ATX-style headers (# ... through ###### ...)" <|
        toTests
            [ ( "# Title\n", header 1 "Title" )
            , ( "## Title\n", header 2 "Title" )
            , ( "### Title\n", header 3 "Title" )
            , ( "#### Title\n", header 4 "Title" )
            , ( "##### Title\n", header 5 "Title" )
            , ( "###### Title\n", header 6 "Title" )
            ]


{-| The parser itself (`Lia.Parser.Preprocessor.title\_tag`) doesn't cap the
number of `#` at 6 like standard Markdown does, so this generates an
arbitrary run of 1 to 12 `#` characters alongside arbitrary title text, to
confirm the header level always matches the marker length, however deep.
-}
atx_fuzz_Suite : Test
atx_fuzz_Suite =
    describe "any run of # characters becomes a header at that depth"
        [ fuzz2 (fuzzRegex "#{1,12}") words "wrapped in #...# Title" <|
            \marker title ->
                parse (marker ++ " " ++ title ++ "\n")
                    |> Expect.equal [ header (String.length marker) title ]
        ]


{-| Setext-style headers underline the title with a run of `=` (level 1) or
`-` (level 2) of at least length 3 - fuzz the run length to make sure any
length beyond the minimum still counts.
-}
setext_fuzz_Suite : Test
setext_fuzz_Suite =
    describe "underlining a title with =... or -... generates a setext-style header"
        [ fuzz2 words (fuzzRegex "={3,20}") "underlined with =...=" <|
            \title underline ->
                parse (title ++ "\n" ++ underline ++ "\n")
                    |> Expect.equal [ header 1 title ]
        , fuzz2 words (fuzzRegex "-{3,20}") "underlined with -...-" <|
            \title underline ->
                parse (title ++ "\n" ++ underline ++ "\n")
                    |> Expect.equal [ header 2 title ]
        ]
