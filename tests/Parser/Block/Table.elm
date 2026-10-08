module Parser.Block.Table exposing
    ( alignment_Suite
    , autoClass_Suite
    , chartClass_Suite
    , sortable_Suite
    , table_Suite
    )

import Const
import Expect
import Lia.Markdown.Table.Types exposing (Class(..))
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (parse, toTests)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, test)


table_Suite : Test
table_Suite =
    describe "generating tables" <|
        toTests
            {- | Col1 | Col2 |
               | --- | --- |
               | a | b |
            -}
            [ ( "| Col1 | Col2 |\n| --- | --- |\n| a | b |\n"
              , Table []
                    { class = None
                    , sortable = True
                    , head =
                        [ ( [], [ chars "Col1 " ] )
                        , ( [], [ chars "Col2 " ] )
                        ]
                    , format = [ Const.align.default, Const.align.default ]
                    , body =
                        [ [ ( [], [ chars "a " ] )
                          , ( [], [ chars "b " ] )
                          ]
                        ]
                    , id = 0
                    }
              )
            ]


{-| The `:---`/`---:`/`:---:` header-separator markers (left/right/center),
one per column - a plain `---` with no colon defaults to `Const.align.default`
(which is itself the same value as `.left`).
-}
alignment_Suite : Test
alignment_Suite =
    describe "a column's header separator sets its alignment (:---, ---:, :---:)" <|
        toTests
            {- | Col1 | Col2 | Col3 |
               |:---|---:|:---:|
               | a | b | c |
            -}
            [ ( "| Col1 | Col2 | Col3 |\n|:---|---:|:---:|\n| a | b | c |\n"
              , Table []
                    { class = None
                    , sortable = True
                    , head =
                        [ ( [], [ chars "Col1 " ] )
                        , ( [], [ chars "Col2 " ] )
                        , ( [], [ chars "Col3 " ] )
                        ]
                    , format = [ Const.align.left, Const.align.right, Const.align.center ]
                    , body =
                        [ [ ( [], [ chars "a " ] )
                          , ( [], [ chars "b " ] )
                          , ( [], [ chars "c " ] )
                          ]
                        ]
                    , id = 0
                    }
              )
            ]


{-| `data-sortable="false"` on the comment preceding a table overrides the
default `sortable = True` - `Table.Parser.classify` reads it via
`Param.isSetMaybe`, same boolean-ish parsing as any other HTML attribute.
-}
sortable_Suite : Test
sortable_Suite =
    describe "a data-sortable=\"false\" attribute turns off sorting" <|
        toTests
            {- <!-- data-sortable="false" -->
               | Col1 | Col2 |
               | --- | --- |
               | a | b |
            -}
            [ ( "<!-- data-sortable=\"false\" -->\n| Col1 | Col2 |\n| --- | --- |\n| a | b |\n"
              , Table [ ( "data-sortable", "false" ) ]
                    { class = None
                    , sortable = False
                    , head =
                        [ ( [], [ chars "Col1 " ] )
                        , ( [], [ chars "Col2 " ] )
                        ]
                    , format = [ Const.align.default, Const.align.default ]
                    , body =
                        [ [ ( [], [ chars "a " ] )
                          , ( [], [ chars "b " ] )
                          ]
                        ]
                    , id = 0
                    }
              )
            ]


{-| A `data-type="..."` attribute explicitly forces the table's chart
classification (`Table.Parser.diagramType`), bypassing the heuristic
auto-detection (`checkDiagram`) that would otherwise inspect the table's
actual numeric content - this is the deterministic way to pin down chart
classification without needing to replicate that heuristic's math.
-}
chartClass_Suite : Test
chartClass_Suite =
    describe "a data-type=\"...\" attribute forces the table's chart classification" <|
        toTests
            {- <!-- data-type="barchart" -->
               | Col1 | Col2 |
               | --- | --- |
               | a | b |
            -}
            [ ( "<!-- data-type=\"barchart\" -->\n| Col1 | Col2 |\n| --- | --- |\n| a | b |\n"
              , Table [ ( "data-type", "barchart" ) ]
                    { class = BarChart
                    , sortable = True
                    , head =
                        [ ( [], [ chars "Col1 " ] )
                        , ( [], [ chars "Col2 " ] )
                        ]
                    , format = [ Const.align.default, Const.align.default ]
                    , body =
                        [ [ ( [], [ chars "a " ] )
                          , ( [], [ chars "b " ] )
                          ]
                        ]
                    , id = 0
                    }
              )
            ]


