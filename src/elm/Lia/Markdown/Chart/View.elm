module Lia.Markdown.Chart.View exposing
    ( getColor
    , view
    , viewBarChart
    , viewBoxPlot
    , viewChart
    , viewFunnel
    , viewGraph
    , viewHeatMap
    , viewLines
    , viewMapChart
    , viewParallel
    , viewPieChart
    , viewPoints
    , viewRadarChart
    , viewSankey
    )

import Char exposing (toLower)
import Dict exposing (Dict)
import FStatistics
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Chart, Diagram(..), Labels)
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)


view : Parameters -> Bool -> Chart -> Html msg
view attr light =
    encode True >> eCharts attr light Nothing


viewChart : Parameters -> Bool -> Chart -> Html msg
viewChart attr light =
    encode False >> eCharts attr light Nothing


viewLines :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List ( String, List (Maybe Float) )
    -> Html msg
viewLines attr light labels category data =
    encodeBasic "line" labels category data
        |> eCharts attr light Nothing


viewPoints :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List ( String, List (Maybe Float) )
    -> Html msg
viewPoints attr light labels category data =
    encodeBasic "scatter" labels category data
        |> eCharts attr light Nothing


viewBarChart :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List ( Maybe String, List (Maybe Float) )
    -> Html msg
viewBarChart attr light labels category data =
    encodeBarChart labels category data
        |> eCharts attr light Nothing


viewBoxPlot :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List (List (Maybe Float))
    -> Html msg
viewBoxPlot attr light labels category data =
    encodeBoxPlot labels category data
        |> eCharts attr light Nothing


viewParallel :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List (List (Maybe Float))
    -> Html msg
viewParallel attr light labels category data =
    encodeParallel labels category data
        |> eCharts attr light Nothing


viewGraph :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List ( String, String, Float )
    -> Html msg
viewGraph attr light labels nodes edges =
    encodeGraph labels nodes edges
        |> eCharts attr light Nothing


viewSankey :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List ( String, String, Float )
    -> Html msg
viewSankey attr light labels nodes edges =
    encodeSankey labels nodes edges
        |> eCharts attr light Nothing


viewRadarChart : Parameters -> Bool -> Labels -> List String -> List ( String, List (Maybe Float) ) -> Html msg
viewRadarChart attr light labels category data =
    encodeRadarChart labels category data
        |> eCharts attr light Nothing


viewMapChart : Parameters -> Bool -> Labels -> List ( String, Maybe Float ) -> Maybe String -> Html msg
viewMapChart attr light labels data json =
    encodeMapChart labels data json
        |> eCharts attr light json


viewPieChart :
    Int
    -> Parameters
    -> Bool
    -> Labels
    -> Maybe (List String)
    -> List (List ( String, Float ))
    -> Html msg
viewPieChart width attr light labels subtitle data =
    encodePieChart width labels subtitle data
        |> eCharts attr light Nothing


viewFunnel :
    Int
    -> Parameters
    -> Bool
    -> Labels
    -> Maybe (List String)
    -> List (List ( String, Float ))
    -> Html msg
viewFunnel _ attr light labels subtitle data =
    encodeFunnel labels subtitle data
        |> eCharts attr light Nothing


viewHeatMap :
    Parameters
    -> Bool
    -> Labels
    -> List String
    -> List String
    -> List (List ( Int, Int, Maybe Float ))
    -> Html msg
viewHeatMap attr light labels x y data =
    encodeHeatMap labels x y data
        |> eCharts attr light Nothing


eCharts : Parameters -> Bool -> Maybe String -> JE.Value -> Html msg
eCharts attr light json option =
    Html.node "lia-chart"
        (List.append
            [ Attr.attribute "mode" <|
                if light then
                    ""

                else
                    "dark"
            , Attr.property "option" option
            , json
                |> Maybe.withDefault ""
                |> Attr.attribute "json"
            ]
            (annotation "lia-chart" attr)
        )
        []


minMax : List comparable -> Maybe ( comparable, comparable )
minMax list =
    case list of
        [] ->
            Nothing

        l :: ls ->
            ls
                |> List.foldl
                    (\value ( min, max ) ->
                        ( if value < min then
                            value

                          else
                            min
                        , if value > max then
                            value

                          else
                            max
                        )
                    )
                    ( l, l )
                |> Just


