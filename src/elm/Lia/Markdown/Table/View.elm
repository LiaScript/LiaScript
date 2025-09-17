module Lia.Markdown.Table.View exposing (view)

{- Example of a accessible table:
   <https://dequeuniversity.com/library/aria/table-sortable>
-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Array
import Const
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed
import I18n.Translations as Translations exposing (Lang, sortAsc, sortDesc, sortNot)
import Lia.Markdown.Chart.Types exposing (Diagram(..), Labels, Orientation(..), Point)
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.Config exposing (Config)
import Lia.Markdown.HTML.Attributes as Param exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix, Row)
import Lia.Markdown.Table.Types
    exposing
        ( Cell
        , Class(..)
        , State
        , Table
        , Vector
        , isEmpty
        , isNumber
        , toCell
        , toMatrix
        )
import Lia.Markdown.Table.Update as Sub
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Utils exposing (blockKeydown, btn, btnIcon, get, icon)
import Set


view : Config sub -> Parameters -> Table -> Html Msg
view config attr table =
    let
        state =
            getState table.id config.section.table_vector
    in
    if diagramShow attr state.diagram then
        viewDiagram
            config
            table
            state
            attr

    else if table.head == [] && table.format == [] then
        state
            |> unformatted config.main.lang table.sortable config.view (toMatrix config.main table.body) table.id
            |> toTable config.main.lang table.id attr table.class

    else
        state
            |> formatted config.main.lang table.sortable config.view table.head table.format (toMatrix config.main table.body) table.id
            |> toTable config.main.lang table.id attr table.class


viewDiagram : Config sub -> Table -> State -> Parameters -> Html Msg
viewDiagram config table state attr =
    Html.div
        [ blockKeydown (UpdateTable Sub.NoOp)
        , A11y_Live.polite
        ]
        [ toggleBtn table.id ( "table", "Table" )
        , table.body
            |> toMatrix config.main
            |> sort state
            |> (::) (List.indexedMap (toCell config.main -1) table.head)
            |> diagramTranspose attr
            |> chart config.main.lang config.screen.width (table.format /= []) attr config.light table.class
        ]


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


diagramOrientation : Parameters -> Maybe Orientation
diagramOrientation attr =
    case Param.get "data-orientation" attr of
        Just "horizontal" ->
            Just Horizontal

        Just "vertical" ->
            Just Vertical

        _ ->
            Nothing


