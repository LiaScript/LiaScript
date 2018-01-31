module Lia.Chart.View exposing (view)

import Char exposing (isLower, toLower)
import Dict exposing (Dict)
import Html exposing (Html)
import Lia.Chart.Types exposing (..)
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation)
import Plot
import Svg.Attributes as Attr


title str summary =
    Plot.junk
        (Plot.viewLabel [ Attr.style "text-anchor: end; font-style: italic;" ] str)
        summary.x.dataMax
        summary.y.max


x_label str summary =
    Plot.junk
        (Plot.viewLabel [ Attr.style "text-anchor: begin; font-style: italic;" ] str)
        (summary.x.dataMax / 2.0)
        (summary.y.min - (summary.y.max - summary.y.min) / 9)


y_label str summary =
    Plot.junk
        (Plot.viewLabel [ Attr.style "text-anchor: begin; font-style: italic; transform: rotate(-90deg);" ] str)
        (summary.x.dataMin - (summary.x.dataMax - summary.x.dataMin) / 11)
        (summary.y.max / 2.0)


view : Annotation -> Chart -> Html msg
view attr chart =
    let
        custom =
            Plot.defaultSeriesPlotCustomizations
    in
    Html.div (annotation attr "lia-chart")
        [ Plot.viewSeriesCustom
            { custom
                | junk =
                    \summary ->
                        [ title chart.title summary
                        , x_label chart.x_label summary
                        , y_label chart.y_label summary
                        ]
                , margin = { top = 50, right = 50, bottom = 50, left = 60 }
            }
            (chart
                |> .diagrams
                |> Dict.toList
                |> List.map plot
            )
            chart.diagrams
        ]


plot : ( Char, Diagram ) -> Plot.Series (Dict Char Diagram) msg
plot ( c, type_ ) =
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


get_points : Char -> Dict Char Diagram -> List Point
get_points c dict =
    case Dict.get c dict of
        Just (Dots d) ->
            d

        Just (Line d) ->
            d

        _ ->
            []


colors : Dict Char String
colors =
    [ ( '*', "black" )
    , ( '+', "black" )
    , ( 'x', "black" )
    , ( 'a', "banana" )
    , ( 'b', "blue" )
    , ( 'c', "cyan" )
    , ( 'd', "darkred" )
    , ( 'e', "" )
    , ( 'f', "" )
    , ( 'g', "green" )
    , ( 'h', "" )
    , ( 'i', "indigo" )
    , ( 'j', "" )
    , ( 'k', "kaki" )
    , ( 'l', "lavender" )
    , ( 'm', "magenta" )
    , ( 'n', "navy" )
    , ( 'o', "orange" )
    , ( 'p', "" )
    , ( 'q', "pink" )
    , ( 'r', "red" )
    , ( 's', "salmon" )
    , ( 't', "turquoise" )
    , ( 'u', "" )
    , ( 'v', "violet" )
    , ( 'w', "white" )
    , ( 'y', "yellow" )
    , ( 'z', "" )
    ]
        |> Dict.fromList


get_color : Char -> String
get_color c =
    case Dict.get (toLower c) colors of
        Just col ->
            col

        _ ->
            "black"
