module Parser.Block.Lists exposing
    ( bulletList_Suite
    , bulletList_marker_fuzz_Suite
    , looseVsTight_Suite
    , multiParagraphItem_Suite
    , nested_Suite
    , orderedList_Suite
    , orderedList_number_fuzz_Suite
    )

import Expect
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex, words)
import Parser.Block.Fixtures exposing (bulletList, orderedList, paragraph, parse, toTests)
import Test exposing (Test, describe, fuzz2, test)


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
                {- * example item -}
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
                {- 42. example item -}
                parse (number ++ ". " ++ item ++ "\n")
                    |> Expect.equal [ orderedList [ ( number, item ) ] ]
        ]


{-| A list item's content is `Blocks`, not a single `Block` - it can contain
another whole list nested inside it (indented one level: 2 spaces for a
bullet list, 3 for an ordered list, matching each marker's own width), same
as any other block-in-a-block nesting.
-}
nested_Suite : Test
nested_Suite =
    describe "a list item can contain a nested list, indented one level"
        [ test "a bullet list nested inside a bullet-list item" <|
            \_ ->
                {- * item one
                     * nested one
                     * nested two
                   * item two
                -}
                parse "* item one\n  * nested one\n  * nested two\n* item two\n"
                    |> Expect.equal
                        [ BulletList []
                            [ [ paragraph "item one"
                              , BulletList [] [ [ paragraph "nested one" ], [ paragraph "nested two" ] ]
                              ]
                            , [ paragraph "item two" ]
                            ]
                        ]
        , test "an ordered list nested inside an ordered-list item" <|
            \_ ->
                {- 1. item one
                      1. nested one
                      2. nested two
                   2. item two
                -}
                parse "1. item one\n   1. nested one\n   2. nested two\n2. item two\n"
                    |> Expect.equal
                        [ OrderedList []
                            [ ( "1"
                              , [ paragraph "item one"
                                , OrderedList [] [ ( "1", [ paragraph "nested one" ] ), ( "2", [ paragraph "nested two" ] ) ]
                                ]
                              )
                            , ( "2", [ paragraph "item two" ] )
                            ]
                        ]
        ]


{-| A blank line between two list items ("loose" list, in CommonMark terms)
produces the exact same tree as no blank line at all ("tight") - every item's
content is already `Blocks` (each wrapped in its own `Paragraph`)
unconditionally, so LiaScript has no separate tight-list representation to
switch to/from in the first place.
-}
looseVsTight_Suite : Test
looseVsTight_Suite =
    describe "a blank line between list items (loose) parses identically to no blank line (tight)"
        [ test "tight: no blank line between items" <|
            \_ ->
                {- * item one
                   * item two
                -}
                parse "* item one\n* item two\n"
                    {- * item one

                       * item two
                    -}
                    |> Expect.equal (parse "* item one\n\n* item two\n")
        ]


{-| Indenting a continuation line by the marker's own width (2 spaces for a
bullet, matching `nested_Suite` above) after a blank line adds a second
`Block` to that item's content, rather than starting a new item or a nested
list - the same multi-block-per-option continuation already covered for
Quiz/Survey options doesn't apply here since list items always accept it.
-}
multiParagraphItem_Suite : Test
multiParagraphItem_Suite =
    describe "a list item can span multiple paragraphs via an indented continuation"
        [ test "a blank line then an indented paragraph continues the same item" <|
            \_ ->
                {- * item one

                     continued
                   * item two
                -}
                parse "* item one\n\n  continued\n* item two\n"
                    |> Expect.equal
                        [ BulletList []
                            [ [ paragraph "item one", paragraph "continued" ]
                            , [ paragraph "item two" ]
                            ]
                        ]
        ]