encodeGraph : Labels -> List String -> List ( String, String, Float ) -> JE.Value
encodeGraph labels nodes edges =
    let
        ( min, max ) =
            edges
                |> List.map (\( _, _, v ) -> v)
                |> minMax
                |> Maybe.withDefault ( 0, 0 )

        lineWidth v =
            1 + (4 * abs v / (max - min))

        dict =
            edges
                |> List.map (\( source, target, val ) -> ( ( source, target ), val ))
                |> Dict.fromList

        directed =
            dict
                |> Dict.map (\( s, t ) v -> Dict.get ( t, s ) dict == Just v)
                |> Dict.values
                |> List.all identity
    in
    [ toolbox Nothing { saveAsImage = True, dataView = False, dataZoom = False, magicType = False }
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ ( "type", JE.string "graph" )
        , ( "layout", JE.string "force" )
        , ( "label", JE.object [ ( "show", JE.bool True ) ] )
        , ( "symbolSize", JE.float 40 )
        , ( "roam", JE.bool True )
        , ( "animation", JE.bool True )

        --, ( "animationDurationUpdate", JE.int 30000 )
        , ( "edgeSymbol"
          , JE.list JE.string <|
                if directed then
                    []

                else
                    [ "circle", "arrow" ]
          )
        , ( "force"
          , JE.object
                [ ( "repulsion", JE.int 300 )
                , ( "edgeLength", JE.int 100 )
                , ( "gravity", JE.float 0.1 )
                ]
          )
        , ( "draggable", JE.bool True )
        , ( "data"
          , nodes
                |> List.map
                    (\node ->
                        [ ( "id", JE.string node )
                        , ( "name", JE.string node )

                        --, ( "fixed", JE.bool True )
                        --, ( "x", JE.int 100 )
                        --, ( "y", JE.int 100 )
                        ]
                    )
                |> JE.list JE.object
          )
        , ( "edges"
          , edges
                |> List.map
                    (\( source, target, v ) ->
                        [ ( "source", JE.string source )
                        , ( "target", JE.string target )
                        , ( "symbolSize", JE.list JE.int [ 5 ] )
                        , ( "value", JE.float v )
                        , ( "lineStyle"
                          , [ ( "width", JE.float <| lineWidth v )
                            , ( "curveness"
                              , JE.float <|
                                    if directed then
                                        0

                                    else if Dict.get ( target, source ) dict == Nothing then
                                        0

                                    else
                                        0.25
                              )
                            , ( "opacity"
                              , JE.float <|
                                    if v > 0 then
                                        0.9

                                    else
                                        0.3
                              )
                            ]
                                |> JE.object
                          )
                        ]
                    )
                |> JE.list JE.object
          )
        ]
            |> List.singleton
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeSankey : Labels -> List String -> List ( String, String, Float ) -> JE.Value
encodeSankey labels nodes edges =
    let
        dict =
            edges
                |> List.map (\( source, target, val ) -> ( ( source, target ), val ))
                |> Dict.fromList

        cleared =
            dict
                |> Dict.toList
                |> List.foldl
                    (\( ( s, t ), _ ) d ->
                        if Dict.get ( t, s ) d /= Nothing then
                            Dict.remove ( t, s ) d

                        else
                            d
                    )
                    dict
                |> Dict.toList
    in
    [ toolbox Nothing { saveAsImage = True, dataView = False, dataZoom = False, magicType = False }
    , ( "tooltip", JE.object [] )
    , ( "height", JE.string "80%" )
    , ( "width", JE.string "90%" )
    , ( "series"
      , [ ( "type", JE.string "sankey" )
        , ( "layout", JE.string "none" )
        , ( "focusNodeAdjacency", JE.string "allEdges" )
        , ( "animation", JE.bool True )
        , ( "data"
          , nodes
                |> List.map (\node -> [ ( "name", JE.string node ) ])
                |> JE.list JE.object
          )
        , ( "edges"
          , cleared
                |> List.map
                    (\( ( source, target ), v ) ->
                        [ ( "source", JE.string source )
                        , ( "target", JE.string target )
                        , ( "value", JE.float v )
                        ]
                    )
                |> JE.list JE.object
          )
        , ( "lineStyle", JE.object [ ( "color", JE.string "source" ) ] )
        ]
            |> List.singleton
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeBoxPlot : Labels -> List String -> List (List (Maybe Float)) -> JE.Value
encodeBoxPlot labels category data =
    let
        boxplots =
            data
                |> List.map (List.filterMap identity)
                |> List.map List.sort
                |> List.map2
                    (\c data_ ->
                        case
                            ( FStatistics.percentile 0.25 data_
                            , FStatistics.median data_
                            , FStatistics.percentile 0.75 data_
                            )
                        of
                            ( Just q1, Just q2, Just q3 ) ->
                                let
                                    ( min, max ) =
                                        data_
                                            |> FStatistics.minmax
                                            |> Maybe.map
                                                (\( min_, max_ ) ->
                                                    let
                                                        whisker1 =
                                                            q1 - 1.5 * (q3 - q1)

                                                        whisker2 =
                                                            q3 + 1.5 * (q3 - q1)
                                                    in
                                                    ( if whisker1 < min_ then
                                                        min_

                                                      else
                                                        whisker1
                                                    , if whisker2 > max_ then
                                                        max_

                                                      else
                                                        whisker2
                                                    )
                                                )
                                            |> Maybe.withDefault ( q1, q3 )
                                in
                                Just
                                    ( c
                                    , ( [ min
                                        , q1
                                        , q2
                                        , q3
                                        , max
                                        ]
                                      , List.filter (\x -> x > max || x < min) data_
                                      )
                                    )

                            _ ->
                                Nothing
                    )
                    category
                |> List.filterMap identity
    in
    [ ( "xAxis"
      , JE.object
            ([ ( "type", JE.string "category" )

             --, ( "name", JE.string xLabel )
             , ( "data"
               , boxplots
                    |> List.map Tuple.first
                    |> JE.list JE.string
               )
             ]
                ++ (labels.x
                        |> Maybe.map (\title -> [ ( "name", JE.string title ) ])
                        |> Maybe.withDefault []
                   )
            )
      )
    , yAxis "value" labels.y []
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = True, magicType = False }

    --  , brush
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ [ ( "type", JE.string "boxplot" )
          , ( "data"
            , boxplots
                |> List.map (Tuple.second >> Tuple.first >> JE.list JE.float)
                |> JE.list identity
            )
          ]
        , [ ( "type", JE.string "scatter" )
          , ( "name", JE.string "outlier" )
          , ( "data"
            , boxplots
                |> List.map (Tuple.second >> Tuple.second)
                |> List.indexedMap
                    (\i data_ ->
                        toFloat i
                            :: data_
                            |> JE.list JE.float
                    )
                |> JE.list identity
            )
          ]
        ]
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeBarChart : Labels -> List String -> List ( Maybe String, List (Maybe Float) ) -> JE.Value
encodeBarChart labels category data =
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
                ([ ( "type", JE.string "category" )

                 --, ( "name", JE.string xLabel )
                 , ( "data"
                   , category
                        |> JE.list JE.string
                   )
                 ]
                    ++ (labels.x
                            |> Maybe.map (\title -> [ ( "name", JE.string title ) ])
                            |> Maybe.withDefault []
                       )
                )
          )
        , yAxis "value" labels.y []

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
        , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = True, magicType = True }

        --  , brush
        , ( "tooltip", JE.object [] )
        , ( "series", bars )
        ]


