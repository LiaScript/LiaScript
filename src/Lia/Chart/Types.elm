module Lia.Chart.Types exposing (..)

import Dict exposing (Dict)


type alias Point =
    { x : Float
    , y : Float
    }


type alias Chart =
    { title : String
    , y_label : String
    , x_label : String
    , diagrams : Dict Char Diagram
    }


type Diagram
    = Line (List Point)
    | Dots (List Point)