chart : Lang -> Int -> Bool -> Parameters -> Bool -> Class -> Matrix Cell -> Html Msg
chart lang width isFormatted attr mode class matrix =
    let
        ( head, body ) =
            Matrix.split matrix

        labels =
            getLabels attr head

        settings =
            { lang = lang, attr = attr, light = mode }

        orientation =
            diagramOrientation attr
    in
    case class of
        BarChart ->
            Chart.viewBarChart settings
                { labels = labels
                , category =
                    body
                        |> List.map (List.head >> Maybe.map .string >> Maybe.withDefault "")
                , data =
                    matrix
                        |> Matrix.transpose
                        |> Matrix.tail
                        |> List.map
                            (\row ->
                                ( row |> List.head |> Maybe.map .string
                                , row |> List.tail |> Maybe.map (List.map .float) |> Maybe.withDefault []
                                )
                            )
                , orientation = orientation
                }

        PieChart ->
            if
                body
                    |> Matrix.column 0
                    |> Maybe.map (List.all isNumber)
                    |> Maybe.withDefault False
            then
                Chart.viewPieChart settings
                    width
                    { labels = labels
                    , category = []
                    , data =
                        body
                            |> Matrix.map .float
                            |> List.map
                                (List.map2 (\category -> Maybe.map (Tuple.pair category.string)) head
                                    >> List.filterMap identity
                                )
                    , orientation = orientation
                    }

            else
                let
                    classes =
                        head
                            |> List.tail
                            |> Maybe.withDefault []
                            |> List.map .string
                in
                Chart.viewPieChart settings
                    width
                    { labels = labels
                    , category =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .string
                    , data =
                        body
                            |> Matrix.map .float
                            |> List.filterMap List.tail
                            |> List.map
                                (List.map2 (\c -> Maybe.map (Tuple.pair c))
                                    classes
                                    >> List.filterMap identity
                                )
                    , orientation = orientation
                    }

        Funnel ->
            if
                body
                    |> Matrix.column 0
                    |> Maybe.map (List.all isNumber)
                    |> Maybe.withDefault False
            then
                Chart.viewFunnel settings
                    width
                    { labels = labels
                    , category = []
                    , data =
                        body
                            |> Matrix.map .float
                            |> List.map
                                (List.map2 (\category -> Maybe.map (Tuple.pair category.string)) head
                                    >> List.filterMap identity
                                )
                    , orientation = orientation
                    }

            else
                let
                    classes =
                        head
                            |> List.tail
                            |> Maybe.withDefault []
                            |> List.map .string
                in
                Chart.viewFunnel settings
                    width
                    { labels = labels
                    , category =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .string
                    , data =
                        body
                            |> Matrix.map .float
                            |> List.filterMap List.tail
                            |> List.map
                                (List.map2
                                    (\c ->
                                        Maybe.map (Tuple.pair c)
                                    )
                                    classes
                                    >> List.filterMap identity
                                )
                    , orientation = orientation
                    }

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
            in
            Chart.viewHeatMap settings
                y
                { labels = labels
                , category = x
                , data =
                    body
                        |> Matrix.transpose
                        |> Matrix.tail
                        |> List.indexedMap
                            (\y_ row ->
                                row
                                    |> List.indexedMap (\x_ cell -> ( x_, y_, cell.float ))
                            )
                , orientation = orientation
                }

        Radar ->
            Chart.viewRadarChart settings
                { labels = labels
                , category =
                    head
                        |> List.tail
                        |> Maybe.map (List.map .string)
                        |> Maybe.withDefault []
                , data =
                    body
                        |> List.map
                            (\row ->
                                ( row
                                    |> List.head
                                    |> Maybe.map .string
                                    |> Maybe.withDefault ""
                                , row
                                    |> List.tail
                                    |> Maybe.map (List.map .float)
                                    |> Maybe.withDefault []
                                )
                            )
                , orientation = orientation
                }

        Parallel ->
            Chart.viewParallel settings
                { labels = labels
                , category =
                    head
                        |> List.tail
                        |> Maybe.withDefault []
                        |> List.map .string
                , data =
                    body
                        |> Matrix.transpose
                        |> Matrix.tail
                        |> Matrix.map .float
                        |> Matrix.transpose
                , orientation = orientation
                }

        BoxPlot ->
            Chart.viewBoxPlot settings
                { labels = labels
                , category = List.map .string head
                , data =
                    body
                        |> Matrix.map .float
                        |> Matrix.transpose
                , orientation = orientation
                }

        Graph ->
            let
                nodesA =
                    head
                        |> List.tail
                        |> Maybe.withDefault []
                        |> List.map .string

                nodesB =
                    body
                        |> Matrix.column 0
                        |> Maybe.withDefault []
                        |> List.map .string

                nodes =
                    nodesA
                        ++ nodesB
                        |> Set.fromList
                        |> Set.toList
                        |> List.filter ((/=) "")
            in
            Chart.viewGraph settings
                { labels = labels
                , orientation = orientation
                , category = nodes
                , data =
                    body
                        |> List.concatMap
                            (\row ->
                                case row of
                                    [] ->
                                        []

                                    b :: values ->
                                        values
                                            |> List.map2
                                                (\a v ->
                                                    case v.float of
                                                        Just float ->
                                                            if float == 0 then
                                                                Nothing

                                                            else
                                                                Just ( a, b.string, float )

                                                        _ ->
                                                            Nothing
                                                )
                                                nodesA
                            )
                        |> List.filterMap identity
                        |> List.filter (\( a, b, _ ) -> a /= "" || b /= "")
                }

        Sankey ->
            let
                nodesA =
                    head
                        |> List.tail
                        |> Maybe.withDefault []
                        |> List.map .string

                nodesB =
                    body
                        |> Matrix.column 0
                        |> Maybe.withDefault []
                        |> List.map .string

                nodes =
                    nodesA
                        ++ nodesB
                        |> Set.fromList
                        |> Set.toList
                        |> List.filter ((/=) "")
            in
            Chart.viewSankey settings
                { labels = labels
                , category = nodes
                , orientation = orientation
                , data =
                    body
                        |> List.concatMap
                            (\row ->
                                case row of
                                    [] ->
                                        []

                                    b :: values ->
                                        values
                                            |> List.map2
                                                (\a v ->
                                                    case v.float of
                                                        Just float ->
                                                            if float == 0 then
                                                                Nothing

                                                            else
                                                                Just ( a, b.string, float )

                                                        _ ->
                                                            Nothing
                                                )
                                                nodesA
                            )
                        |> List.filterMap identity
                        |> List.filter (\( a, b, _ ) -> a /= "" || b /= "")
                }

        Map ->
            let
                data =
                    if isFormatted then
                        body

                    else
                        matrix

                categories =
                    data
                        |> Matrix.column 0
                        |> Maybe.withDefault []
                        |> List.map .string
            in
            Chart.viewMapChart settings
                (Param.get "data-src" attr)
                { labels = labels
                , orientation = orientation
                , category = []
                , data =
                    data
                        |> Matrix.column 1
                        |> Maybe.withDefault []
                        |> List.map .float
                        |> List.map2 Tuple.pair categories
                }

        _ ->
            let
                xs : List (Maybe Float)
                xs =
                    body
                        |> Matrix.column 0
                        |> Maybe.withDefault []
                        |> List.map .float
            in
            if
                xs
                    |> List.filterMap identity
                    |> List.length
                    |> (==) (List.length xs)
            then
                let
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
                { title = labels.main |> Maybe.withDefault ""
                , yLabel = labels.y |> Maybe.withDefault ""
                , xLabel = labels.x |> Maybe.withDefault ""
                , legend = legend
                , diagrams = diagrams |> Dict.fromList
                , xLimits = labels.xLimits
                , yLimits = labels.yLimits
                , orientation = orientation
                }
                    |> Chart.viewChart settings

            else
                let
                    xValues =
                        body
                            |> Matrix.column 0
                            |> Maybe.withDefault []
                            |> List.map .string

                    xLabels =
                        head
                            |> List.tail
                            |> Maybe.withDefault []
                            |> List.map .string
                in
                (if class == LinePlot then
                    Chart.viewLines

                 else
                    Chart.viewPoints
                )
                    settings
                    { labels = labels
                    , category = xValues
                    , orientation = orientation
                    , data =
                        body
                            |> Matrix.transpose
                            |> Matrix.tail
                            |> Matrix.map .float
                            |> List.map2 Tuple.pair xLabels
                    }


