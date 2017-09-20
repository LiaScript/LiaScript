module Lia.Chart.Types exposing (..)


type alias Point =
    { x : Float, y : Float }


type Chart
    = Diagram (List Point)
