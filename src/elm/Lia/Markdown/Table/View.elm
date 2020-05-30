module Lia.Markdown.Table.View exposing (view)

import Array
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Chart.Types exposing (Diagram(..), Point)
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.HTML.Attributes as Param exposing (Parameters)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix, Row)
import Lia.Markdown.Table.Types
    exposing
        ( Cell
        , Class(..)
        , State
        , Table
        , Vector
        , isNumber
        , toCell
        , toMatrix
        )
import Lia.Markdown.Table.Update as Sub
import Lia.Markdown.Update exposing (Msg(..))


view : (Inlines -> List (Html Msg)) -> Int -> Maybe Int -> Parameters -> Bool -> Table -> Vector -> Html Msg
view viewer width effectId attr mode table vector =
    let
        state =
            getState table.id vector
    in
    if diagramShow attr state.diagram then
        Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ]
            [ toggleBtn table.id "list"
            , table.body
                |> toMatrix effectId
                |> sort state
                |> (::) (List.map (toCell effectId) table.head)
                |> diagramTranspose attr
                |> chart width attr mode (diagramType table.class attr)
            ]

    else if table.head == [] && table.format == [] then
        state
            |> unformatted viewer (toMatrix effectId table.body) table.id
            |> toTable table.id attr (diagramType table.class attr) state.diagram

    else
        state
            |> formatted viewer table.head table.format (toMatrix effectId table.body) table.id
            |> toTable table.id attr (diagramType table.class attr) state.diagram


diagramShow : Parameters -> Bool -> Bool
diagramShow attr active =
    if Param.isSet "data-show" attr then
        not active

    else
        active


diagramTranspose : Parameters -> Matrix Cell -> Matrix Cell
diagramTranspose attr matrix =
    if Param.isSet "data-transpose" attr then
        Matrix.transpose matrix

    else
        matrix


diagramType : Class -> Parameters -> Class
diagramType default =
    Param.get "data-type"
        >> Maybe.map
            (String.toLower
                >> String.trim
                >> (\param ->
                        case param of
                            "lineplot" ->
                                LinePlot

                            "line" ->
                                LinePlot

                            "scatterplot" ->
                                ScatterPlot

                            "scatter" ->
                                ScatterPlot

                            "barchart" ->
                                BarChart

                            "bar" ->
                                BarChart

                            "piechart" ->
                                PieChart

                            "pie" ->
                                PieChart

                            "heatmap" ->
                                HeatMap

                            "map" ->
                                Map

                            "radar" ->
                                Radar

                            "parallel" ->
                                Parallel

                            "none" ->
                                None

                            _ ->
                                default
                   )
            )
        >> Maybe.withDefault default


