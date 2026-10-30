module Lia.Markdown.Chart.View exposing
    ( eCharts
    , feature
    , getColor
    , niceLimits
    , toolbox
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
    , viewWordCloud
    )

import Char exposing (toLower)
import Conditional.List as CList
import Dict exposing (Dict)
import Helper.List as List
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations exposing (chartDefault, getCodeFromLn)
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Chart, Data, Diagram(..), Orientation(..), Settings, invertDiagram)
import Lia.Markdown.HTML.Attributes exposing (annotation)
import Lia.Utils exposing (string2Color, string2ColorRange)
import List.Statistics as Stat
import Maybe


view : Settings -> Chart -> Html msg
view settings =
    encode settings.light True >> eCharts settings Nothing


viewChart : Settings -> Chart -> Html msg
viewChart settings =
    encode settings.light False >> eCharts settings Nothing


viewLines : Settings -> Data ( String, List (Maybe Float) ) -> Html msg
viewLines settings =
    encodeBasic "line" >> eCharts settings Nothing


viewPoints : Settings -> Data ( String, List (Maybe Float) ) -> Html msg
viewPoints settings =
    encodeBasic "scatter" >> eCharts settings Nothing


viewBarChart : Settings -> Data ( Maybe String, List (Maybe Float) ) -> Html msg
viewBarChart settings =
    encodeBarChart >> eCharts settings Nothing


viewBoxPlot : Settings -> Data (List (Maybe Float)) -> Html msg
viewBoxPlot settings =
    encodeBoxPlot >> eCharts settings Nothing


viewParallel : Settings -> Data (List (Maybe Float)) -> Html msg
viewParallel settings =
    encodeParallel >> eCharts settings Nothing


viewGraph : Settings -> Data ( String, String, Float ) -> Html msg
viewGraph settings =
    encodeGraph >> eCharts settings Nothing


viewSankey : Settings -> Data ( String, String, Float ) -> Html msg
viewSankey settings =
    encodeSankey >> eCharts settings Nothing


viewRadarChart : Settings -> Data ( String, List (Maybe Float) ) -> Html msg
viewRadarChart settings =
    encodeRadarChart >> eCharts settings Nothing


viewMapChart : Settings -> Maybe String -> Data ( String, Maybe Float ) -> Html msg
viewMapChart settings json =
    encodeMapChart json >> eCharts settings json


viewPieChart : Settings -> Int -> Data (List ( String, Float )) -> Html msg
viewPieChart settings width =
    encodePieChart width >> eCharts settings Nothing


viewFunnel : Settings -> Data (List ( String, Float )) -> Html msg
viewFunnel settings =
    encodeFunnel >> eCharts settings Nothing


viewWordCloud : Settings -> Int -> Data (List ( String, Float )) -> Html msg
viewWordCloud settings width =
    encodeWordCloud settings.light width >> eCharts settings Nothing


viewHeatMap : Settings -> List String -> Data (List ( Int, Int, Maybe Float )) -> Html msg
viewHeatMap settings y =
    encodeHeatMap y >> eCharts settings Nothing


eCharts : Settings -> Maybe String -> JE.Value -> Html msg
eCharts { lang, attr, light } json option =
    Html.node "lia-chart"
        (List.append
            [ Attr.attribute "mode" <|
                if light then
                    ""

                else
                    "dark"
            , Attr.attribute "locale" (getCodeFromLn lang)

            -- the name until eCharts has generated a description
            , Attr.attribute "data-label" (chartDefault lang)
            , Attr.property "option" option
            , json
                |> Maybe.withDefault ""
                |> Attr.attribute "json"
            ]
            (attr
                |> annotation "lia-chart"
            )
        )
        []


