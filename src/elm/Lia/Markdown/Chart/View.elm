module Lia.Markdown.Chart.View exposing (view)

import Char exposing (isLower, toLower)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Chart, Diagram(..), Point)
import Lia.Markdown.Inline.Types exposing (Annotation)
import Lia.Markdown.Inline.View exposing (annotation)


view : Annotation -> Bool -> Chart -> Html msg
view attr light chart =
    Html.node "e-charts"
        (List.append
            [ encode chart
                |> Attr.attribute "option"
            ]
            (annotation "lia-chart" attr)
        )
        []


encode : Chart -> String
encode chart =
    JE.encode 0 <|
        JE.object
            [ ( "xAxis"
              , JE.object
                    [ ( "type", JE.string "value" )
                    , ( "name", JE.string chart.xLabel )
                    ]
              )
            , ( "yAxis"
              , JE.object
                    [ ( "type", JE.string "value" )
                    , ( "name", JE.string chart.yLabel )
                    ]
              )
            , ( "title", JE.object [ ( "text", JE.string chart.title ) ] )
            , ( "legend", JE.object [ ( "data", JE.list JE.string chart.legend ) ] )
            , ( "toolbox"
              , JE.object
                    [ ( "feature"
                      , JE.object
                            [ ( "saveAsImage", JE.object [ ( "title", JE.string "store" ) ] )
                            , ( "dataView", JE.object [ ( "title", JE.string "data" ) ] )
                            , ( "dataZoom"
                              , JE.object
                                    [ ( "title"
                                      , JE.object
                                            [ ( "zoom", JE.string "zoom" )
                                            , ( "back", JE.string "back" )
                                            ]
                                      )
                                    ]
                              )
                            ]
                      )
                    ]
              )
            , ( "tooltip", JE.object [] )
            , ( "series"
              , chart.diagrams
                    |> Dict.toList
                    |> JE.list series
              )
            ]


series : ( Char, Diagram ) -> JE.Value
series ( char, diagram ) =
    JE.object <|
        List.append
            [ symbol char
            , symbolSize char
            , color char
            ]
        <|
            case diagram of
                Line list label ->
                    [ ( "data"
                      , list
                            |> List.map (\point -> JE.list JE.float [ point.x, point.y ])
                            |> JE.list identity
                      )
                    , ( "type", JE.string "line" )
                    , smooth char
                    ]
                        ++ name label

                Dots list label ->
                    [ ( "data"
                      , list
                            |> List.map (\point -> JE.list JE.float [ point.x, point.y ])
                            |> JE.list identity
                      )
                    , ( "type", JE.string "scatter" )
                    ]
                        ++ name label


name : Maybe String -> List ( String, JE.Value )
name label =
    case label of
        Nothing ->
            []

        Just str ->
            [ ( "name", JE.string str ) ]


smooth : Char -> ( String, JE.Value )
smooth char =
    ( "smooth"
    , char
        |> Char.toCode
        |> modBy 2
        |> (==) 0
        |> JE.bool
    )


symbolSize : Char -> ( String, JE.Value )
symbolSize c =
    ( "symbolSize"
    , JE.int <|
        if Char.isLower c then
            10

        else
            16
    )


symbol : Char -> ( String, JE.Value )
symbol c =
    ( "symbol"
    , JE.string <|
        case c of
            'd' ->
                "diamond"

            'D' ->
                "diamond"

            't' ->
                "triangle"

            'T' ->
                "triangle"

            'A' ->
                "arrow"

            'v' ->
                "triangle"

            'V' ->
                "triangle"

            '#' ->
                "rect"

            'H' ->
                "rect"

            'B' ->
                "roundRect"

            'N' ->
                "roundRect"

            'p' ->
                "pin"

            'P' ->
                "pin"

            '+' ->
                "diamond"

            'x' ->
                "rect"

            'X' ->
                "rect"

            _ ->
                "circle"
    )


colors : Dict Char String
colors =
    [ ( '*', "#000000" )
    , ( '+', "#000000" )
    , ( 'x', "#000000" )
    , ( 'a', "#FFBF00" ) -- Amber
    , ( 'b', "#0000FF" ) -- Blue
    , ( 'c', "#00FFFF" ) -- Cyan
    , ( 'd', "#8B0000" ) -- Dark red
    , ( 'e', "#555D50" ) -- Ebony
    , ( 'f', "#014421" ) -- Forest green
    , ( 'g', "#008000" ) -- Green
    , ( 'h', "#DF73FF" ) -- Heliotrope
    , ( 'i', "#4B0082" ) -- Indigo
    , ( 'j', "#00A86B" ) -- Jade
    , ( 'k', "#C3B091" ) -- Kaki
    , ( 'l', "#00FF00" ) -- Lime
    , ( 'm', "#3EB489" ) -- Mint
    , ( 'n', "#88540B" ) -- browN
    , ( 'o', "#FF7F00" ) -- Orange
    , ( 'p', "#FFC0CB" ) -- Pink
    , ( 'q', "#436B95" ) -- Queen blue
    , ( 'r', "#FF0000" ) -- Red
    , ( 's', "#C0C0C0" ) -- Silver
    , ( 't', "#008080" ) -- Teal
    , ( 'u', "#3F00FF" ) -- Ultramarine
    , ( 'v', "#EE82EE" )
    , ( 'w', "#FFFFFF" )
    , ( 'y', "#FFFF00" )
    , ( 'z', "#39A78E" ) -- Zomp
    ]
        |> Dict.fromList


color : Char -> ( String, JE.Value )
color char =
    ( "itemStyle"
    , JE.object
        [ ( "color"
          , colors
                |> Dict.get (toLower char)
                |> Maybe.withDefault "#000000"
                |> JE.string
          )
        ]
    )
