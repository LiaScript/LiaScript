module Lia.Markdown.Chart.Types exposing
    ( Chart
    , Diagram(..)
    , Labels
    , Point
    )

import Dict exposing (Dict)


type alias Point =
    { x : Float
    , y : Float
    }


type alias Chart =
    { title : String
    , yLabel : String
    , xLabel : String
    , legend : List String
    , diagrams : Dict Char Diagram
    }


type alias Labels =
    { main : Maybe String
    , x : Maybe String
    , y : Maybe String
    }


type Diagram
    = Lines (List Point) (Maybe String)
    | Dots (List Point) (Maybe String)