encodeBasic : String -> Labels -> List String -> List ( String, List (Maybe Float) ) -> JE.Value
encodeBasic type_ labels category data =
    [ xAxis Nothing "category" labels.x category
    , yAxis "value" labels.y []
    , data
        |> List.map Tuple.first
        |> encodeLegend [ ( "top", JE.string "30px" ) ]
    , ( "tooltip", JE.object [] )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = True, magicType = True }
    , ( "series"
      , data
            |> JE.list
                (\( name_, values ) ->
                    JE.object
                        [ ( "name", JE.string name_ )
                        , ( "type", JE.string type_ )
                        , ( "data"
                          , values
                                |> JE.list (Maybe.map JE.float >> Maybe.withDefault JE.null)
                          )
                        ]
                )
      )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


encodeParallel : Labels -> List String -> List (List (Maybe Float)) -> JE.Value
encodeParallel labels category data =
    [ ( "parallelAxis"
      , category
            |> List.indexedMap (\i cat -> [ ( "dim", JE.int i ), ( "name", JE.string cat ) ])
            |> JE.list JE.object
      )
    , ( "parallel"
      , [ ( "axisExpandable", JE.bool True )
        , ( "axisExpandCenter", JE.int 15 )
        , ( "axisExpandCount", JE.int 10 )
        , ( "axisExpandWidth", JE.int 100 )
        , ( "axisExpandTriggerOn", JE.string "mousemove" )
        ]
            |> JE.object
      )
    , ( "series"
      , [ ( "type", JE.string "parallel" )
        , ( "data"
          , data
                |> List.map
                    (List.map (Maybe.map JE.float >> Maybe.withDefault JE.null) >> JE.list identity)
                |> JE.list identity
          )
        ]
            |> JE.object
      )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }

    --  , brush
    , ( "tooltip", JE.object [] )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


