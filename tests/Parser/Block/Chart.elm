module Parser.Block.Chart exposing (lines_Suite)

{-| The raw ASCII chart notation described in the docs' "Charts" section
(`LinePlot`/`ScatterPlot` etc.) - rows of `label |dots(label)?` lines
followed by an `x0 +---dashes---` axis line and an `x0 label x1` line below
it. Each distinct non-space character in a row's dots-string becomes its own
series, plotted using the row's position (bottom row = lowest y) and the
dots-string's column position (scaled by the x-axis segmentation).

Note that a leading number right before the first row doubles as an explicit
`y-max` override (and, since it's consumed positionally rather than as part
of that row, blanks that row's own label) - this is what lets the docs'
example spell out "9", "y", "-", "a", "x", "i", "s", "0" as single-character
row labels down the left edge. To keep this test's expected values simple we
avoid that overlap by giving every row a non-numeric label instead, which
leaves `y-max`/`y-min` at their defaults (1.0 / 0.0).

-}

import Dict
import Expect
import Lia.Markdown.Chart.Types exposing (Diagram(..))
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (parse)
import Test exposing (Test, describe, test)


lines_Suite : Test
lines_Suite =
    describe "generating a chart from the raw ASCII row/axis notation"
        [ test "two single-point rows become a two-point Lines series" <|
            \_ ->
                {- a |*
                   b |  *
                   +----
                   0 x   4
                -}
                parse "a |*\nb |  *\n+----\n0 x   4\n"
                    |> Expect.equal
                        [ Chart []
                            { title = ""
                            , yLabel = "ab"
                            , xLabel = "x"
                            , legend = []
                            , diagrams =
                                Dict.fromList
                                    [ ( '*'
                                      , Lines
                                            [ { x = 0, y = 0.5 }
                                            , { x = 2, y = 0 }
                                            ]
                                            Nothing
                                      )
                                    ]
                            , xLimits = { min = Nothing, max = Nothing }
                            , yLimits = { min = Nothing, max = Nothing }
                            , orientation = Nothing
                            }
                        ]
        ]