{-| Without `data-type` the diagram type is guessed from the content
(`Table.Parser.checkDiagram`).
-}
autoClass_Suite : Test
autoClass_Suite =
    let
        table attr head rows =
            attr ++ head ++ "\n|" ++ String.repeat (List.length (String.indexes "|" head) - 1) "---|" ++ "\n" ++ String.join "\n" rows ++ "\n"

        classOf md =
            case parse md of
                [ Table _ t ] ->
                    Just t.class

                _ ->
                    Nothing
    in
    describe "the diagram type is guessed from the table's content" <|
        List.map
            (\( name, md, class ) -> test name <| \_ -> classOf md |> Expect.equal (Just class))
            [ ( "unique numeric x values", table "" "| x | a | b |" [ "| 1 | 2 | 3 |", "| 2 | 4 | 5 |" ], LinePlot )
            , ( "repeated numeric x values", table "" "| x | a | b |" [ "| 1 | 2 | 3 |", "| 1 | 4 | 5 |" ], ScatterPlot )
            , ( "numbers on both axes", table "" "| | 1 | 2 |" [ "| 1 | 2 | 3 |", "| 2 | 4 | 5 |" ], HeatMap )
            , ( "one numeric row", table "" "| | a | b |" [ "| 1 | 2 | 3 |" ], PieChart )
            , ( "one category row", table "" "| | a | b |" [ "| k | 2 | 3 |" ], PieChart )
            , ( "adjacency matrix", table "" "| | a | b |" [ "| a | 0 | 1 |", "| b | 1 | 0 |" ], Graph )
            , ( "categories", table "" "| | a | b |" [ "| x | 10 | 11 |", "| y | 9 | 12 |" ], BarChart )
            , ( "two columns with differing scales", table "" "| | a | b |" [ "| x | 150 | 1 |", "| y | 90 | 12 |" ], Parallel )
            , ( "three columns with differing scales", table "" "| | a | b | c |" [ "| x | 150 | 1 | 5 |", "| y | 90 | 12 | 7 |" ], Radar )
            , ( "an all-zero column does not count as scale", table "" "| | a | b | c |" [ "| x | 10 | 0 | 2 |", "| y | 7 | 0 | 5 |" ], BarChart )
            , ( "unsorted unique x values", table "" "| x | a |" [ "| 2 | 3 |", "| 1 | 4 |", "| 3 | 5 |" ], ScatterPlot )
            , ( "dates", table "" "| | a |" [ "| 2024-03-01 | 3 |", "| 2024-03-02 | 4 |" ], LinePlot )
            , ( "self-references", table "" "| | a | b |" [ "| a | 1 | 0.5 |", "| b | 0.5 | 1 |" ], HeatMap )
            , ( "truth table", table "" "| a | b | y |" [ "| 0 | 0 | 0 |", "| 0 | 1 | 1 |", "| 1 | 0 | 1 |" ], None )
            , ( "one row with a zero", table "" "| | a | b |" [ "| k | 2 | 0 |" ], None )
            , ( "more text than numeric columns", table "" "| | a | b | c |" [ "| x | 1 | u | v |", "| y | 2 | w | z |" ], None )
            , ( "numbers within text", table "" "| | a |" [ "| x | 44 % mittlerer Abschluss |", "| y | 5. April |" ], None )
            , ( "many rows of a single column", table "" "| | a |" (List.map (\i -> "| k" ++ String.fromInt i ++ " | " ++ String.fromInt (modBy 7 i + 1) ++ " |") (List.range 1 30)), BarChart )
            , ( "at least 50 cells", table "" "| | a | b | c | d |" (List.repeat 10 "| k | 1 | 2 | 3 | 4 |"), Parallel )
            , ( "text only", table "" "| | a | b |" [ "| x | u | v |", "| y | w | z |" ], None )
            , ( "simple table without header", "| x | 1 |\n| y | 2 |\n", None )
            , ( "data-transpose", table "<!-- data-transpose -->\n" "| x | a | b |" [ "| 1 | 2 | 3 |", "| 2 | 4 | 5 |" ], BarChart )
            , ( "data-src", table "<!-- data-src=\"geo.json\" -->\n" "| | a |" [ "| x | 1 |" ], Map )
            ]
