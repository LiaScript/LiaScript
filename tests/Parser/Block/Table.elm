module Parser.Block.Table exposing (table_Suite)

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
