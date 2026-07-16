module Parser.Block.Lists exposing
    ( bulletList_Suite
    , bulletList_marker_fuzz_Suite
    , orderedList_Suite
    , orderedList_number_fuzz_Suite
    )

import Expect
import LiaFuzz exposing (fuzzRegex, words)
import Parser.Block.Fixtures exposing (bulletList, orderedList, parse, toTests)
import Test exposing (Test, describe, fuzz2)


bulletList_Suite : Test
bulletList_Suite =
    describe "generating unordered lists" <|
        toTests
            [ ( "* item one\n* item two\n", bulletList [ "item one", "item two" ] )
            , ( "+ item one\n+ item two\n", bulletList [ "item one", "item two" ] )
            , ( "- item one\n- item two\n", bulletList [ "item one", "item two" ] )
            ]


{-| `*`, `+`, and `-` are all valid, interchangeable bullet markers - fuzz
across all three (via the `[*+-]` character class) alongside arbitrary item
text, to confirm the marker choice never leaks into the parsed result.
-}
bulletList_marker_fuzz_Suite : Test
bulletList_marker_fuzz_Suite =
    describe "any of *, +, - works as a bullet marker"
        [ fuzz2 (fuzzRegex "[*+-]") words "wrapped in <marker> ...\\n" <|
            \marker item ->
                parse (marker ++ " " ++ item ++ "\n")
                    |> Expect.equal [ bulletList [ item ] ]
        ]


orderedList_Suite : Test
orderedList_Suite =
    describe "generating ordered lists" <|
        toTests
            [ ( "1. item one\n2. item two\n", orderedList [ ( "1", "item one" ), ( "2", "item two" ) ] )
            ]


{-| The list marker's numeral is captured and reused verbatim (it's not
renumbered or normalized) - fuzz arbitrary numerals, including ones with
leading zeros, to confirm the captured digits always survive unchanged.
-}
orderedList_number_fuzz_Suite : Test
orderedList_number_fuzz_Suite =
    describe "the numeral in front of a list item is preserved as-is"
        [ fuzz2 (fuzzRegex "[0-9]{1,4}") words "wrapped in <number>. ...\\n" <|
            \number item ->
                parse (number ++ ". " ++ item ++ "\n")
                    |> Expect.equal [ orderedList [ ( number, item ) ] ]
        ]
