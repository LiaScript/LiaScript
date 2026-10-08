module Lia.Markdown.Table.View exposing (view)

{- Example of a accessible table:
   <https://dequeuniversity.com/library/aria/table-sortable>
-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Live as A11y_Live
import Array
import Const
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed
import Html.Lazy as Lazy
import I18n.Translations as Translations exposing (Lang, sortAsc, sortDesc, sortNot)
import Lia.Markdown.Chart.Types exposing (Data, Diagram(..), Labels, Orientation(..), Point)
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.Config exposing (Config)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes as Param exposing (Parameters)
import Lia.Markdown.Inline.Stringify as Stringify
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix, Row)
import Lia.Markdown.Table.Types
    exposing
        ( Cell
        , Class(..)
        , State
        , Table
        , Vector
        , className
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
        if Array.isEmpty config.main.input.state then
            -- quiz inputs are only set within quizzes, elsewhere these keys define the chart
            Lazy.lazy8 viewLazyDiagram
                config.main.lang
                config.screen.width
                config.light
                config.main.scripts
                config.main.visible
                attr
                table
                state

        else
            viewDiagram config.main config.main.lang config.screen.width config.light attr table state

    else if table.head == [] && table.format == [] then
        toTable config.main.lang attr table (viewSimple config state table)

    else
        toTable config.main.lang attr table (viewFormatted config state table)


viewLazyDiagram : Lang -> Int -> Bool -> Scripts a -> Maybe Int -> Parameters -> Table -> State -> Html Msg
viewLazyDiagram lang width light scripts visible =
    viewDiagram
        { scripts = scripts
        , visible = visible
        , input = { state = Array.empty, options = Array.empty }
        }
        lang
        width
        light


viewDiagram : Stringify.Config config input a -> Lang -> Int -> Bool -> Parameters -> Table -> State -> Html Msg
viewDiagram main lang width light attr table state =
    Html.div
        [ blockKeydown (UpdateTable Sub.NoOp)
        , A11y_Live.polite
        ]
        [ toggleBtn table.id ( "table", "Table" )
        , table.head
            :: sort main state identity table.body
            |> toMatrix main
            |> diagramTranspose attr
            |> chart lang width (table.format /= []) attr light table.class
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
            Chart.viewPieChart settings width (pieData labels orientation head body)

        Funnel ->
            Chart.viewFunnel settings (pieData labels orientation head body)

        HeatMap ->
            let
                y =
                    firstColumn body
                        |> List.map .string
                        |> List.reverse

                x =
                    names head
            in
            Chart.viewHeatMap settings
                y
                { labels = labels
                , category = x
                , data =
                    body
                        |> valueColumns
                        |> List.indexedMap
                            (\y_ column ->
                                column
                                    |> List.reverse
                                    |> List.indexedMap (\x_ value -> ( y_, x_, value ))
                            )
                , orientation = orientation
                }

        Radar ->
            Chart.viewRadarChart settings
                { labels = labels
                , category =
                    names head
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
                    names head
                , data =
                    body
                        |> valueColumns
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
            Chart.viewGraph settings (graphData labels orientation head body)

        Sankey ->
            Chart.viewSankey settings (graphData labels orientation head body)

        Map ->
            let
                data =
                    if isFormatted then
                        body

                    else
                        matrix

                categories =
                    firstColumn data
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
                xs =
                    List.map .float (firstColumn body)
            in
            if List.all ((/=) Nothing) xs then
                -- numeric x values, one line or point series per column
                { title = labels.main |> Maybe.withDefault ""
                , yLabel = labels.y |> Maybe.withDefault ""
                , xLabel = labels.x |> Maybe.withDefault ""
                , legend = names head
                , diagrams =
                    body
                        |> valueColumns
                        |> List.map (List.map2 (Maybe.map2 Point) xs >> List.filterMap identity)
                        |> List.map2
                            (\name points ->
                                if class == LinePlot then
                                    Lines points (Just name)

                                else
                                    Dots points (Just name)
                            )
                            (names head)
                        |> List.indexedMap (\i diagram -> ( Chart.getColor i, diagram ))
                        |> Dict.fromList
                , xLimits = labels.xLimits
                , yLimits = labels.yLimits
                , orientation = orientation
                }
                    |> Chart.viewChart settings

            else
                -- categorical x values
                (if class == LinePlot then
                    Chart.viewLines

                 else
                    Chart.viewPoints
                )
                    settings
                    { labels = labels
                    , category = List.map .string (firstColumn body)
                    , orientation = orientation
                    , data =
                        body
                            |> valueColumns
                            |> List.map2 Tuple.pair (names head)
                    }


{-| The series names, the header without its first cell.
-}
names : Row Cell -> List String
names =
    List.drop 1 >> List.map .string


{-| The categories or x values of the rows.
-}
firstColumn : Matrix Cell -> Row Cell
firstColumn =
    Matrix.column 0 >> Maybe.withDefault []


{-| The numbers of all columns but the first, truncated to the shortest row.
-}
valueColumns : Matrix Cell -> Matrix (Maybe Float)
valueColumns =
    Matrix.transpose >> Matrix.tail >> Matrix.map .float


{-| Pie charts and funnels, one diagram per row if the first column holds
categories, otherwise every row is one diagram over the header.
-}
pieData : Labels -> Maybe Orientation -> Row Cell -> Matrix Cell -> Data (List ( String, Float ))
pieData labels orientation head body =
    if
        body
            |> Matrix.column 0
            |> Maybe.map (List.all isNumber)
            |> Maybe.withDefault False
    then
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
                names head
        in
        { labels = labels
        , category =
            firstColumn body
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


{-| Graphs and sankey diagrams, the table is an adjacency matrix with the
source nodes in the header and the target nodes in the first column.
-}
graphData : Labels -> Maybe Orientation -> Row Cell -> Matrix Cell -> Data ( String, String, Float )
graphData labels orientation head body =
    let
        nodesA =
            names head

        nodesB =
            firstColumn body
                |> List.map .string
    in
    { labels = labels
    , orientation = orientation
    , category =
        nodesA
            ++ nodesB
            |> Set.fromList
            |> Set.toList
            |> List.filter ((/=) "")
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


{-| The title is `data-title` or the table's corner cell.
-}
getLabels : Parameters -> Row Cell -> Labels
getLabels attr row =
    { main =
        case Param.get "data-title" attr of
            Just title ->
                Just title

            Nothing ->
                row
                    |> List.head
                    |> Maybe.andThen (.string >> nonEmpty)
    , x = Param.get "data-xlabel" attr
    , y = Param.get "data-ylabel" attr
    , xLimits = getMinMax "data-xlim" attr
    , yLimits = getMinMax "data-ylim" attr
    }


{-| Axis limits as "min,max", either one can be left empty.
-}
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


nonEmpty : String -> Maybe String
nonEmpty str =
    if str == "" then
        Nothing

    else
        Just str


getState : Int -> Vector -> State
getState id =
    Array.get id >> Maybe.withDefault (State -1 False False)


{-| Tables that can be shown as diagrams get a toggle button and a sticky
first column.
-}
toTable : Lang -> Parameters -> Table -> List (Html Msg) -> Html Msg
toTable lang attr table body =
    if table.class == None then
        viewTable False attr body

    else
        Html.div [ Attr.class "lia-plot" ]
            [ toggleBtn table.id ( className table.class, chartName lang table.class )
            , viewTable True attr body
            ]


chartName : Lang -> Class -> String
chartName lang class =
    case class of
        BarChart ->
            Translations.chartBar lang

        PieChart ->
            Translations.chartPie lang

        LinePlot ->
            Translations.chartLine lang

        HeatMap ->
            Translations.chartHeatmap lang

        Radar ->
            Translations.chartRadar lang

        Parallel ->
            Translations.chartParallel lang

        Graph ->
            Translations.chartGraph lang

        Map ->
            Translations.chartMap lang

        Sankey ->
            Translations.chartSankey lang

        ScatterPlot ->
            Translations.chartScatter lang

        BoxPlot ->
            Translations.chartBoxplot lang

        Funnel ->
            Translations.chartFunnel lang

        None ->
            ""


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
        [ Html.table (Param.annotation "lia-table" attr) body
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
        [ icon ("icon-" ++ name) []
        , Html.span [ Attr.class "lia-btn__text" ]
            [ Html.text title
            ]
        ]


{-| Simple tables without format line have no header, sort buttons are added
to their first row, which is sorted together with the others.
-}
viewSimple : Config sub -> State -> Table -> List (Html Msg)
viewSimple config state table =
    case sort config.main state identity table.body of
        head :: tail ->
            (head
                |> List.indexedMap
                    (\column ( attr, inlines ) ->
                        Html.td (Attr.class Const.align.default :: Param.toAttribute attr)
                            (header config state table Const.align.default column ( attr, inlines ))
                    )
                |> Html.tr [ Attr.class "lia-table__row" ]
            )
                :: List.map
                    (List.map (\( attr, inlines ) -> Html.td (Attr.class "lia-table__data" :: Param.toAttribute attr) (config.view inlines))
                        >> Html.tr [ Attr.class "lia-table__row" ]
                    )
                    tail

        [] ->
            []


{-| Tables with header and format line, the rows are keyed by their original
position, so that sorting moves their DOM nodes instead of rebuilding them.
-}
viewFormatted : Config sub -> State -> Table -> List (Html Msg)
viewFormatted config state table =
    [ List.map2 Tuple.pair table.format table.head
        |> List.indexedMap
            (\column ( format, ( attr, inlines ) ) ->
                Html.th
                    (Attr.class "lia-table__header"
                        :: (if table.id == column && state.column == column then
                                if state.dir then
                                    A11y_Aria.sortAscending

                                else
                                    A11y_Aria.sortDescending

                            else
                                A11y_Aria.sortNone
                           )
                        :: Attr.class format
                        :: Param.toAttribute attr
                    )
                    (header config state table format column ( attr, inlines ))
            )
        |> Html.tr []
        |> List.singleton
        |> Html.thead [ Attr.class "lia-table__head" ]
    , table.body
        |> List.indexedMap Tuple.pair
        |> sort config.main state Tuple.second
        |> List.map
            (\( i, row ) ->
                ( String.fromInt i
                , row
                    |> List.map2
                        (\format ( attr, inlines ) ->
                            Html.td
                                (Attr.class format
                                    :: Attr.class "lia-table__data"
                                    :: Param.toAttribute attr
                                )
                                (config.view inlines)
                        )
                        table.format
                    |> Html.tr [ Attr.class "lia-table__row" ]
                )
            )
        |> Keyed.node "tbody" [ Attr.class "lia-table__body" ]
    ]


{-| The content of a header cell and its sort button, which cycles through
ascending, descending and unsorted. `data-sortable` of a cell overrides the
table's setting.
-}
header : Config sub -> State -> Table -> String -> Int -> ( Parameters, Inlines ) -> List (Html Msg)
header config state table format column ( attr, inlines ) =
    let
        active =
            state.column == column
    in
    [ Html.span [ Attr.class format ] (config.view inlines)
    , if
        attr
            |> Param.isSetMaybe "data-sortable"
            |> Maybe.withDefault table.sortable
      then
        btnIcon
            { title =
                if not active then
                    sortAsc config.main.lang

                else if state.dir then
                    sortDesc config.main.lang

                else
                    sortNot config.main.lang
            , msg = Just <| UpdateTable <| Sub.Sort table.id column
            , tabbable = True
            , icon =
                if active && state.dir then
                    "icon-sort-asc"

                else
                    "icon-sort-desc"
            }
            [ Attr.class "lia-btn--transparent lia-table__sort"
            , Attr.classList [ ( "active", active ) ]
            ]

      else
        Html.text ""
    ]


{-| Sort the rows by `state.column`, numerically if every row has a number in
that column, otherwise by the lower case text. Only this column gets
stringified, `cells` picks the cells out of a row.
-}
sort : Stringify.Config config input a -> State -> (row -> Row ( Parameters, Inlines )) -> List row -> List row
sort config state cells rows =
    if state.column < 0 then
        rows

    else
        let
            keys =
                List.map (cells >> get state.column >> Maybe.map (toCell config)) rows

            sorted =
                List.map2 Tuple.pair keys rows
                    |> (if List.all (Maybe.map isNumber >> Maybe.withDefault False) keys then
                            List.sortBy (Tuple.first >> Maybe.andThen .float >> Maybe.withDefault 0)

                        else
                            List.sortBy (Tuple.first >> Maybe.map (.string >> String.toLower) >> Maybe.withDefault "")
                       )
                    |> List.map Tuple.second
        in
        if state.dir then
            sorted

        else
            List.reverse sorted