encodeGraph : Data ( String, String, Float ) -> JE.Value
encodeGraph { labels, category, data } =
    let
        ( min, max ) =
            data
                |> List.map (\( _, _, v ) -> v)
                |> Stat.minmax
                |> Maybe.withDefault ( 0, 0 )

        lineWidth v =
            1 + (4 * abs v / (max - min))

        dict =
            data
                |> List.map (\( source, target, val ) -> ( ( source, target ), val ))
                |> Dict.fromList

        directed =
            dict
                |> Dict.map (\( s, t ) v -> Dict.get ( t, s ) dict == Just v)
                |> Dict.values
                |> List.all identity
    in
    [ toolbox Nothing
        { saveAsImage = True
        , dataView = False
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ ( "type", JE.string "graph" )
        , ( "layout", JE.string "force" )
        , ( "label", JE.object [ ( "show", JE.bool True ) ] )
        , ( "symbolSize", JE.float 40 )
        , ( "roam", JE.bool True )
        , ( "animation", JE.bool True )
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
          , category
                |> JE.list
                    (\node ->
                        JE.object
                            [ ( "id", JE.string node )
                            , ( "name", JE.string node )
                            ]
                    )
          )
        , ( "edges"
          , data
                |> JE.list
                    (\( source, target, v ) ->
                        JE.object
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
          )
        ]
            |> List.singleton
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeSankey : Data ( String, String, Float ) -> JE.Value
encodeSankey { labels, category, data, orientation } =
    let
        dict =
            data
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

        -- nodes without outgoing flow form the last column
        sources =
            List.map (Tuple.first >> Tuple.first) cleared

        horizontal =
            orientation /= Just Vertical
    in
    [ toolbox Nothing
        { saveAsImage = True
        , dataView = False
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ ( "type", JE.string "sankey" )

        -- below the title, above the toolbox
        , ( "left", JE.string "1%" )
        , ( "top"
          , JE.int <|
                if labels.main == Nothing then
                    10

                else
                    50
          )
        , ( "right", JE.string "1%" )
        , ( "bottom", JE.int 40 )
        , ( "layout", JE.string "none" )
        , ( "focusNodeAdjacency", JE.string "allEdges" )
        , ( "animation", JE.bool True )
        , ( "data"
          , category
                |> JE.list
                    (\node ->
                        [ ( "name", JE.string node ) ]
                            -- the labels of the last column stand left, no margin needed
                            |> CList.addIf (horizontal && not (List.member node sources))
                                ( "label", JE.object [ ( "position", JE.string "left" ) ] )
                            |> JE.object
                    )
          )
        , ( "edges"
          , cleared
                |> JE.list
                    (\( ( source, target ), v ) ->
                        JE.object
                            [ ( "source", JE.string source )
                            , ( "target", JE.string target )
                            , ( "value", JE.float v )
                            ]
                    )
          )
        , ( "lineStyle", JE.object [ ( "color", JE.string "source" ) ] )
        ]
            |> CList.addIf (not horizontal) ( "orient", JE.string "vertical" )
            -- labels right of the wide vertical nodes would overlap the next one
            |> CList.addIf (not horizontal) ( "label", JE.object [ ( "position", JE.string "inside" ) ] )
            |> List.singleton
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeBoxPlot : Data (List (Maybe Float)) -> JE.Value
encodeBoxPlot { labels, category, data } =
    let
        boxplots =
            data
                |> List.map (List.filterMap identity >> List.sort)
                |> List.map2
                    (\c data_ ->
                        case
                            ( Stat.percentile 0.25 data_
                            , Stat.median data_
                            , Stat.percentile 0.75 data_
                            )
                        of
                            ( Just q1, Just q2, Just q3 ) ->
                                let
                                    ( min, max ) =
                                        data_
                                            |> Stat.minmax
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
             , ( "data"
               , JE.list (Tuple.first >> JE.string) boxplots
               )
             ]
                |> CList.addWhen (labels.x |> Maybe.map (JE.string >> Tuple.pair "name"))
                |> addAxisLimits labels.xLimits
            )
      )
    , yAxis labels.yLimits "value" labels.y []
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = True
        , magicType = False
        , restore = False
        }
    , grid
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ [ ( "type", JE.string "boxplot" )
          , ( "data"
            , boxplots
                |> JE.list (Tuple.second >> Tuple.first >> JE.list JE.float)
            )
          ]
        , [ ( "type", JE.string "scatter" )
          , ( "name", JE.string "outlier" )
          , ( "data"
            , boxplots
                |> List.map (Tuple.second >> Tuple.second)
                |> List.indexedMap (\i data_ -> toFloat i :: data_)
                |> JE.list (JE.list JE.float)
            )
          ]
        ]
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodeBarChart : Data ( Maybe String, List (Maybe Float) ) -> JE.Value
encodeBarChart { labels, category, data, orientation } =
    let
        bars =
            data
                |> List.foldl
                    (\( label_, floats ) bs ->
                        if List.all ((==) Nothing) floats then
                            bs

                        else
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
                                    |> JE.list (Maybe.map JE.float >> Maybe.withDefault JE.null)
                              )
                            ]
                                :: bs
                    )
                    []
                |> JE.list JE.object
    in
    [ ( if orientation == Just Horizontal then
            "yAxis"

        else
            "xAxis"
      , [ ( "type", JE.string "category" )
        , ( "data", category |> JE.list JE.string )
        ]
            |> CList.addWhen (labels.x |> Maybe.map (\title -> ( "name", JE.string title )))
            |> addAxisLimits labels.xLimits
            |> JE.object
      )
    , (if orientation == Just Horizontal then
        xAxis

       else
        yAxis
      )
        labels.yLimits
        "value"
        labels.y
        []
    , grid
    , ( "legend"
      , [ ( "data"
          , data
                |> List.unzip
                |> Tuple.first
                |> List.filterMap identity
                |> JE.list JE.string
          )
        ]
            |> CList.addIf (labels.main /= Nothing) ( "top", JE.string "30px" )
            |> JE.object
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = True
        , magicType = True
        , restore = False
        }
    , ( "tooltip", JE.object [] )
    , ( "series", bars )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


grid : ( String, JE.Value )
grid =
    ( "grid"
    , JE.object
        [ ( "left", JE.string "1%" )
        , ( "right", JE.string "1%" )
        , ( "bottom", JE.string "12%" )

        -- keeps axis labels and axis names within the margins
        , ( "outerBoundsMode", JE.string "same" )
        , ( "outerBoundsContain", JE.string "all" )
        ]
    )


addAxisLimits : { min : Maybe String, max : Maybe String } -> List ( String, JE.Value ) -> List ( String, JE.Value )
addAxisLimits { min, max } =
    CList.addWhen (min |> Maybe.map (JE.string >> Tuple.pair "min"))
        >> CList.addWhen (max |> Maybe.map (JE.string >> Tuple.pair "max"))


encodeBasic : String -> Data ( String, List (Maybe Float) ) -> JE.Value
encodeBasic type_ { labels, category, data } =
    [ xAxis labels.xLimits "category" labels.x category
    , yAxis labels.yLimits "value" labels.y []
    , grid
    , data
        |> List.map Tuple.first
        |> encodeLegend [ ( "top", JE.string "30px" ) ]
    , ( "tooltip", JE.object [] )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = True
        , magicType = True
        , restore = False
        }
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


{-| Estimated width of a text in the 12px chart font.

shortcut: 6.4px per letter and 12px per CJK character, measure the text in the
browser if other scripts or fonts get clipped

-}
textWidth : String -> Float
textWidth =
    String.foldl
        (\c sum ->
            let
                code =
                    Char.toCode c
            in
            if
                (code >= 0x1100 && code <= 0x115F)
                    || (code >= 0x2E80 && code <= 0xA4CF)
                    || (code >= 0xAC00 && code <= 0xD7A3)
                    || (code >= 0xF900 && code <= 0xFAFF)
                    || (code >= 0xFF00 && code <= 0xFF60)
            then
                sum + 12

            else
                sum + 6.4
        )
        0


encodeParallel : Data (List (Maybe Float)) -> JE.Value
encodeParallel { labels, category, data, orientation } =
    let
        -- half of the first, centered axis name
        left =
            category
                |> List.head
                |> Maybe.map (textWidth >> (\w -> w / 2 + 4) >> round)
                |> Maybe.withDefault 20
                -- longer names are cut by echarts anyway
                |> clamp 20 60

        truncate maxWidth =
            ( "nameTruncate", JE.object [ ( "maxWidth", JE.int maxWidth ) ] )
    in
    [ ( "parallelAxis"
      , category
            |> List.indexedMap
                (\i cat ->
                    [ ( "dim", JE.int i )
                    , ( "name", JE.string cat )

                    -- long numbers on narrow screens
                    , ( "axisLabel", JE.object [ ( "hideOverlap", JE.bool True ) ] )
                    ]
                        -- vertical names stand right of the axis, within the margin
                        |> CList.addIf (orientation == Just Vertical) (truncate 100)
                        -- a longer translation of the first name stays within the margin
                        |> CList.addIf (orientation /= Just Vertical && i == 0) (truncate (2 * (left - 4)))
                )
            |> JE.list JE.object
      )
    , ( "series"
      , [ ( "type", JE.string "parallel" )
        , ( "data"
          , data
                |> JE.list (JE.list (Maybe.map JE.float >> Maybe.withDefault JE.null))
          )
        ]
            |> JE.object
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "parallel"
      , JE.object <|
            if orientation == Just Vertical then
                [ ( "layout", JE.string "vertical" )
                , ( "left", JE.int 30 )
                , ( "right", JE.int 120 )
                ]

            else
                -- the numbers right of the last axis keep the default of 80
                [ ( "layout", JE.string "horizontal" )
                , ( "left", JE.int left )
                ]
      )
    , ( "tooltip", JE.object [] )
    ]
        |> add (encodeTitle Nothing) labels.main
        |> JE.object


encodeMapChart : Maybe String -> Data ( String, Maybe Float ) -> JE.Value
encodeMapChart json data =
    let
        ( min, max ) =
            data.data
                |> List.filterMap Tuple.second
                |> Stat.minmax
                |> Maybe.withDefault ( 0, 0 )

        -- a string limit turns the color bar black
        limit default =
            Maybe.andThen String.toFloat >> Maybe.withDefault default >> JE.float
    in
    [ ( "series"
      , [ [ ( "type", JE.string "map" )

          -- use the full height, by default a map only takes 80 percent
          , ( "top", JE.int 50 )
          , ( "bottom", JE.int 40 )
          , ( "map"
            , json
                |> Maybe.withDefault ""
                |> JE.string
            )
          , ( "roam", JE.bool True ) -- allow zooming
          , ( "name"
            , data.labels.y
                |> Maybe.withDefault "data"
                |> JE.string
            )
          , ( "data"
            , data.data
                |> List.filterMap
                    (\( key, value ) ->
                        case value of
                            Just num ->
                                [ ( "name", JE.string key )
                                , ( "value", JE.float num )
                                ]
                                    |> Just

                            _ ->
                                Nothing
                    )
                |> JE.list JE.object
            )
          ]
        ]
            |> JE.list JE.object
      )
    , ( "visualMap"
      , JE.object
            [ ( "min", limit min data.labels.xLimits.min )
            , ( "max", limit max data.labels.xLimits.max )
            , ( "calculable", JE.bool True )
            , ( "itemHeight", JE.string "150px" )
            , ( "right", JE.string "0" )
            , ( "bottom", JE.string "center" )
            , ( "orient", JE.string "vertical" )
            ]
      )
    , grid
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = True
        }
    , ( "tooltip", JE.object [] )
    ]
        |> add (encodeTitle Nothing) data.labels.main
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


