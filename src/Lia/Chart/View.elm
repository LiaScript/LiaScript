module Lia.Chart.View exposing (view)

import Html exposing (Html)
import Lia.Chart.Types exposing (..)
import Plot
import Svg.Attributes as Attr


view : Chart -> Html msg
view chart =
    case chart of
        --        Diagram points ->
        --            Plot.viewSeries
        --                [ Plot.line (List.map (\{ x, y } -> Plot.circle x y)) ]
        --                points
        Diagram points ->
            Plot.viewSeriesCustom Plot.defaultSeriesPlotCustomizations
                [ { axis = Plot.normalAxis
                  , interpolation = Plot.Monotone Nothing [ Attr.stroke "black" ]
                  , toDataPoints = List.map (\{ x, y } -> Plot.circle x y)
                  }
                ]
                points
