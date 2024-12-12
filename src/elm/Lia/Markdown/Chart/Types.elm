module Lia.Markdown.Chart.Types exposing
    ( Chart
    , Data
    , Diagram(..)
    , Labels
    , Orientation(..)
    , Point
    , Settings
    , invertDiagram
    )

import Dict exposing (Dict)
import I18n.Translations exposing (Lang)
import Lia.Markdown.HTML.Attributes exposing (Parameters)


type alias Point =
    { x : Float
    , y : Float
    }


type Orientation
    = Horizontal
    | Vertical


type alias Chart =
    { title : String
    , yLabel : String
    , xLabel : String
    , legend : List String
    , diagrams : Dict Char Diagram
    , xLimits :
        { min : Maybe String
        , max : Maybe String
        }
    , yLimits :
        { min : Maybe String
        , max : Maybe String
        }
    , orientation : Maybe Orientation
    }


type alias Labels =
    { main : Maybe String
    , x : Maybe String
    , y : Maybe String
    , xLimits :
        { min : Maybe String
        , max : Maybe String
        }
    , yLimits :
        { min : Maybe String
        , max : Maybe String
        }
    }


type Diagram
    = Lines (List Point) (Maybe String)
    | Dots (List Point) (Maybe String)


type alias Settings =
    { lang : Lang
    , attr : Parameters
    , light : Bool
    }


type alias Data x =
    { labels : Labels
    , category : List String
    , data : List x
    , orientation : Maybe Orientation
    }


invertDiagram : Diagram -> Diagram
invertDiagram diagram =
    case diagram of
        Lines points color ->
            Lines (List.map swapXY points) color

        Dots points color ->
            Dots (List.map swapXY points) color


swapXY : Point -> Point
swapXY point =
    { x = point.y, y = point.x }