encodeMapChart : Labels -> List ( String, Maybe Float ) -> Maybe String -> JE.Value
encodeMapChart labels data json =
    let
        ( min, max ) =
            data
                |> List.filterMap Tuple.second
                |> minMax
                |> Maybe.withDefault ( 0, 0 )
    in
    [ ( "series"
      , [ JE.object
            [ ( "type", JE.string "map" )
            , ( "map"
              , json
                    |> Maybe.withDefault ""
                    |> JE.string
              )
            , ( "data"
              , data
                    |> List.filterMap
                        (\( key, value ) ->
                            case value of
                                Just num ->
                                    [ ( "name", JE.string key )
                                    , ( "value", JE.float num )
                                    ]
                                        |> JE.object
                                        |> Just

                                _ ->
                                    Nothing
                        )
                    |> JE.list identity
              )
            ]
        ]
            |> JE.list identity
      )
    , ( "visualMap"
      , JE.object
            [ ( "min", JE.float min )
            , ( "max", JE.float max )
            , ( "calculable", JE.bool True )
            , ( "itemHeight", JE.string "150px" )
            , ( "right", JE.string "0" )
            , ( "bottom", JE.string "center" )
            , ( "orient", JE.string "vertical" )
            ]
      )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }
    , ( "tooltip", JE.object [] )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


add : (a -> b) -> Maybe a -> List b -> List b
add transform to list =
    case to of
        Just data ->
            transform data :: list

        Nothing ->
            list


calcMax : List { x | max : Float } -> List (Maybe Float) -> List { x | max : Float }
calcMax =
    List.map2
        (\i d ->
            let
                value =
                    Maybe.withDefault 0 d
            in
            if value > i.max then
                { i | max = value }

            else
                i
        )


encodeRadarChart : Labels -> List String -> List ( String, List (Maybe Float) ) -> JE.Value
encodeRadarChart labels category data =
    let
        max_ =
            category
                |> List.map (\c -> { name = c, max = 0 })

        indicator =
            data
                |> List.map Tuple.second
                |> List.foldl (\d i -> calcMax i d) max_
                |> List.map
                    (\i ->
                        JE.object
                            [ ( "name", JE.string i.name )
                            , ( "max", JE.float i.max )
                            ]
                    )
                |> JE.list identity

        values =
            data
                |> List.map
                    (\( name_, value ) ->
                        [ ( "name", JE.string name_ )
                        , ( "value"
                          , value
                                |> List.map (Maybe.withDefault 0 >> JE.float)
                                |> JE.list identity
                          )
                        ]
                    )
                |> JE.list JE.object
    in
    [ ( "radar"
      , JE.object
            [ ( "indicator", indicator )
            , ( "name"
              , JE.object
                    [ ( "textStyle"
                      , JE.object
                            [ ( "color", JE.string "#fff" )
                            , ( "backgroundColor", JE.string "#999" )
                            , ( "borderRadius", JE.int 3 )
                            , ( "padding", JE.list JE.int [ 3, 5 ] )
                            ]
                      )
                    ]
              )
            ]
      )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ JE.object
            [ ( "type", JE.string "radar" )
            , ( "data", values )
            , ( "emphasis"
              , JE.object
                    [ ( "lineStyle"
                      , JE.object
                            [ ( "width", JE.int 4 )
                            ]
                      )
                    ]
              )
            ]
        ]
            |> JE.list identity
      )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


