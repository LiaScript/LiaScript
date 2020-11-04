module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , State
    , Table
    , Vector
    , isEmpty
    , isNumber
    , toCell
    , toMatrix
    )

import Array exposing (Array)
import Lia.Markdown.Effect.Script.Types exposing (Script)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)


type alias Table =
    { class : Class
    , head : List Inlines
    , format : List String
    , body : List (List Inlines)
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


type alias Vector =
    Array State


type alias State =
    { column : Int
    , dir : Bool
    , diagram : Bool
    }


type alias Cell =
    { inlines : Inlines
    , string : String
    , float : Maybe Float
    }


toMatrix : Array Script -> Maybe Int -> Matrix Inlines -> Matrix Cell
toMatrix effects id =
    Matrix.map (toCell effects id)


toCell : Array Script -> Maybe Int -> Inlines -> Cell
toCell effects effectId data =
    let
        str =
            data
                |> stringify_ effects effectId
                |> String.trim
    in
    str
        |> float
        |> Cell data str


float : String -> Maybe Float
float =
    String.split " " >> List.head >> Maybe.andThen String.toFloat


isEmpty : String -> Maybe String
isEmpty str =
    if str == "" then
        Nothing

    else
        Just str


isNumber : Cell -> Bool
isNumber =
    .float >> (/=) Nothing