encodeRadarChart : Data ( String, List (Maybe Float) ) -> JE.Value
encodeRadarChart { labels, category, data } =
    let
        max_ =
            category
                |> List.map (\c -> { name = c, max = 0 })

        indicator =
            data
                |> List.map Tuple.second
                |> List.foldl (\d i -> calcMax i d) max_
                |> JE.list
                    (\i ->
                        JE.object
                            [ ( "name", JE.string i.name )
                            , ( "max", JE.float i.max )
                            ]
                    )

        values =
            data
                |> JE.list
                    (\( name_, value ) ->
                        JE.object
                            [ ( "name", JE.string name_ )
                            , ( "value"
                              , value |> JE.list (Maybe.withDefault 0 >> JE.float)
                              )
                            ]
                    )
    in
    [ ( "radar"
      , JE.object
            [ ( "indicator", indicator )

            -- keeps the lowest name above the toolbox
            , ( "radius", JE.string "70%" )
            , ( "center", JE.list JE.string [ "50%", "48%" ] )
            , ( "axisName"
              , JE.object
                    [ ( "color", JE.string "#fff" )
                    , ( "backgroundColor", JE.string "#999" )
                    , ( "borderRadius", JE.int 3 )
                    , ( "padding", JE.list JE.int [ 3, 5 ] )
                    ]
              )
            ]
      )

    -- on narrow screens the names left and right would be cut off
    , ( "media"
      , JE.list JE.object
            [ [ ( "query", JE.object [ ( "maxWidth", JE.int 450 ) ] )
              , ( "option", JE.object [ ( "radar", JE.object [ ( "radius", JE.string "50%" ) ] ) ] )
              ]
            ]
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "tooltip", JE.object [] )
    , ( "series"
      , [ [ ( "type", JE.string "radar" )
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
            |> JE.list JE.object
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


xAxis : { min : Maybe String, max : Maybe String } -> String -> Maybe String -> List String -> ( String, JE.Value )
xAxis =
    axis True


yAxis : { min : Maybe String, max : Maybe String } -> String -> Maybe String -> List String -> ( String, JE.Value )
yAxis =
    axis False


axis : Bool -> { min : Maybe String, max : Maybe String } -> String -> Maybe String -> List String -> ( String, JE.Value )
axis x limits type_ title data =
    ( if x then
        "xAxis"

      else
        "yAxis"
    , [ ( "type", JE.string type_ ) ]
        |> addAxisLimits limits
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


encodeHeatMap : List String -> Data (List ( Int, Int, Maybe Float )) -> JE.Value
encodeHeatMap yLabels { labels, category, data } =
    let
        ( min, max ) =
            data
                |> List.concat
                |> List.filterMap (\( _, _, v ) -> v)
                |> Stat.minmax
                |> Maybe.withDefault ( 0, 0 )
    in
    [ toolbox (Just "7%")
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "tooltip", JE.object [] )
    , ( "grid"
      , JE.object <|
            [ ( "left", JE.string "1%" )
            , ( "right", JE.string "1%" )
            , ( "outerBoundsMode", JE.string "same" )
            , ( "outerBoundsContain", JE.string "all" )
            ]
                ++ (if labels.main == Nothing then
                        [ ( "height", JE.string "82%" )
                        , ( "top", JE.string "0%" )
                        ]

                    else
                        [ ( "height", JE.string "74%" )
                        , ( "top", JE.string "7%" )
                        ]
                   )
      )
    , xAxis labels.xLimits "category" labels.x category
    , yAxis labels.yLimits "category" labels.y yLabels
    , ( "visualMap"
      , JE.object
            [ ( "min", JE.float min )
            , ( "max", JE.float max )
            , ( "calculable", JE.bool True )
            , ( "itemHeight", JE.string "150px" )
            , ( "right", JE.string "7%" )
            , ( "bottom", JE.string "9" )
            , ( "orient", JE.string "horizontal" )
            ]
      )
    , ( "series"
      , [ [ ( "type", JE.string "heatmap" )
          , ( "label", JE.object [ ( "show", JE.bool True ) ] )
          , ( "data"
            , data
                |> List.concat
                |> JE.list
                    (\( x, y, z ) ->
                        JE.list identity
                            [ JE.int x
                            , JE.int y
                            , z
                                |> Maybe.map JE.float
                                |> Maybe.withDefault JE.null
                            ]
                    )
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
            |> JE.list JE.object
      )
    ]
        |> add (encodeTitle (Just ( "left", "center" ))) labels.main
        |> JE.object


encodePieChart : Int -> Data (List ( String, Float )) -> JE.Value
encodePieChart width chart =
    case chart.data of
        [ pieces ] ->
            encodeSingle chart
                [ ( "type", JE.string "pie" )
                , ( "radius"
                  , JE.string <|
                        if hasTitle chart then
                            "65%"

                        else
                            "75%"
                  )
                , ( "center", JE.string "50%" )
                ]
                pieces

        _ ->
            let
                step =
                    stepWidth chart.data

                radius =
                    toFloat width
                        / (6.1 * toFloat (List.length chart.data))
                        |> min 70
                        |> percent
            in
            encodeMultiple chart
                (\i ->
                    [ ( "type", JE.string "pie" )
                    , ( "radius", JE.string radius )
                    , ( "center", JE.list JE.string [ percent (toFloat (2 * i) * step + step), "50%" ] )
                    ]
                )


encodeFunnel : Data (List ( String, Float )) -> JE.Value
encodeFunnel chart =
    case chart.data of
        [ pieces ] ->
            encodeSingle chart
                ([ ( "type", JE.string "funnel" )
                 , ( "sort", JE.string "none" )
                 ]
                    |> CList.addIf (chart.orientation == Just Horizontal) ( "orient", JE.string "horizontal" )
                )
                pieces

        _ ->
            let
                step =
                    stepWidth chart.data
            in
            encodeMultiple chart
                (\i ->
                    [ ( "type", JE.string "funnel" )
                    , ( "width", JE.string (percent (100 / toFloat (List.length chart.data))) )
                    , ( "sort", JE.string "none" )
                    , ( "left", JE.string (percent (toFloat (2 * i) * step)) )
                    ]
                )


{-| A single pie or funnel, the first category is used as subtitle.
-}
encodeSingle : Data (List ( String, Float )) -> List ( String, JE.Value ) -> List ( String, Float ) -> JE.Value
encodeSingle chart specific pieces =
    [ ( "series"
      , JE.list JE.object
            [ specific
                ++ [ ( "name", JE.string (subtitle chart) )
                   , ( "selectedMode", JE.string "single" )
                   , ( "data", JE.list encodePiece pieces )
                   ]
            ]
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , itemTooltip
    ]
        |> CList.addIf (hasTitle chart) (titles chart)
        |> JE.object


{-| Multiple pies or funnels side by side, one per category, `specific` returns
the type and position of the i-th diagram.
-}
encodeMultiple : Data (List ( String, Float )) -> (Int -> List ( String, JE.Value )) -> JE.Value
encodeMultiple chart specific =
    [ ( "series"
      , chart.data
            |> List.indexedMap
                (\i pieces ->
                    specific i
                        ++ [ ( "label"
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
                           , ( "data", JE.list encodePiece pieces )
                           ]
                )
            |> JE.list JE.object
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , chart.data
        |> List.head
        |> Maybe.map (List.map Tuple.first)
        |> Maybe.withDefault []
        |> encodeLegend [ ( "top", JE.string "30px" ) ]
    , itemTooltip
    ]
        |> CList.addIf (hasTitle chart) (titles chart)
        |> JE.object


{-| The main title, a single diagram shows its category as subtitle, multiple
diagrams side by side get theirs below.
-}
titles : Data (List x) -> ( String, JE.Value )
titles chart =
    let
        main =
            ( "text", chart.labels.main |> Maybe.withDefault "" |> JE.string )
    in
    ( "title"
    , case chart.data of
        [ _ ] ->
            JE.object
                [ main
                , ( "subtext", JE.string (subtitle chart) )
                , ( "left", JE.string "center" )
                ]

        _ ->
            chart.category
                |> List.indexedMap
                    (\i sub ->
                        [ ( "subtext", JE.string sub )
                        , ( "bottom", JE.int 40 )
                        , ( "textAlign", JE.string "center" )
                        , ( "left", JE.string (percent (toFloat (2 * i + 1) * stepWidth chart.data)) )
                        ]
                    )
                |> (::) [ main, ( "left", JE.string "center" ) ]
                |> JE.list JE.object
    )


{-| Every word keeps its color, in dark mode the same color is lifted into the
bright range.
-}
wordColor : Bool -> String -> String
wordColor light =
    if light then
        string2Color 160

    else
        string2ColorRange 95 160


{-| Word clouds side by side, like pies. All clouds share one font scale, so
equal values have equal sizes, and every word keeps its color.
-}
encodeWordCloud : Bool -> Int -> Data (List ( String, Float )) -> JE.Value
encodeWordCloud light width chart =
    let
        step =
            stepWidth chart.data

        values =
            List.concatMap (List.map Tuple.second) chart.data

        ( low, high ) =
            values |> Stat.minmax |> Maybe.withDefault ( 0, 0 )

        largest =
            toFloat width / toFloat (5 * List.length chart.data) |> clamp 16 50

        fontSize value =
            if high == low then
                largest

            else
                12 + (value - low) / (high - low) * (largest - 12)

        sizeRange words =
            List.map Tuple.second words
                |> Stat.minmax
                |> Maybe.map (\( min, max ) -> [ fontSize min, fontSize max ])
                |> Maybe.withDefault [ largest, largest ]
    in
    [ ( "series"
      , chart.data
            |> List.indexedMap
                (\i words ->
                    [ ( "type", JE.string "wordCloud" )
                    , ( "left", JE.string (percent (toFloat (2 * i) * step)) )
                    , ( "width", JE.string (percent (2 * step)) )
                    , ( "top"
                      , JE.string <|
                            if hasTitle chart then
                                "15%"

                            else
                                "5%"
                      )
                    , ( "height", JE.string "70%" )
                    , ( "sizeRange", JE.list JE.float (sizeRange words) )
                    , ( "gridSize", JE.int 5 )
                    , ( "shrinkToFit", JE.bool True )
                    , ( "layoutAnimation", JE.bool True )
                    , ( "emphasis", JE.object [ ( "focus", JE.string "self" ) ] )
                    , ( "data"
                      , words
                            |> JE.list
                                (\( name, value ) ->
                                    JE.object
                                        [ ( "name", JE.string name )
                                        , ( "value", JE.float value )
                                        , ( "textStyle", JE.object [ ( "color", JE.string (wordColor light name) ) ] )
                                        ]
                                )
                      )
                    ]
                )
            |> JE.list JE.object
      )
    , toolbox Nothing
        { saveAsImage = True
        , dataView = True
        , dataZoom = False
        , magicType = False
        , restore = False
        }
    , ( "tooltip"
      , JE.object
            [ ( "trigger", JE.string "item" )
            , ( "formatter", JE.string "{b} : {c}" )
            ]
      )
    ]
        |> CList.addIf (hasTitle chart) (titles chart)
        |> JE.object


hasTitle : Data x -> Bool
hasTitle { labels, category } =
    labels.main /= Nothing || category /= []


subtitle : Data x -> String
subtitle =
    .category >> List.head >> Maybe.withDefault ""


{-| Half the width of one of n diagrams side by side, in percent.
-}
stepWidth : List x -> Float
stepWidth data =
    100 / toFloat (2 * List.length data)


percent : Float -> String
percent value =
    String.fromFloat value ++ "%"


encodePiece : ( String, Float ) -> JE.Value
encodePiece ( name, value ) =
    JE.object
        [ ( "name", JE.string name )
        , ( "value", JE.float value )
        ]


itemTooltip : ( String, JE.Value )
itemTooltip =
    ( "tooltip"
    , JE.object
        [ ( "trigger", JE.string "item" )
        , ( "formatter", JE.string "{b} : {c} ({d}%)" )
        ]
    )


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


encode : Bool -> Bool -> Chart -> JE.Value
encode light withColor chart =
    let
        ( min, max ) =
            chart.diagrams
                |> Dict.values
                |> List.concatMap
                    (\diagram ->
                        List.map .x <|
                            case diagram of
                                Lines points _ ->
                                    points

                                Dots points _ ->
                                    points
                    )
                |> Stat.minmax
                |> Maybe.withDefault ( 0, 0 )
                |> niceLimits
                |> Tuple.mapBoth String.fromFloat String.fromFloat
    in
    JE.object
        [ grid
        , (if chart.orientation == Just Vertical then
            yAxis

           else
            xAxis
          )
            { min =
                chart.xLimits.min
                    |> Maybe.withDefault min
                    |> Just
            , max =
                chart.xLimits.max
                    |> Maybe.withDefault max
                    |> Just
            }
            "value"
            (Just chart.xLabel)
            []
        , (if chart.orientation == Just Vertical then
            xAxis

           else
            yAxis
          )
            chart.yLimits
            "value"
            (Just chart.yLabel)
            []
        , ( "title", JE.object [ ( "text", JE.string chart.title ) ] )
        , ( "legend"
          , JE.object
                [ ( "data", JE.list JE.string chart.legend )
                , ( "top", JE.int 28 )
                ]
          )
        , toolbox Nothing
            { saveAsImage = True
            , dataView = True
            , dataZoom = True
            , magicType = True
            , restore = False
            }
        , ( "tooltip", JE.object [] )
        , ( "series"
          , chart.diagrams
                |> Dict.toList
                |> (if chart.orientation == Just Vertical then
                        List.map (Tuple.mapSecond invertDiagram)

                    else
                        identity
                   )
                |> JE.list (series light withColor)
          )
        ]


{-| Rounds the limits of the data to a tenth of the order of magnitude of their
range (4.33 and 97.67 become 4 and 98), otherwise the axis labels at both ends
show the odd values.
-}
niceLimits : ( Float, Float ) -> ( Float, Float )
niceLimits ( min, max ) =
    if max <= min then
        ( min, max )

    else
        let
            exp =
                floor (logBase 10 (max - min)) - 1

            -- the epsilon keeps float noise like 97.00000000000001 from rounding up
            steps value =
                value / 10 ^ toFloat exp

            -- fractions are divided by the inverse, 3 * 0.1 would be 0.30000000000000004
            toValue n =
                if exp >= 0 then
                    toFloat n * 10 ^ toFloat exp

                else
                    toFloat n / 10 ^ toFloat -exp
        in
        ( toValue (floor (steps min + 1.0e-9))
        , toValue (ceiling (steps max - 1.0e-9))
        )


toolbox :
    Maybe String
    ->
        { saveAsImage : Bool
        , dataView : Bool
        , dataZoom : Bool
        , magicType : Bool
        , restore : Bool
        }
    -> ( String, JE.Value )
toolbox position config =
    ( "toolbox"
    , JE.object
        [ ( "bottom", JE.int 8 )
        , ( "left"
          , position
                |> Maybe.withDefault "center"
                |> JE.string
          )
        , feature config
        ]
    )


feature :
    { saveAsImage : Bool
    , dataView : Bool
    , dataZoom : Bool
    , magicType : Bool
    , restore : Bool
    }
    -> ( String, JE.Value )
feature config =
    ( "feature"
    , []
        |> CList.addIf config.saveAsImage
            ( "saveAsImage", JE.object [] )
        |> CList.addIf config.restore
            ( "restore", JE.object [] )
        |> CList.addIf config.dataView
            ( "dataView", JE.object [] )
        |> CList.addIf config.dataZoom
            ( "dataZoom", JE.object [] )
        |> CList.addIf config.magicType
            ( "magicType"
            , JE.object
                [ ( "type"
                  , JE.list JE.string
                        [ "tiled"
                        , "line"
                        , "bar"
                        , "stack"
                        ]
                  )
                ]
            )
        |> JE.object
    )


series : Bool -> Bool -> ( Char, Diagram ) -> JE.Value
series light withColor ( char, diagram ) =
    let
        ( points, name, specific ) =
            case diagram of
                Lines list name_ ->
                    ( list
                    , name_
                    , [ ( "type", JE.string "line" )
                      , style withColor char
                      , smooth withColor char
                      ]
                    )

                Dots list name_ ->
                    ( list, name_, [ ( "type", JE.string "scatter" ) ] )
    in
    [ symbol char
    , symbolSize char
    , label
    , ( "data", JE.list (\point -> JE.list JE.float [ point.x, point.y ]) points )
    , ( "barGap", JE.int 0 )
    ]
        ++ specific
        |> CList.addIf withColor (color light char)
        |> add (JE.string >> Tuple.pair "name") name
        |> JE.object


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


{-| Black and white are swapped in dark mode, otherwise they would vanish.
-}
color : Bool -> Char -> ( String, JE.Value )
color light char =
    ( "itemStyle"
    , JE.object
        [ ( "color"
          , case ( light, colors |> Dict.get (toLower char) |> Maybe.withDefault "#000000" ) of
                ( False, "#000000" ) ->
                    JE.string "#FFFFFF"

                ( False, "#FFFFFF" ) ->
                    JE.string "#000000"

                ( _, hex ) ->
                    JE.string hex
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
