module Markdown.ChartView exposing (suite)

import Expect
import Lia.Markdown.Chart.View exposing (niceLimits)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "niceLimits"
        [ test "rounds to a tenth of the order of magnitude of the range" <|
            \_ -> niceLimits ( 4.333333333333334, 97.66666666666667 ) |> Expect.equal ( 4, 98 )
        , test "keeps clean limits" <|
            \_ -> niceLimits ( 1, 4 ) |> Expect.equal ( 1, 4 )
        , test "float noise does not round up" <|
            \_ -> niceLimits ( 0.0232558, 0.97 ) |> Expect.equal ( 0.02, 0.97 )
        , test "just above a power of ten" <|
            \_ -> niceLimits ( 0, 1.02 ) |> Expect.equal ( 0, 1.1 )
        , test "years" <|
            \_ -> niceLimits ( 1995, 2014 ) |> Expect.equal ( 1995, 2014 )
        , test "large values" <|
            \_ -> niceLimits ( 1234, 5678 ) |> Expect.equal ( 1200, 5700 )
        , test "single value stays" <|
            \_ -> niceLimits ( 3, 3 ) |> Expect.equal ( 3, 3 )
        ]