encodeTitle : Maybe ( String, String ) -> String -> ( String, JE.Value )
encodeTitle position title =
    ( "title"
    , [ ( "text", JE.string title ) ]
        |> add (Tuple.mapSecond JE.string) position
        |> JE.object
    )


encodeLegend : List ( String, JE.Value ) -> List String -> ( String, JE.Value )
encodeLegend params data =
    ( "legend"
    , ( "data", JE.list JE.string data )
        :: params
        |> JE.object
    )


xAxis : Maybe ( Float, Float ) -> String -> Maybe String -> List String -> ( String, JE.Value )
xAxis =
    axis True


yAxis : String -> Maybe String -> List String -> ( String, JE.Value )
yAxis =
    axis False Nothing


axis : Bool -> Maybe ( Float, Float ) -> String -> Maybe String -> List String -> ( String, JE.Value )
axis x min_max type_ title data =
    ( if x then
        "xAxis"

      else
        "yAxis"
    , [ ( "type", JE.string type_ ) ]
        |> add (Tuple.first >> JE.float >> Tuple.pair "min") min_max
        |> add (Tuple.second >> JE.float >> Tuple.pair "max") min_max
        |> add (JE.string >> Tuple.pair "name") title
        |> List.append
            (if data == [] then
                []

             else
                [ ( "data", JE.list JE.string data )
                , ( "splitArea", JE.object [ ( "show", JE.bool True ) ] )
                ]
            )
        |> JE.object
    )


