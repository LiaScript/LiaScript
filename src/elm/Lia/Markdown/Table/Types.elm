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
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)


type alias Table =
    { class : Class
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


type alias Vector =
    Array State


type alias State =
    { column : Int
    , dir : Bool
    , diagram : Bool
    }


type alias Cell =
    { attr : Parameters
    , inlines : Inlines
    , string : String
    , float : Maybe Float
    }


toMatrix : Scripts a -> Maybe Int -> Matrix ( Parameters, Inlines ) -> Matrix Cell
toMatrix effects id =
    Matrix.map (toCell effects id)


toCell : Scripts a -> Maybe Int -> ( Parameters, Inlines ) -> Cell
toCell effects effectId ( attr, data ) =
    let
        str =
            data
                |> stringify_ effects effectId
                |> String.trim
    in
    str
        |> float
        |> Cell attr data str


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
