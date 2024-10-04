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
import Lia.Markdown.Quiz.Multi.Types as Input
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)


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


type alias Vector =
    Array State


type alias State =
    { column : Int
    , dir : Bool
    , diagram : Bool
    }


type alias Cell =
    { id : String
    , attr : Parameters
    , inlines : Inlines
    , string : String
    , float : Maybe Float
    }


toMatrix :
    { config
        | scripts : Scripts a
        , visible : Maybe Int
        , input :
            { x
                | state : Input.State
                , options : Array (List Inlines)
            }
    }
    -> Matrix ( Parameters, Inlines )
    -> Matrix Cell
toMatrix config =
    Matrix.indexedMap (toCell config)


toCell :
    { config
        | scripts : Scripts a
        , visible : Maybe Int
        , input :
            { x
                | state : Input.State
                , options : Array (List Inlines)
            }
    }
    -> Int
    -> Int
    -> ( Parameters, Inlines )
    -> Cell
toCell config x y ( attr, data ) =
    let
        str =
            data
                |> stringify_ config
                |> String.trim
    in
    str
        |> float
        |> Cell (cellID x y) attr data str


cellID : Int -> Int -> String
cellID x y =
    String.fromInt x ++ "," ++ String.fromInt y


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