encodeHeatMap : Labels -> List String -> List String -> List (List ( Int, Int, Maybe Float )) -> JE.Value
encodeHeatMap labels xLabels yLabels data =
    let
        ( min, max ) =
            data
                |> List.concat
                |> List.filterMap (\( _, _, v ) -> v)
                |> minMax
                |> Maybe.withDefault ( 0, 0 )
    in
    [ toolbox (Just "7%") { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }
    , ( "tooltip", JE.object [] )
    , ( "grid"
      , JE.object <|
            if labels.main == Nothing then
                [ ( "height", JE.string "82%" )
                , ( "top", JE.string "0%" )

                --, ( "width", JE.string "100%" )
                ]

            else
                [ ( "height", JE.string "74%" )
                , ( "top", JE.string "7%" )

                --, ( "width", JE.string "100%" )
                ]
      )
    , xAxis Nothing "category" labels.x xLabels
    , yAxis "category" labels.y yLabels
    , ( "visualMap"
      , JE.object
            [ ( "min", JE.float min )
            , ( "max", JE.float max )
            , ( "calculable", JE.bool True )

            --, ( "width", JE.string "300px" )
            , ( "itemHeight", JE.string "150px" )
            , ( "right", JE.string "7%" )
            , ( "bottom", JE.string "9" )
            , ( "orient", JE.string "horizontal" )
            ]
      )
    , ( "series"
      , [ JE.object
            [ ( "type", JE.string "heatmap" )
            , ( "label", JE.object [ ( "show", JE.bool True ) ] )
            , ( "data"
              , data
                    |> List.concat
                    |> List.map
                        (\( x, y, z ) ->
                            JE.list identity
                                [ JE.int x
                                , JE.int y
                                , z |> Maybe.map JE.float |> Maybe.withDefault JE.null
                                ]
                        )
                    |> JE.list identity
              )
            , ( "emphasis"
              , JE.object
                    [ ( "itemStyle"
                      , JE.object
                            [ ( "shadowBlur", JE.int 10 )
                            , ( "shadowColor", JE.string "rgba(0, 0, 0, 0.5)" )
                            ]
                      )
                    ]
              )
            ]
        ]
            |> JE.list identity
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodePieChart : Int -> Labels -> Maybe (List String) -> List (List ( String, Float )) -> JE.Value
encodePieChart width labels subtitle data =
    if List.length data == 1 then
        let
            pieces =
                data
                    |> List.head
                    |> Maybe.withDefault []
                    |> List.map
                        (\( name_, value_ ) ->
                            JE.object
                                [ ( "name", JE.string name_ )
                                , ( "value", JE.float value_ )
                                ]
                        )
                    |> JE.list identity

            head =
                if labels.main /= Nothing || subtitle /= Nothing then
                    [ ( "title"
                      , JE.object
                            [ ( "text"
                              , labels.main |> Maybe.withDefault "" |> JE.string
                              )
                            , ( "subtext", subtitle |> Maybe.withDefault [] |> List.head |> Maybe.withDefault "" |> JE.string )
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
                , ( "name"
                  , subtitle
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault ""
                        |> JE.string
                  )

                --, ( "roseType", JE.string "radius" )
                , ( "radius"
                  , JE.string <|
                        if labels.main /= Nothing || subtitle /= Nothing then
                            "65%"

                        else
                            "75%"
                  )
                , ( "center", JE.string "50%" )
                , ( "selectedMode", JE.string "single" )
                , ( "data", pieces )
                ]
            ]
                |> JE.list identity
          )
        , toolbox Nothing
            { saveAsImage = True
            , dataView = True
            , dataZoom = False
            , magicType = False
            }

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
        , ( "tooltip"
          , JE.object
                [ ( "trigger", JE.string "item" )
                , ( "formatter"
                  , JE.string "{b} : {c} ({d}%)"
                    -- "{a}<br/>{b} : {c} ({d}%)"
                  )
                ]
          )
        ]
            |> List.append head
            |> JE.object

    else
        encodePieCharts width labels.main subtitle data


encodeFunnel : Labels -> Maybe (List String) -> List (List ( String, Float )) -> JE.Value
encodeFunnel labels subtitle data =
    if List.length data == 1 then
        let
            pieces =
                data
                    |> List.head
                    |> Maybe.withDefault []
                    |> List.map
                        (\( name_, value_ ) ->
                            JE.object
                                [ ( "name", JE.string name_ )
                                , ( "value", JE.float value_ )
                                ]
                        )
                    |> JE.list identity

            head =
                if labels.main /= Nothing || subtitle /= Nothing then
                    [ ( "title"
                      , JE.object
                            [ ( "text"
                              , labels.main |> Maybe.withDefault "" |> JE.string
                              )
                            , ( "subtext", subtitle |> Maybe.withDefault [] |> List.head |> Maybe.withDefault "" |> JE.string )
                            , ( "left", JE.string "center" )
                            ]
                      )
                    ]

                else
                    []
        in
        [ ( "series"
          , [ JE.object
                [ ( "type", JE.string "funnel" )
                , ( "name"
                  , subtitle
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault ""
                        |> JE.string
                  )

                --, ( "roseType", JE.string "radius" )
                , ( "radius"
                  , JE.string <|
                        if labels.main /= Nothing || subtitle /= Nothing then
                            "65%"

                        else
                            "75%"
                  )
                , ( "center", JE.string "50%" )
                , ( "selectedMode", JE.string "single" )
                , ( "data", pieces )
                , ( "sort", JE.string "none" )
                ]
            ]
                |> JE.list identity
          )
        , toolbox Nothing
            { saveAsImage = True
            , dataView = True
            , dataZoom = False
            , magicType = False
            }

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
        , ( "tooltip"
          , JE.object
                [ ( "trigger", JE.string "item" )
                , ( "formatter"
                  , JE.string "{b} : {c} ({d}%)"
                    -- "{a}<br/>{b} : {c} ({d}%)"
                  )
                ]
          )
        ]
            |> List.append head
            |> JE.object

    else
        encodeFunnels labels.main subtitle data


encodeFunnels : Maybe String -> Maybe (List String) -> List (List ( String, Float )) -> JE.Value
encodeFunnels title subtitle data =
    let
        relWidth =
            ((100 / (toFloat <| List.length data))
                |> String.fromFloat
            )
                ++ "%"

        step =
            100 / toFloat (2 * List.length data)

        categories =
            data
                |> List.head
                |> Maybe.map (List.map Tuple.first)
                |> Maybe.withDefault []

        pieces =
            data
                |> List.indexedMap
                    (\i x ->
                        JE.object
                            [ ( "type", JE.string "funnel" )
                            , ( "width", JE.string relWidth )
                            , ( "sort", JE.string "none" )
                            , ( "left"
                              , String.fromFloat (toFloat (2 * i) * step)
                                    ++ "%"
                                    |> JE.string
                              )
                            , ( "label"
                              , JE.object
                                    [ ( "normal"
                                      , JE.object
                                            [ ( "formatter", JE.string "{c}" )
                                            , ( "position", JE.string "inside" )
                                            ]
                                      )
                                    ]
                              )
                            , ( "selectedMode", JE.string "single" )
                            , ( "data"
                              , x
                                    |> List.map
                                        (\( name_, value_ ) ->
                                            JE.object
                                                [ ( "name", JE.string name_ )
                                                , ( "value", JE.float value_ )
                                                ]
                                        )
                                    |> JE.list identity
                              )
                            ]
                    )

        head =
            if title /= Nothing || subtitle /= Nothing then
                [ ( "title"
                  , subtitle
                        |> Maybe.withDefault []
                        |> List.indexedMap
                            (\i sub ->
                                JE.object
                                    [ ( "subtext", JE.string sub )
                                    , ( "bottom", JE.int 40 )
                                    , ( "textAlign", JE.string "center" )
                                    , ( "left"
                                      , String.fromFloat (toFloat (2 * i) * step + step)
                                            ++ "%"
                                            |> JE.string
                                      )
                                    ]
                            )
                        |> (::)
                            (JE.object
                                [ ( "text"
                                  , title |> Maybe.withDefault "" |> JE.string
                                  )
                                , ( "left", JE.string "center" )
                                ]
                            )
                        |> JE.list identity
                  )
                ]

            else
                []
    in
    [ ( "series", JE.list identity pieces )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }

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
    , encodeLegend [ ( "top", JE.string "30px" ) ] categories
    , ( "tooltip"
      , JE.object
            [ ( "trigger", JE.string "item" )
            , ( "formatter"
              , JE.string "{b} : {c} ({d}%)"
                -- "{a}<br/>{b} : {c} ({d}%)"
              )
            ]
      )
    ]
        |> List.append head
        |> JE.object


