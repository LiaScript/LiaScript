module Lia.Markdown.Table.View exposing (view)

import Array
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Chart.Types exposing (Diagram(..), Point)
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Table.Types
    exposing
        ( Class(..)
        , Row
        , State
        , Table(..)
        , Vector
        , allNumbers
        , getColumn
        )
import Lia.Markdown.Table.Update as Sub
import Lia.Markdown.Update exposing (Msg(..))


view : (Inlines -> List (Html Msg)) -> Parameters -> Bool -> Table -> Vector -> Html Msg
view viewer attr mode table vector =
    let
        activate =
            if
                attr
                    |> List.filter (Tuple.first >> (==) "diagram-show")
                    |> List.head
                    |> Maybe.map
                        (Tuple.second
                            >> String.toLower
                            >> String.trim
                            >> (\param -> param == "true" || param == "")
                        )
                    |> Maybe.withDefault False
            then
                not

            else
                identity

        userClass =
            attr
                |> List.filter (Tuple.first >> (==) "diagram-type")
                |> List.head
                |> Maybe.andThen
                    (Tuple.second
                        >> String.toLower
                        >> String.trim
                        >> (\param ->
                                case param of
                                    "lineplot" ->
                                        Just LinePlot

                                    "line" ->
                                        Just LinePlot

                                    "scatterplot" ->
                                        Just ScatterPlot

                                    "scatter" ->
                                        Just ScatterPlot

                                    "barchart" ->
                                        Just BarChart

                                    "bar" ->
                                        Just BarChart

                                    "piechart" ->
                                        Just PieChart

                                    "pie" ->
                                        Just PieChart

                                    "heatmap" ->
                                        Just HeatMap

                                    "map" ->
                                        Just HeatMap

                                    "radar" ->
                                        Just Radar

                                    "parallel" ->
                                        Just Parallel

                                    "none" ->
                                        Just None

                                    _ ->
                                        Nothing
                           )
                    )
    in
    case table of
        Unformatted class rows id ->
            let
                state =
                    getState id vector
            in
            if activate state.diagram then
                Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ]
                    [ toggleBtn id "list"
                    , rows
                        |> sort state
                        |> chart attr mode (userClass |> Maybe.withDefault class) []
                    ]

            else
                state
                    |> unformatted viewer rows id
                    |> toTable id attr (userClass |> Maybe.withDefault class) state.diagram

        Formatted class head format rows id ->
            let
                state =
                    getState id vector
            in
            if activate state.diagram then
                Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ]
                    [ toggleBtn id "list"
                    , rows
                        |> sort state
                        |> chart attr mode (userClass |> Maybe.withDefault class) head
                    ]

            else
                state
                    |> formatted viewer head format rows id
                    |> toTable id attr (userClass |> Maybe.withDefault class) state.diagram


toData :
    (List Point -> Maybe String -> Diagram)
    -> List (Float -> Point)
    -> Int
    -> List Inlines
    -> List Row
    -> List ( Maybe String, ( Char, Diagram ) )
toData fn points i head rows =
    case getColumn i head rows of
        Nothing ->
            []

        Just ( title, col ) ->
            case
                List.map2
                    (\c p -> Maybe.map p c.float)
                    col
                    points
                    |> List.filterMap identity
            of
                [] ->
                    toData fn points (i + 1) head rows

                diagram ->
                    ( title
                    , ( Chart.getColor i
                      , fn diagram title
                      )
                    )
                        :: toData fn points (i + 1) head rows


toBarChart : Int -> List Inlines -> List Row -> List ( Maybe String, List (Maybe Float) )
toBarChart i head rows =
    case getColumn i head rows of
        Nothing ->
            []

        Just ( title, col ) ->
            let
                data =
                    List.map .float col
            in
            if List.all ((==) Nothing) data then
                toBarChart (i + 1) head rows

            else
                ( title, data ) :: toBarChart (i + 1) head rows


