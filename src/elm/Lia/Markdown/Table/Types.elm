module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , State
    , Table
    , Vector
    , float
    , getColumn
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
                |> String.toLower
    in
    str
        |> float
        |> Cell data str


float : String -> Maybe Float
float =
    String.split " " >> List.head >> Maybe.andThen String.toFloat


getColumn : Int -> List Inlines -> List (List c) -> Maybe ( Maybe String, List c )
getColumn i head rows =
    case Matrix.column i rows of
        Just column ->
            Just
                ( head
                    |> List.head
                    |> Maybe.andThen (stringify >> String.trim >> isEmpty)
                , column
                )

        _ ->
            Nothing


isEmpty : String -> Maybe String
isEmpty str =
    if str == "" then
        Nothing

    else
        Just str


isNumber : Cell -> Bool
isNumber =
    .float >> (/=) Nothing
