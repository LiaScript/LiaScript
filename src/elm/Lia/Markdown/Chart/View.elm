module Lia.Markdown.Chart.View exposing
    ( getColor
    , view
    , viewBarChart
    , viewChart
    , viewPieChart
    )

import Char exposing (isLower, toLower)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Chart, Diagram(..))
import Lia.Markdown.Inline.Annotation exposing (annotation)
import Lia.Markdown.Inline.Types exposing (Annotation)


view : Annotation -> Bool -> Chart -> Html msg
view attr light =
    encode True >> eCharts attr light


viewChart : Annotation -> Bool -> Chart -> Html msg
viewChart attr light =
    encode False >> eCharts attr light


viewBarChart : Annotation -> Bool -> String -> List String -> List ( Maybe String, List (Maybe Float) ) -> Html msg
viewBarChart attr light title category data =
    encodeBarChart title category data
        |> eCharts attr light


viewPieChart : Annotation -> Bool -> Maybe String -> Maybe String -> List ( String, Float ) -> Html msg
viewPieChart attr light title subtitle data =
    encodePieChart title subtitle data
        |> eCharts attr light


eCharts : Annotation -> Bool -> JE.Value -> Html msg
eCharts attr light option =
    Html.node "e-charts"
        (List.append
            [ Attr.attribute "mode" <|
                if light then
                    ""

                else
                    "dark"
            , option
                |> JE.encode 0
                |> Attr.attribute "option"
            ]
            (annotation "lia-chart" attr)
        )
        []


encodeBarChart : String -> List String -> List ( Maybe String, List (Maybe Float) ) -> JE.Value
encodeBarChart xLabel category data =
    let
        bars =
            data
                |> List.foldl
                    (\( label_, floats ) bs ->
                        if List.all ((==) Nothing) floats then
                            bs

                        else
                            JE.object
                                [ ( "type", JE.string "bar" )
                                , ( "name"
                                  , label_
                                        |> Maybe.map JE.string
                                        |> Maybe.withDefault JE.null
                                  )
                                , ( "barGap", JE.int 0 )
                                , label
                                , ( "data"
                                  , floats
                                        |> List.map (Maybe.map JE.float >> Maybe.withDefault JE.null)
                                        |> JE.list identity
                                  )
                                ]
                                :: bs
                    )
                    []
                |> JE.list identity
    in
    JE.object
        [ ( "xAxis"
          , JE.object
                [ ( "type", JE.string "category" )
                , ( "name", JE.string xLabel )
                , ( "data"
                  , category
                        |> JE.list JE.string
                  )
                ]
          )
        , ( "yAxis"
          , JE.object [ ( "type", JE.string "value" ) ]
          )

        --, ( "title", JE.object [ ( "text", JE.string chart.title ) ] )
        , ( "legend"
          , JE.object
                [ ( "data"
                  , data
                        |> List.unzip
                        |> Tuple.first
                        |> List.filterMap identity
                        |> JE.list JE.string
                  )
                ]
          )
        , toolbox

        --  , brush
        , ( "tooltip", JE.object [] )
        , ( "series", bars )
        ]


encodePieChart : Maybe String -> Maybe String -> List ( String, Float ) -> JE.Value
encodePieChart title subtitle data =
    let
        pieces =
            data
                |> List.map
                    (\( name_, value_ ) ->
                        JE.object
                            [ ( "name", JE.string name_ )
                            , ( "value", JE.float value_ )
                            ]
                    )
                |> JE.list identity

        head =
            if title /= Nothing || subtitle /= Nothing then
                [ ( "title"
                  , JE.object
                        [ ( "text"
                          , title |> Maybe.withDefault "" |> JE.string
                          )
                        , ( "subtext", subtitle |> Maybe.withDefault "" |> JE.string )
                        , ( "left", JE.string "center" )
                        ]
                  )
                ]

            else
                []
    in
    [ ( "series"
      , [ JE.object
            [ ( "type", JE.string "pie" )
            , ( "radius"
              , JE.string <|
                    if title /= Nothing || subtitle /= Nothing then
                        "65%"

                    else
                        "75%"
              )
            , ( "center", JE.list JE.string [ "50%", "50%" ] )
            , ( "selectedMode", JE.string "single" )
            , ( "data", pieces )
            ]
        ]
            |> JE.list identity
      )
    , toolbox

    --, ( "legend"
    --  , JE.object
    --        [ ( "data"
    --          , data
    --                |> List.map Tuple.first
    --                |> JE.list JE.string
    --          )
    --, ( "right", JE.int 0 )
    --        , ( "top", JE.int 28 )
    --        ]
    --  )
    --  , brush
    , ( "tooltip", JE.object [] )
    ]
        |> List.append head
        |> JE.object