chart : Parameters -> Bool -> Class -> List Inlines -> List Row -> Html Msg
chart attr mode class head rows =
    Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ] <|
        case class of
            BarChart ->
                let
                    title =
                        head
                            |> List.head
                            |> Maybe.map (stringify >> String.trim)
                            |> Maybe.withDefault ""

                    category =
                        rows
                            |> getColumn 0 []
                            |> Maybe.map (Tuple.second >> List.map (.string >> String.trim))
                            |> Maybe.withDefault []
                in
                [ toBarChart 1 head rows
                    |> Chart.viewBarChart attr mode title category
                ]

            PieChart ->
                if
                    rows
                        |> List.map (List.head >> Maybe.andThen .float)
                        |> List.all ((/=) Nothing)
                then
                    let
                        title =
                            head
                                |> List.map (stringify >> String.trim)

                        data =
                            rows
                                |> List.head
                                |> Maybe.withDefault []
                                |> List.map .float
                    in
                    [ List.map2 (\title_ -> Maybe.map (Tuple.pair title_)) title data
                        |> List.filterMap identity
                        |> Chart.viewPieChart attr mode Nothing Nothing
                    ]

                else
                    let
                        ( main, title ) =
                            case head of
                                m :: heads_ ->
                                    ( stringify m |> String.trim |> Just
                                    , heads_
                                        |> List.map (stringify >> String.trim)
                                    )

                                [] ->
                                    ( Nothing, [] )

                        sub =
                            rows
                                |> List.head
                                |> Maybe.andThen List.head
                                |> Maybe.map .string

                        data =
                            rows
                                |> List.head
                                |> Maybe.andThen List.tail
                                |> Maybe.withDefault []
                                |> List.map .float
                    in
                    [ List.map2 (\title_ -> Maybe.map (Tuple.pair title_)) title data
                        |> List.filterMap identity
                        |> Chart.viewPieChart attr mode main sub
                    ]

            HeatMap ->
                if head == [] then
                    let
                        y =
                            rows
                                |> List.head
                                |> Maybe.andThen List.tail
                                |> Maybe.withDefault []
                                |> List.map .string

                        x =
                            rows
                                |> List.tail
                                |> Maybe.withDefault []
                                |> List.filterMap List.head
                                |> List.map .string
                                |> List.reverse
                    in
                    [ rows
                        |> List.tail
                        |> Maybe.withDefault []
                        |> List.map (List.tail >> Maybe.withDefault [])
                        |> List.indexedMap
                            (\y_ row ->
                                row
                                    |> List.indexedMap (\x_ cell -> ( x_, y_, cell.float ))
                            )
                        |> Chart.viewHeatMap attr mode Nothing y x
                    ]

                else
                    let
                        y =
                            head
                                |> List.tail
                                |> Maybe.withDefault []
                                |> List.map (stringify >> String.trim)

                        x =
                            rows
                                |> List.filterMap List.head
                                |> List.map .string
                                |> List.reverse

                        title =
                            head
                                |> List.head
                                |> Maybe.withDefault []
                                |> stringify
                                |> String.trim
                                |> (\title_ ->
                                        if title_ == "" then
                                            Nothing

                                        else
                                            Just title_
                                   )
                    in
                    [ rows
                        |> List.map (List.tail >> Maybe.withDefault [])
                        |> List.reverse
                        |> List.indexedMap
                            (\y_ row ->
                                row
                                    |> List.indexedMap (\x_ cell -> ( x_, y_, cell.float ))
                            )
                        |> Chart.viewHeatMap attr mode title y x
                    ]

            Radar ->
                if head == [] then
                    let
                        title =
                            rows
                                |> List.head
                                |> Maybe.andThen List.head
                                |> Maybe.map .string
                                |> Maybe.withDefault ""

                        categories =
                            rows
                                |> List.head
                                |> Maybe.andThen List.tail
                                |> Maybe.map (List.map .string)
                                |> Maybe.withDefault []
                    in
                    [ rows
                        |> List.tail
                        |> Maybe.withDefault []
                        |> List.map toRadar
                        |> Chart.viewRadarChart attr mode title categories
                    ]

                else
                    let
                        title =
                            head
                                |> List.head
                                |> Maybe.map (stringify >> String.trim)
                                |> Maybe.withDefault ""

                        categories =
                            head
                                |> List.tail
                                |> Maybe.map (List.map (stringify >> String.trim))
                                |> Maybe.withDefault []
                    in
                    [ rows
                        |> List.map toRadar
                        |> Chart.viewRadarChart attr mode title categories
                    ]

            Parallel ->
                [ Html.text "Parallel" ]

            _ ->
                let
                    points =
                        List.filterMap (List.head >> Maybe.andThen .float >> Maybe.map Point) rows

                    ( legend, diagrams ) =
                        toData
                            (if class == LinePlot then
                                Lines

                             else
                                Dots
                            )
                            points
                            1
                            head
                            rows
                            |> List.unzip
                in
                [ { title = ""
                  , yLabel = ""
                  , xLabel = head |> List.head |> Maybe.map (stringify >> String.trim) |> Maybe.withDefault ""
                  , legend = List.filterMap identity legend
                  , diagrams = diagrams |> Dict.fromList
                  }
                    |> Chart.viewChart attr mode
                ]


toRadar : Row -> ( String, List (Maybe Float) )
toRadar row =
    case row of
        [] ->
            ( "", [] )

        head :: tail ->
            ( head
                |> .string
                |> String.trim
            , tail
                |> List.map .float
            )