encodePieCharts : Int -> Maybe String -> Maybe (List String) -> List (List ( String, Float )) -> JE.Value
encodePieCharts width title subtitle data =
    let
        relWidth =
            (toFloat width
                / (6.1 * toFloat (List.length data))
                |> (\w ->
                        if w > 70 then
                            70

                        else
                            w
                   )
                |> String.fromFloat
            )
                ++ "%"

        step =
            100 / toFloat (2 * List.length data)

        categories =
            data
                |> List.head
                |> Maybe.map (List.map Tuple.first)
                |> Maybe.withDefault []

        pieces =
            data
                |> List.indexedMap
                    (\i x ->
                        JE.object
                            [ ( "type", JE.string "pie" )
                            , ( "radius"
                              , JE.string relWidth
                              )
                            , ( "center"
                              , [ String.fromFloat (toFloat (2 * i) * step + step)
                                    ++ "%"
                                , "50%"
                                ]
                                    |> JE.list JE.string
                              )
                            , ( "label"
                              , JE.object
                                    [ ( "normal"
                                      , JE.object
                                            [ ( "formatter", JE.string "{c}" )
                                            , ( "position", JE.string "inside" )
                                            ]
                                      )
                                    ]
                              )
                            , ( "selectedMode", JE.string "single" )
                            , ( "data"
                              , x
                                    |> List.map
                                        (\( name_, value_ ) ->
                                            JE.object
                                                [ ( "name", JE.string name_ )
                                                , ( "value", JE.float value_ )
                                                ]
                                        )
                                    |> JE.list identity
                              )
                            ]
                    )

        head =
            if title /= Nothing || subtitle /= Nothing then
                [ ( "title"
                  , subtitle
                        |> Maybe.withDefault []
                        |> List.indexedMap
                            (\i sub ->
                                JE.object
                                    [ ( "subtext", JE.string sub )
                                    , ( "bottom", JE.int 40 )
                                    , ( "textAlign", JE.string "center" )
                                    , ( "left"
                                      , String.fromFloat (toFloat (2 * i) * step + step)
                                            ++ "%"
                                            |> JE.string
                                      )
                                    ]
                            )
                        |> (::)
                            (JE.object
                                [ ( "text"
                                  , title |> Maybe.withDefault "" |> JE.string
                                  )
                                , ( "left", JE.string "center" )
                                ]
                            )
                        |> JE.list identity
                  )
                ]

            else
                []
    in
    [ ( "series", JE.list identity pieces )
    , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = False, magicType = False }

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
    , encodeLegend [ ( "top", JE.string "30px" ) ] categories
    , ( "tooltip"
      , JE.object
            [ ( "trigger", JE.string "item" )
            , ( "formatter"
              , JE.string "{b} : {c} ({d}%)"
                -- "{a}<br/>{b} : {c} ({d}%)"
              )
            ]
      )
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
    let
        ( min, max ) =
            chart.diagrams
                |> Dict.toList
                |> List.map Tuple.second
                |> List.concatMap
                    (\diagram ->
                        List.map .x <|
                            case diagram of
                                Lines points _ ->
                                    points

                                Dots points _ ->
                                    points
                    )
                |> minMax
                |> Maybe.withDefault ( 0, 0 )
    in
    JE.object
        [ ( "textStyle"
          , JE.object
                [ ( "fontFamily", JE.string "Roboto" )
                ]
          )
        , xAxis (Just ( min, max )) "value" (Just chart.xLabel) []
        , yAxis "value" (Just chart.yLabel) []
        , ( "title", JE.object [ ( "text", JE.string chart.title ) ] )
        , ( "legend"
          , JE.object
                [ ( "data", JE.list JE.string chart.legend )

                --, ( "right", JE.int 0 )
                , ( "top", JE.int 28 )
                ]
          )
        , toolbox Nothing { saveAsImage = True, dataView = True, dataZoom = True, magicType = True }

        --  , brush
        , ( "tooltip", JE.object [] )
        , ( "series"
          , chart.diagrams
                |> Dict.toList
                |> JE.list (series withColor)
          )
        ]



