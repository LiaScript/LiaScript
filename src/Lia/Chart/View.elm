module Lia.Chart.View exposing (view)

import Char exposing (isLower, toLower)
import Dict exposing (Dict)
import Html exposing (Html)
import Lia.Chart.Types exposing (..)
import Plot
import Svg.Attributes as Attr


view : Chart -> Html msg
view chart =
    Html.div []
        [ Plot.viewSeriesCustom
            Plot.defaultSeriesPlotCustomizations
            (chart
                |> Dict.toList
                |> List.map plot
            )
            chart
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
