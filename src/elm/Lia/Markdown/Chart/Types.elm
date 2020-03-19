module Lia.Markdown.Chart.Types exposing (Chart, Diagram(..), Point)

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


type Diagram
    = Line (List Point) (Maybe String)
    | Dots (List Point) (Maybe String)