getLabels : Parameters -> Row Cell -> Labels
getLabels attr row =
    { main =
        case Param.get "data-title" attr of
            Just title ->
                Just title

            Nothing ->
                row
                    |> List.head
                    |> Maybe.andThen (.string >> isEmpty)
    , x =
        Param.get "data-xlabel" attr
    , y =
        Param.get "data-ylabel" attr
    , xLimits = getMinMax "data-xlim" attr
    , yLimits = getMinMax "data-ylim" attr
    }


getMinMax : String -> Parameters -> { min : Maybe String, max : Maybe String }
getMinMax name attr =
    case Param.get name attr |> Maybe.map (String.split "," >> List.map String.trim) of
        Just [ "", "" ] ->
            { min = Nothing, max = Nothing }

        Just [ "", max ] ->
            { min = Nothing, max = Just max }

        Just [ min, "" ] ->
            { min = Just min, max = Nothing }

        Just [ min ] ->
            { min = Just min, max = Nothing }

        Just [ min, max ] ->
            { min = Just min, max = Just max }

        _ ->
            { min = Nothing, max = Nothing }


getState : Int -> Vector -> State
getState id =
    Array.get id >> Maybe.withDefault (State -1 False False)


toTable : Lang -> Int -> Parameters -> Class -> List (Html Msg) -> Html Msg
toTable lang id attr class body =
    if class == None then
        viewTable False attr body

    else
        Html.div [ Attr.class "lia-plot" ]
            [ toggleBtn id <|
                case class of
                    BarChart ->
                        ( "barchart", Translations.chartBar lang )

                    PieChart ->
                        ( "piechart", Translations.chartPie lang )

                    LinePlot ->
                        ( "lineplot", Translations.chartLine lang )

                    HeatMap ->
                        ( "heatmap", Translations.chartHeatmap lang )

                    Radar ->
                        ( "radar", Translations.chartRadar lang )

                    Parallel ->
                        ( "parallel", Translations.chartParallel lang )

                    Graph ->
                        ( "graph", Translations.chartGraph lang )

                    Map ->
                        ( "map", Translations.chartMap lang )

                    Sankey ->
                        ( "sankey", Translations.chartSankey lang )

                    ScatterPlot ->
                        ( "scatterplot", Translations.chartScatter lang )

                    BoxPlot ->
                        ( "boxplot", Translations.chartBoxplot lang )

                    Funnel ->
                        ( "funnel", Translations.chartFunnel lang )

                    None ->
                        ( "", "" )
            , viewTable True attr body
            ]


