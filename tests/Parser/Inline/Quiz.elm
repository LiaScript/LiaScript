module Parser.Inline.Quiz exposing
    ( blankWidth_fuzz_Suite
    , blank_Suite
    , drop_Suite
    )

import Expect
import Lia.Markdown.Inline.Types exposing (Inline(..))
import LiaFuzz exposing (words)
import Parser.Inline.Fixtures exposing (chars, parseWithInputEnabled)
import Test exposing (Test, describe, fuzz, test)


blank_Suite : Test
blank_Suite =
    describe "generating inline fill-in-the-blank quiz inputs (only reachable once a quiz block has granted input permission)"
        [ test "a single blank registers as the first option" <|
            \_ ->
                parseWithInputEnabled "[[cat]]"
                    |> Expect.equal [ Quiz ( "2em", 0 ) [] ]
        , test "a second blank on the same line registers as the next option" <|
            \_ ->
                parseWithInputEnabled "[[cat]] [[dog]]"
                    |> Expect.equal
                        [ Quiz ( "2em", 0 ) []
                        , chars " "
                        , Quiz ( "2em", 1 ) []
                        ]
        ]


drop_Suite : Test
drop_Suite =
    describe "generating inline drag-and-drop quiz inputs"
        [ test "a single drop target registers as the first option" <|
            \_ ->
                parseWithInputEnabled "[->[cat]]"
                    |> Expect.equal [ Quiz ( "2em", 0 ) [] ]
        ]


blankWidth_fuzz_Suite : Test
blankWidth_fuzz_Suite =
    describe "blank width scales with the captured content length"
        [ fuzz words "wrapped in [[...]]" <|
            \content ->
                parseWithInputEnabled ("[[" ++ content ++ "]]")
                    |> Expect.equal
                        [ Quiz
                            ( String.fromFloat (toFloat (String.length content + 2) * 0.4) ++ "em", 0 )
                            []
                        ]
        ]
