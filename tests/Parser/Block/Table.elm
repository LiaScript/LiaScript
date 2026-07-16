module Parser.Block.Table exposing
    ( alignment_Suite
    , chartClass_Suite
    , sortable_Suite
    , table_Suite
    )

import Const
import Lia.Markdown.Table.Types exposing (Class(..))
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (toTests)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe)


table_Suite : Test
table_Suite =
    describe "generating tables" <|
        toTests
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