viewTable : Bool -> Parameters -> List (Html msg) -> Html msg
viewTable sticky attr body =
    Html.div
        [ Attr.classList
            [ ( "lia-table-responsive", True )
            , ( "has-thead-sticky", True )
            , ( "has-first-col-sticky", sticky )
            ]
        , A11y_Live.polite
        ]
        [ Html.table
            (A11y_Role.grid :: A11y_Aria.readOnly True :: Param.annotation "lia-table" attr)
            body
        ]


toggleBtn : Int -> ( String, String ) -> Html Msg
toggleBtn id ( name, title ) =
    btn
        { title = title
        , msg = Just <| UpdateTable <| Sub.Toggle id
        , tabbable = True
        }
        [ Attr.class "lia-btn--outline lia-plot__switch mb-1"
        , A11y_Aria.label <|
            if name == "table" then
                "switch to table representation"

            else
                "switch to visualization in mode " ++ title
        ]
        [ --Html.img
          -- [ Attr.height 16
          -- , Attr.width 16
          -- , Attr.src <| "img/" ++ icon ++ ".png"
          -- ]
          -- []
          icon ("icon-" ++ name) []
        , Html.span [ Attr.class "lia-btn__text" ]
            [ Html.text title
            ]
        ]


unformatted : Lang -> Bool -> (Inlines -> List (Html Msg)) -> Matrix Cell -> Int -> State -> List (Html Msg)
unformatted lang sortable viewer rows id state =
    case sort state rows of
        head :: tail ->
            tail
                |> List.map
                    (List.map (\e -> Html.td (Attr.class "lia-table__data" :: Param.toAttribute e.attr) (viewer e.inlines))
                        >> Html.tr [ Attr.class "lia-table__row", A11y_Role.row ]
                    )
                |> (::)
                    (head
                        |> view_head1 lang sortable viewer id state
                        |> Html.tr [ Attr.class "lia-table__row", A11y_Role.row ]
                    )

        [] ->
            []


