module Lia.Markdown.Table.Json exposing (encode)

import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Types exposing (Class(..), Table)


encode : Table -> JE.Value
encode table =
    JE.object
        [ ( "class"
          , JE.string <|
                case table.class of
                    None ->
                        "none"

                    LinePlot ->
                        "lineplot"

                    ScatterPlot ->
                        "scatterplot"

                    BarChart ->
                        "barchart"

                    PieChart ->
                        "piechart"

                    HeatMap ->
                        "heatmap"

                    Radar ->
                        "radar"

                    Parallel ->
                        "parallel"

                    Sankey ->
                        "sankey"

                    BoxPlot ->
                        "boxplot"

                    Graph ->
                        "graph"

                    Map ->
                        "map"

                    Funnel ->
                        "funnel"
          )
        , ( "head", JE.list cell table.head )
        , ( "format", JE.list JE.string table.format )
        , ( "body", JE.list (JE.list cell) table.body )
        , ( "id", JE.int table.id )
        ]


cell : ( Parameters, Inlines ) -> JE.Value
cell ( p, inlines ) =
    JE.object
        [ ( "cell", Inline.encode inlines )
        , ( "a", JE.null )
        ]
