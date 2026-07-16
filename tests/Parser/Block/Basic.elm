module Parser.Block.Basic exposing
    ( hline_Suite
    , paragraph_Suite
    )

import Parser.Block.Fixtures exposing (hline, paragraph, toTests)
import Test exposing (Test, describe)


paragraph_Suite : Test
paragraph_Suite =
    describe "generating paragraphs" <|
        toTests
            [ ( "hello world\n", paragraph "hello world" )
            ]


hline_Suite : Test
hline_Suite =
    describe "generating horizontal lines" <|
        toTests
            [ ( "---\n", hline )
            ]