label : ( String, JE.Value )
label =
    ( "label"
    , JE.object
        [ ( "normal"
          , JE.object
                [ ( "show", JE.bool False )
                , ( "position", JE.string "top" )
                ]
          )
        ]
    )


encode : Bool -> Chart -> JE.Value
encode withColor chart =
    JE.object
        [ ( "textStyle"
          , JE.object
                [ ( "fontFamily", JE.string "Roboto" )
                ]
          )
        , ( "xAxis"
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
        , ( "legend"
          , JE.object
                [ ( "data", JE.list JE.string chart.legend )

                --, ( "right", JE.int 0 )
                , ( "top", JE.int 28 )
                ]
          )
        , toolbox

        --  , brush
        , ( "tooltip", JE.object [] )
        , ( "series"
          , chart.diagrams
                |> Dict.toList
                |> JE.list (series withColor)
          )
        ]


brush : ( String, JE.Value )
brush =
    ( "brush"
    , JE.object
        [ ( "toolbox"
          , JE.list JE.string [ "rect", "polygon", "lineX", "lineY", "keep", "clear" ]
          )
        ]
    )


toolbox : ( String, JE.Value )
toolbox =
    ( "toolbox"
    , JE.object
        [ ( "bottom", JE.int 8 )
        , ( "left", JE.string "center" )
        , ( "feature"
          , JE.object
                [ ( "saveAsImage", JE.object [ ( "title", JE.string "store" ) ] )
                , ( "dataView"
                  , JE.object
                        [ ( "title", JE.string "edit" )
                        , ( "lang", JE.list JE.string [ "data view", "turn off", "refresh" ] )
                        ]
                  )
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
                , ( "magicType"
                  , JE.object
                        [ ( "type"
                          , JE.list JE.string
                                [ "tiled"
                                , "line"
                                , "bar"
                                ]
                          )
                        , ( "title"
                          , JE.object
                                [ ( "stack", JE.string "stack" )
                                , ( "tiled", JE.string "tiled" )
                                , ( "line", JE.string "line" )
                                , ( "bar", JE.string "bar" )
                                ]
                          )
                        ]
                  )
                ]
          )
        ]
    )


series : Bool -> ( Char, Diagram ) -> JE.Value
series withColor ( char, diagram ) =
    JE.object <|
        List.append
            ([ symbol char
             , symbolSize char
             , label
             ]
                ++ (if withColor then
                        [ color char ]

                    else
                        []
                   )
            )
        <|
            case diagram of
                Lines list label_ ->
                    [ ( "data"
                      , list
                            |> List.map (\point -> JE.list JE.float [ point.x, point.y ])
                            |> JE.list identity
                      )
                    , ( "type", JE.string "line" )
                    , ( "barGap", JE.int 0 )
                    , style withColor char
                    , smooth withColor char
                    ]
                        ++ name label_

                Dots list label_ ->
                    [ ( "data"
                      , list
                            |> List.map (\point -> JE.list JE.float [ point.x, point.y ])
                            |> JE.list identity
                      )
                    , ( "barGap", JE.int 0 )
                    , ( "type", JE.string "scatter" )
                    ]
                        ++ name label_


name : Maybe String -> List ( String, JE.Value )
name label_ =
    case label_ of
        Nothing ->
            []

        Just str ->
            [ ( "name", JE.string str ) ]


style : Bool -> Char -> ( String, JE.Value )
style withColor char =
    ( "lineStyle"
    , JE.object
        [ ( "type"
          , JE.string <|
                if withColor then
                    if modBy 7 (Char.toCode char) == 0 then
                        "dashed"

                    else if modBy 5 (Char.toCode char) == 0 then
                        "dotted"

                    else
                        "solid"

                else
                    "solid"
          )
        ]
    )


smooth : Bool -> Char -> ( String, JE.Value )
smooth withColor char =
    ( "smooth"
    , if withColor then
        char
            |> Char.toCode
            |> modBy 2
            |> (==) 0
            |> JE.bool

      else
        JE.bool False
    )


symbolSize : Char -> ( String, JE.Value )
symbolSize c =
    ( "symbolSize"
    , JE.int <|
        if Char.isLower c then
            5

        else
            10
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


getColor : Int -> Char
getColor i =
    "*abcdefghijklmnopqrstuvwxyz+ABCDEFGHIJKLMNOPQRSTUVWXYZ#1234567890!§$%&/()=?'_.,;:<>|^°~"
        |> String.slice i -1
        |> String.uncons
        |> Maybe.map Tuple.first
        |> Maybe.withDefault '~'
