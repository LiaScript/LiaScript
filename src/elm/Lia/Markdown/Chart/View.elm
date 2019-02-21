module Lia.Markdown.Chart.View exposing (view)

import Char exposing (isLower, toLower)
import Color
import Dict exposing (Dict)
import Html exposing (Html)
import Lia.Markdown.Chart.Types exposing (Chart, Diagram(..), Point)
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Coordinate as Coordinate
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line


title : String -> Coordinate.System -> Junk.Layers msg
title str system =
    { below = []
    , above =
        [ Junk.labelAt
            system
            (system.x.max / 2)
            system.y.max
            0
            -5
            "middle"
            Color.black
            str
        ]
    , html = []
    }


view : Annotation -> Chart -> Html msg
view attr chart =
    let
        list =
            chart
                |> .diagrams
                |> Dict.toList
                |> List.map plot
    in
    Html.div (annotation "lia-chart" attr)
        [ LineChart.viewCustom
            { y = Axis.default 450 chart.y_label (Tuple.first >> .y)
            , x = Axis.default 600 chart.x_label (Tuple.first >> .x)
            , container =
                Container.styled "lia-diagram"
                    [ ( "width", "100%" )
                    , ( "display", "inline" )
                    , ( "font-family", "monospace" )
                    ]
            , interpolation = Interpolation.monotone
            , intersection = Intersection.default
            , legends = Legends.none
            , events = Events.default
            , junk = Junk.custom (title chart.title)
            , grid = Grid.default
            , area = Area.default
            , line = Line.default
            , dots = customDotsConfig
            }
            list
        ]


plot : ( Char, Diagram ) -> LineChart.Series ( Point, Bool )
plot config =
    case config of
        ( c, Line points ) ->
            points
                |> dotSize c
                |> LineChart.line (get_color c) (dotType c) ""

        ( c, Dots points ) ->
            points
                |> dotSize c
                |> LineChart.dash (get_color c) (dotType c) "" [ 0, 50 ]


dotSize : Char -> List Point -> List ( Point, Bool )
dotSize c points =
    let
        small =
            Char.isLower c
    in
    List.map (\p -> ( p, small )) points


dotType : Char -> Dots.Shape
dotType c =
    case c of
        't' ->
            Dots.triangle

        'T' ->
            Dots.triangle

        'A' ->
            Dots.triangle

        'v' ->
            Dots.triangle

        'V' ->
            Dots.triangle

        '#' ->
            Dots.square

        'H' ->
            Dots.square

        'B' ->
            Dots.square

        'N' ->
            Dots.square

        '+' ->
            Dots.plus

        'x' ->
            Dots.cross

        'X' ->
            Dots.cross

        _ ->
            Dots.circle


customDotsConfig : Dots.Config ( Point, Bool )
customDotsConfig =
    let
        styleLegend _ =
            Dots.full 7

        styleIndividual ( _, small ) =
            Dots.full <|
                if small then
                    5

                else
                    12
    in
    Dots.customAny
        { legend = styleLegend
        , individual = styleIndividual
        }



{-

             let
                 plot_dot =
                     Plot.dot (dot c)
             in
             case ( c, type_ ) of
                 ( 'x', Line _ ) ->
                     Plot.line
                         (\dict ->
                             dict
                                 |> get_points c
                                 |> List.map (\{ x, y } -> plot_dot x y)
                         )

                 ( 'X', Line _ ) ->
                     Plot.line
                         (\dict ->
                             dict
                                 |> get_points c
                                 |> List.map (\{ x, y } -> plot_dot x y)
                         )

                 ( _, Line _ ) ->
                     { axis = Plot.normalAxis
                     , interpolation = Plot.Monotone Nothing [ Attr.stroke "black" ]
                     , toDataPoints =
                         \dict ->
                             dict
                                 |> get_points c
                                 |> List.map (\{ x, y } -> plot_dot x y)
                     }

                 ( _, Dots _ ) ->
                     Plot.dots
                         (\dict ->
                             dict
                                 |> get_points c
                                 |> List.map (\{ x, y } -> plot_dot x y)
                         )



   dot c =
          let
              size =
                  if isLower c then
                      5

                  else
                      8

              color =
                  get_color c
          in
          case c of
              '#' ->
                  Plot.viewSquare size color

              '+' ->
                  Plot.viewDiamond size size color

              't' ->
                  Plot.viewTriangle color

              _ ->
                  Plot.viewCircle size color

   {-

      get_points : Char -> Dict Char Diagram -> List Point
      get_points c dict =
          case Dict.get c dict of
              Just (Dots d) ->
                  d

              Just (Line d) ->
                  d

              _ ->
                  []

   -}
-}


colors : Dict Char Color.Color
colors =
    [ ( '*', Color.black )
    , ( '+', Color.black )
    , ( 'x', Color.black )
    , ( 'a', Color.rgb255 127 255 212 ) -- Aquamarine
    , ( 'b', Color.blue )
    , ( 'c', Colors.cyan )
    , ( 'd', Color.darkRed )
    , ( 'e', Color.grey )
    , ( 'f', Color.rgb255 230 230 250 ) -- Forest green
    , ( 'g', Color.green )
    , ( 'h', Color.rgb255 240 255 240 ) -- Honey dew
    , ( 'i', Color.rgb255 75 0 130 ) -- Indigo
    , ( 'j', Color.black ) -- navaJo white
    , ( 'k', Color.rgb255 240 230 140 ) -- Kaki
    , ( 'l', Color.rgb255 230 230 250 ) -- Lavender
    , ( 'm', Color.rgb255 255 0 255 ) -- Magenta
    , ( 'n', Color.brown )
    , ( 'o', Color.orange )
    , ( 'p', Colors.pink )
    , ( 'q', Color.rgb255 0 255 255 ) -- aQua
    , ( 'r', Colors.red )
    , ( 's', Colors.strongBlue )
    , ( 't', Colors.teal )
    , ( 'u', Colors.rust )
    , ( 'v', Colors.purple )
    , ( 'w', Color.white )
    , ( 'y', Color.yellow )
    , ( 'z', Color.rgb255 240 255 255 ) -- aZure
    ]
        |> Dict.fromList


get_color : Char -> Color.Color
get_color c =
    colors
        |> Dict.get (toLower c)
        |> Maybe.withDefault Color.black