-- brush : ( String, JE.Value )
-- brush =
--     ( "brush"
--     , JE.object
--         [ ( "toolbox"
--           , JE.list JE.string
--                 [ "rect"
--                 , "polygon"
--                 , "lineX"
--                 , "lineY"
--                 , "keep"
--                 , "clear"
--                 ]
--           )
--         ]
--     )


toolbox : Maybe String -> { saveAsImage : Bool, dataView : Bool, dataZoom : Bool, magicType : Bool } -> ( String, JE.Value )
toolbox position config =
    ( "toolbox"
    , JE.object
        [ ( "bottom", JE.int 8 )
        , ( "left"
          , position
                |> Maybe.withDefault "center"
                |> JE.string
          )
        , ( "feature"
          , []
                |> List.append
                    (if config.saveAsImage then
                        [ ( "saveAsImage", JE.object [ ( "title", JE.string "store" ) ] ) ]

                     else
                        []
                    )
                |> List.append
                    (if config.dataView then
                        [ ( "dataView"
                          , JE.object
                                [ ( "title", JE.string "edit" )
                                , ( "lang", JE.list JE.string [ "data view", "turn off", "refresh" ] )
                                ]
                          )
                        ]

                     else
                        []
                    )
                |> List.append
                    (if config.dataZoom then
                        [ ( "dataZoom"
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

                     else
                        []
                    )
                |> List.append
                    (if config.magicType then
                        [ ( "magicType"
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

                     else
                        []
                    )
                |> JE.object
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
