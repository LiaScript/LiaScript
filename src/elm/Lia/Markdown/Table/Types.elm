module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , State
    , Table
    , Vector
    , className
    , isNumber
    , toCell
    , toMatrix
    )

import Array exposing (Array)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Stringify as Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)


{-| A parsed table:

  - `class`: the diagram it can be shown as, `None` for plain tables
  - `head`: the header row, empty for simple tables without format line
  - `format`: alignment classes from the format line (`:--`, `--:`, ...)
  - `id`: index of the table's `State` within the section's `Vector`

-}
type alias Table =
    { class : Class
    , sortable : Bool
    , head : List ( Parameters, Inlines )
    , format : List String
    , body : List (List ( Parameters, Inlines ))
    , id : Int
    }


type Class
    = None
    | LinePlot
    | ScatterPlot
    | BarChart
    | PieChart
    | HeatMap
    | Radar
    | Parallel
    | Sankey
    | BoxPlot
    | Graph
    | Map
    | Funnel


{-| The name of a diagram type, as used for `data-type`, the JSON export and
the toggle button icons (`icon-<name>`).
-}
className : Class -> String
className class =
    case class of
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


{-| The view states of all tables within a section, indexed by `Table.id`.
-}
type alias Vector =
    Array State


{-| `column` is the sorted column (-1 for unsorted), `dir` is `True` for
ascending order, `diagram` is toggled by the table/diagram button.
-}
type alias State =
    { column : Int
    , dir : Bool
    , diagram : Bool
    }


{-| A cell with its plain text and the number its text starts with.
-}
type alias Cell =
    { attr : Parameters
    , inlines : Inlines
    , string : String
    , float : Maybe Float
    }


toMatrix : Stringify.Config config input a -> Matrix ( Parameters, Inlines ) -> Matrix Cell
toMatrix config =
    Matrix.map (toCell config)


toCell : Stringify.Config config input a -> ( Parameters, Inlines ) -> Cell
toCell config ( attr, inlines ) =
    let
        string =
            inlines
                |> stringify_ config
                |> String.trim
    in
    { attr = attr
    , inlines = inlines
    , string = string
    , float =
        -- "12.5 kg" is a number with a unit, "5. April" an ordinal and
        -- "44 % mittlerer Abschluss" text
        case String.words string of
            [ number ] ->
                toFloat number

            [ number, _ ] ->
                toFloat number

            _ ->
                Nothing
    }


toFloat : String -> Maybe Float
toFloat number =
    if String.endsWith "." number then
        Nothing

    else
        String.toFloat number


isNumber : Cell -> Bool
isNumber =
    .float >> (/=) Nothing