getState : Int -> Vector -> State
getState id =
    Array.get id >> Maybe.withDefault (State -1 False False)


toTable : Int -> Parameters -> Class -> Bool -> List (Html Msg) -> Html Msg
toTable id attr class diagram body =
    if class == None then
        Html.table (annotation "lia-table" attr) body

    else
        Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ]
            [ toggleBtn id <|
                case class of
                    BarChart ->
                        "bar_chart"

                    PieChart ->
                        "pie_chart"

                    LinePlot ->
                        "multiline_chart"

                    HeatMap ->
                        "apps"

                    Radar ->
                        "star_outline"

                    Parallel ->
                        "apps"

                    _ ->
                        "scatter_plot"
            , Html.div [] [ Html.table (annotation "lia-table" attr) body ]
            ]


toggleBtn : Int -> String -> Html Msg
toggleBtn id icon =
    Html.div
        [ Attr.class "lia-icon"
        , Attr.style "float" "left"
        , Attr.style "cursor" "pointer"
        , Attr.style "color" "gray"
        , onClick <| UpdateTable <| Sub.Toggle id
        ]
        [ Html.text icon
        ]


unformatted : (Inlines -> List (Html Msg)) -> List Row -> Int -> State -> List (Html Msg)
unformatted viewer rows id state =
    case sort state rows of
        head :: tail ->
            tail
                |> List.map
                    (List.map (.inlines >> viewer >> Html.td [ Attr.align "left" ])
                        >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )
                |> (::)
                    (head
                        |> view_head1 viewer id state
                        |> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                    )

        [] ->
            []


formatted : (Inlines -> List (Html Msg)) -> MultInlines -> List String -> List Row -> Int -> State -> List (Html Msg)
formatted viewer head format rows id state =
    rows
        |> sort state
        |> List.map
            (List.map2 (\f -> .inlines >> viewer >> Html.td [ Attr.align f ]) format
                >> Html.tr [ Attr.class "lia-inline lia-table-row" ]
            )
        |> (::)
            (head
                |> view_head2 viewer id format state
                |> Html.thead [ Attr.class "lia-inline lia-table-head" ]
            )


get : Int -> List x -> Maybe x
get i list =
    if i == 0 then
        List.head list

    else
        List.tail list
            |> Maybe.withDefault []
            |> get (i - 1)


sort : State -> List Row -> List Row
sort state matrix =
    if state.column /= -1 then
        let
            sorted =
                if
                    matrix
                        |> get state.column
                        |> Maybe.map allNumbers
                        |> Maybe.withDefault False
                then
                    List.sortBy (get state.column >> Maybe.andThen .float >> Maybe.withDefault 0) matrix

                else
                    List.sortBy (get state.column >> Maybe.map .string >> Maybe.withDefault "") matrix
        in
        if state.dir then
            sorted

        else
            List.reverse sorted

    else
        matrix


view_head1 : (Inlines -> List (Html Msg)) -> Int -> State -> Row -> List (Html Msg)
view_head1 viewer id state =
    List.indexedMap
        (\i r ->
            header viewer id "left" state i r.inlines
                |> Html.td [ Attr.align "left" ]
        )


view_head2 : (Inlines -> List (Html Msg)) -> Int -> List String -> State -> List Inlines -> List (Html Msg)
view_head2 viewer id format state =
    List.map2 Tuple.pair format
        >> List.indexedMap
            (\i ( f, r ) ->
                header viewer id f state i r
                    |> Html.th [ Attr.align f, Attr.style "height" "100%" ]
            )


header : (Inlines -> List (Html Msg)) -> Int -> String -> State -> Int -> Inlines -> List (Html Msg)
header viewer id format state i r =
    [ Html.span
        (if format /= "right" then
            [ Attr.style "float" format, Attr.style "height" "100%" ]

         else
            [ Attr.style "height" "100%" ]
        )
        (viewer r)
    , Html.span
        [ Attr.class "lia-icon"
        , Attr.style "float" "right"
        , Attr.style "cursor" "pointer"
        , Attr.style "margin-right" "-17px"
        , Attr.style "margin-top" "-10px"

        --  , Attr.style "height" "100%"
        --  , Attr.style "position" "relative"
        --  , Attr.style "vertical-align" "top"
        , onClick <| UpdateTable <| Sub.Sort id i
        ]
        [ Html.div
            [ Attr.style "height" "6px"
            , Attr.style "color" <|
                if state.column == i && state.dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_up" ]
        , Html.div
            [ Attr.style "height" "6px"
            , Attr.style "color" <|
                if state.column == i && not state.dir then
                    "red"

                else
                    "gray"
            ]
            [ Html.text "arrow_drop_down" ]
        ]
    ]