chart : Int -> Parameters -> Bool -> Class -> Matrix Cell -> Html Msg
chart width attr mode class matrix =
    let
        ( head, body ) =
            Matrix.split matrix

        title =
            getTitle head
    in
    Html.div [ Attr.style "float" "left", Attr.style "width" "100%" ]
        [ case class of
            BarChart ->
                let
                    category =
                        body
                            |> List.map (List.head >> Maybe.map .string >> Maybe.withDefault "")
                in
                matrix
                    |> Matrix.transpose
                    |> Matrix.tail
                    |> List.map
                        (\row ->
                            ( row |> List.head |> Maybe.map .string
                            , row |> List.tail |> Maybe.map (List.map .float) |> Maybe.withDefault []
                            )
                        )
                    |> Chart.viewBarChart attr mode title category

            PieChart ->
                if
                    body
                        |> Matrix.column 0
                        |> Maybe.map (List.all isNumber)
                        |> Maybe.withDefault False
                then
                    body
                        |> Matrix.map .float
                        |> List.map
                            (List.map2 (\category -> Maybe.map (Tuple.pair category.string)) head
                                >> List.filterMap identity
                            )
                        |> Chart.viewPieChart width attr mode Nothing Nothing

                else
                    let
                        category =
                            head
                                |> List.tail
                                |> Maybe.withDefault []
                                |> List.map .string

                        sub =
                            body
                                |> List.head
                                |> Maybe.andThen List.head
                                |> Maybe.map .string

                        data =
                            body
                                |> List.head
                                |> Maybe.andThen List.tail
                                |> Maybe.withDefault []
                                |> List.map .float
                    in
                    List.map2 (\c -> Maybe.map (Tuple.pair c)) category data
                        |> List.filterMap identity
                        |> List.singleton
                        |> Chart.viewPieChart width attr mode title sub

            HeatMap ->
                let
                    y =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .string

                    x =
                        head
                            |> List.tail
                            |> Maybe.withDefault []
                            |> List.map .string
                            |> List.reverse
                in
                body
                    |> Matrix.transpose
                    |> Matrix.tail
                    |> List.indexedMap
                        (\y_ row ->
                            row
                                |> List.indexedMap (\x_ cell -> ( x_, y_, cell.float ))
                        )
                    |> Chart.viewHeatMap attr mode Nothing y x

            Radar ->
                let
                    categories =
                        head
                            |> List.tail
                            |> Maybe.map (List.map .string)
                            |> Maybe.withDefault []
                in
                body
                    |> List.map
                        (\row ->
                            ( row |> List.head |> Maybe.map .string |> Maybe.withDefault ""
                            , row |> List.tail |> Maybe.map (List.map .float) |> Maybe.withDefault []
                            )
                        )
                    |> Chart.viewRadarChart attr mode title categories

            Parallel ->
                Html.text "Parallel"

            Map ->
                let
                    categories =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .string

                    values =
                        body
                            |> Matrix.column 1
                            |> Maybe.withDefault []
                            |> List.map .float

                    data =
                        List.map2 Tuple.pair categories values
                in
                attr
                    |> Param.get "data-src"
                    |> Chart.viewMapChart attr mode title data

            _ ->
                let
                    xs : List (Maybe Float)
                    xs =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .float

                    legend =
                        head
                            |> List.tail
                            |> Maybe.withDefault []
                            |> List.map .string

                    type_ name pts =
                        if class == LinePlot then
                            Lines pts (Just name)

                        else
                            Dots pts (Just name)

                    diagrams =
                        body
                            |> Matrix.transpose
                            |> Matrix.tail
                            |> Matrix.map .float
                            |> List.map
                                (List.map2 (\x y -> Maybe.map2 Point x y) xs
                                    >> List.filterMap identity
                                )
                            |> List.map2 type_ legend
                            |> List.indexedMap (\i diagram -> ( Chart.getColor i, diagram ))
                in
                { title = ""
                , yLabel = ""
                , xLabel = title |> Maybe.withDefault ""
                , legend = legend
                , diagrams = diagrams |> Dict.fromList
                }
                    |> Chart.viewChart attr mode
        ]


getTitle : Row Cell -> Maybe String
getTitle =
    List.head >> Maybe.map .string


getState : Int -> Vector -> State
getState id =
    Array.get id >> Maybe.withDefault (State -1 False False)


toTable : Int -> Parameters -> Class -> Bool -> List (Html Msg) -> Html Msg
toTable id attr class diagram body =
    if class == None then
        Html.table (Param.annotation "lia-table" attr) body

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

                    Map ->
                        "map"

                    _ ->
                        "scatter_plot"
            , Html.div [] [ Html.table (Param.annotation "lia-table" attr) body ]
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


unformatted : (Inlines -> List (Html Msg)) -> Matrix Cell -> Int -> State -> List (Html Msg)
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


formatted : (Inlines -> List (Html Msg)) -> MultInlines -> List String -> Matrix Cell -> Int -> State -> List (Html Msg)
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
get i =
    if i == 0 then
        List.head

    else
        List.tail >> Maybe.andThen (get (i - 1))


sort : State -> Matrix Cell -> Matrix Cell
sort state matrix =
    if state.column /= -1 then
        let
            sorted =
                if
                    matrix
                        |> Matrix.column state.column
                        |> Maybe.map (List.all isNumber)
                        |> Maybe.withDefault False
                then
                    List.sortBy
                        (get state.column
                            >> Maybe.andThen .float
                            >> Maybe.withDefault 0
                        )
                        matrix

                else
                    List.sortBy (get state.column >> Maybe.map (.string >> String.toLower) >> Maybe.withDefault "") matrix
        in
        if state.dir then
            sorted

        else
            List.reverse sorted

    else
        matrix


view_head1 : (Inlines -> List (Html Msg)) -> Int -> State -> Row Cell -> List (Html Msg)
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