formatted : Lang -> Bool -> (Inlines -> List (Html Msg)) -> List ( Parameters, Inlines ) -> List String -> Matrix Cell -> Int -> State -> List (Html Msg)
formatted lang sortable viewer head format rows id state =
    [ head
        |> view_head2 lang sortable viewer id format state
        |> Html.tr [ A11y_Role.row ]
        |> List.singleton
        |> Html.thead [ Attr.class "lia-table__head" ]
    , rows
        |> sort state
        |> List.map
            (List.indexedMap Tuple.pair
                >> List.map2
                    (\f ( i, e ) ->
                        ( e.id
                        , Html.td
                            (e.attr
                                |> Param.toAttribute
                                |> (::) (Attr.class "lia-table__data")
                                |> (::) (Attr.class f)
                                |> (if i == 0 then
                                        List.append
                                            [ A11y_Role.rowHeader
                                            , Attr.scope "row"
                                            ]

                                    else
                                        (::) A11y_Role.gridCell
                                   )
                            )
                            (viewer e.inlines)
                        )
                    )
                    format
                >> List.unzip
                >> Tuple.mapFirst String.concat
                >> Tuple.mapSecond (Html.tr [ Attr.class "lia-table__row", A11y_Role.row ])
            )
        |> Keyed.node "tbody" [ Attr.class "lia-table__body" ]
    ]


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
                    List.sortBy
                        (get state.column
                            >> Maybe.map (.string >> String.toLower)
                            >> Maybe.withDefault ""
                        )
                        matrix
        in
        if state.dir then
            sorted

        else
            List.reverse sorted

    else
        matrix


view_head1 : Lang -> Bool -> (Inlines -> List (Html Msg)) -> Int -> State -> Row Cell -> List (Html Msg)
view_head1 lang sortable viewer id state =
    List.indexedMap
        (\i r ->
            header
                { lang = lang
                , viewer = viewer
                , id = id
                , format = Const.align.default
                , state = state
                , column = i
                , inline = r.inlines
                , sortable = isSortable sortable r.attr
                }
                |> Html.td (Attr.class Const.align.default :: Param.toAttribute r.attr)
        )


view_head2 : Lang -> Bool -> (Inlines -> List (Html Msg)) -> Int -> List String -> State -> List ( Parameters, Inlines ) -> List (Html Msg)
view_head2 lang sortable viewer id format state =
    List.map2 Tuple.pair format
        >> List.indexedMap
            (\i ( f, ( a, r ) ) ->
                header
                    { lang = lang
                    , viewer = viewer
                    , id = id
                    , format = f
                    , state = state
                    , column = i
                    , inline = r
                    , sortable = isSortable sortable a
                    }
                    |> Html.th
                        (Attr.class "lia-table__header"
                            :: (if i == id && state.column == i then
                                    if state.dir then
                                        A11y_Aria.sortAscending

                                    else
                                        A11y_Aria.sortDescending

                                else
                                    Attr.class ""
                               )
                            :: Attr.scope "col"
                            :: A11y_Role.columnHeader
                            :: Attr.class f
                            :: Param.toAttribute a
                        )
            )


isSortable : Bool -> Parameters -> Bool
isSortable default attr =
    Param.isSetMaybe "data-sortable" attr
        |> Maybe.withDefault default


header :
    { lang : Lang
    , viewer : Inlines -> List (Html Msg)
    , id : Int
    , format : String
    , state : State
    , column : Int
    , inline : Inlines
    , sortable : Bool
    }
    -> List (Html Msg)
header { lang, viewer, id, format, state, column, inline, sortable } =
    [ Html.span [ Attr.class format ] (viewer inline)
    , if sortable then
        btnIcon
            { title =
                if state.column == column && state.dir then
                    sortDesc lang

                else if state.column == column && not state.dir then
                    sortNot lang

                else
                    sortAsc lang
            , msg = Just <| UpdateTable <| Sub.Sort id column
            , tabbable = True
            , icon =
                if state.column == column then
                    if state.dir then
                        "icon-sort-asc"

                    else
                        "icon-sort-desc"

                else
                    "icon-sort-desc"
            }
            [ Attr.class "lia-btn--transparent lia-table__sort"
            , Attr.class <|
                if state.column == column then
                    "active"

                else
                    ""
            ]

      else
        Html.text ""
    ]
