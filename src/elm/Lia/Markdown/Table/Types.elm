module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , State
    , Table
    , Vector
    , float
    , isNumber
    , toCell
    , toMatrix
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Stringify exposing (stringify, stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
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
    | Graph
    | Map


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


toMatrix : Maybe Int -> Matrix Inlines -> Matrix Cell
toMatrix id =
    Matrix.map (toCell id)


toCell : Maybe Int -> Inlines -> Cell
toCell effectId data =
    let
        str =
            data
                |> stringify_ effectId
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
