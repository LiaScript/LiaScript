module Lia.Markdown.Table.Parser exposing (classify, parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , choice
        , ignore
        , keep
        , many
        , many1
        , manyTill
        , map
        , modifyState
        , onsuccess
        , optional
        , or
        , regex
        , sepEndBy
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes as Param exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (annotations, line)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)
import Lia.Markdown.Table.Types
    exposing
        ( Cell
        , Class(..)
        , State
        , Table
        , isNumber
        , toCell
        , toMatrix
        )
import Lia.Parser.Context exposing (Context, indentation, indentation_skip)
import Lia.Parser.Helper exposing (spaces)
import Set


parse : Parser Context Table
parse =
    indentation_skip
        |> keep (or formated simple)
        |> modify_State


classify : Parameters -> Table -> Scripts a -> Table
classify attr table js =
    { table
        | class =
            case diagramType attr of
                Just class ->
                    class

                _ ->
                    if Param.get "data-src" attr /= Nothing then
                        Map

                    else
                        let
                            matrix =
                                if Param.isSet "data-transpose" attr then
                                    { table
                                        | head =
                                            case List.head table.head of
                                                Nothing ->
                                                    []

                                                Just cell ->
                                                    table.body
                                                        |> Matrix.column 0
                                                        |> Maybe.withDefault []
                                                        |> (::) cell
                                        , body =
                                            table.head
                                                :: table.body
                                                |> Matrix.transpose
                                                |> Matrix.split
                                                |> Tuple.second
                                    }

                                else
                                    table
                        in
                        checkDiagram
                            (if matrix.head == [] then
                                Nothing

                             else
                                matrix.head
                                    |> List.map (toCell js Nothing)
                                    |> Just
                            )
                            (toMatrix js Nothing matrix.body)
    }


diagramType : Parameters -> Maybe Class
diagramType =
    Param.get "data-type"
        >> Maybe.withDefault ""
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
                        Just Map

                    "radar" ->
                        Just Radar

                    "graph" ->
                        Just Graph

                    "parallel" ->
                        Just Parallel

                    "sankey" ->
                        Just Sankey

                    "boxplot" ->
                        Just BoxPlot

                    "funnel" ->
                        Just Funnel

                    "none" ->
                        Just None

                    _ ->
                        Nothing
           )


checkDiagram : Maybe (List Cell) -> Matrix Cell -> Class
checkDiagram headLine rows =
    if
        -- if body has numbers ...
        rows
            |> List.filterMap List.tail
            |> Matrix.any isNumber
    then
        let
            -- get first column
            firstColumn =
                List.map (List.head >> Maybe.andThen .float) rows
        in
        -- all element in first column are numbers
        if List.all ((/=) Nothing) firstColumn then
            -- headline contains elements and there is exactly one row
            if headLine /= Nothing && List.length firstColumn == 1 then
                PieChart

            else if
                -- thera are only unique numbers in first column
                firstColumn
                    |> List.filterMap identity
                    |> Set.fromList
                    |> Set.size
                    |> (==) (List.length firstColumn)
            then
                let
                    -- get all numbers from headline
                    headNumbers =
                        headLine
                            |> Maybe.andThen List.tail
                            |> Maybe.map (List.map .float)
                            |> Maybe.withDefault [ Nothing ]
                in
                if
                    --
                    List.length headNumbers
                        > 1
                        && List.all ((/=) Nothing) headNumbers
                then
                    HeatMap

                else if
                    rows
                        |> Matrix.transpose
                        |> Matrix.split
                        |> Tuple.second
                        |> Matrix.some 0.3 isNumber
                then
                    LinePlot

                else
                    None

            else if
                rows
                    |> Matrix.transpose
                    |> Matrix.split
                    |> Tuple.second
                    |> Matrix.some 0.3 isNumber
            then
                ScatterPlot

            else
                None

        else if headLine /= Nothing then
            if List.length firstColumn == 1 then
                --True
                PieChart

            else if
                -- check if x ans y are qual
                (headLine
                    |> Maybe.andThen List.tail
                    |> Maybe.map (List.map .string)
                )
                    == (rows
                            |> Matrix.column 0
                            |> Maybe.map (List.map .string)
                       )
            then
                Graph

            else if
                (List.length rows
                    * (headLine
                        |> Maybe.map List.length
                        |> Maybe.withDefault 1
                      )
                )
                    >= 50
            then
                Parallel

            else
                let
                    maxima =
                        rows
                            |> Matrix.transpose
                            |> Matrix.split
                            |> Tuple.second
                            |> Matrix.map .float
                            |> List.map (List.filterMap identity >> List.maximum)
                            |> List.filterMap identity
                in
                if (maxima |> List.maximum |> Maybe.withDefault 0 |> abs) > 10 * (maxima |> List.minimum |> Maybe.withDefault 0 |> abs) then
                    Radar

                else
                    BarChart

        else
            None

    else
        None


row : Parser Context (List ( Parameters, Inlines ))
row =
    indentation
        |> keep
            (manyTill
                (string "|"
                    |> ignore spaces
                    |> ignore macro
                    |> keep annotations
                    |> map Tuple.pair
                    -- maybe empty cell
                    |> andMap (optional [] line)
                )
                (regex "\\|[\t ]*\\n")
            )


simple : Parser Context (Int -> Table)
simple =
    row
        |> many1
        |> map (Table None [] [])


formated : Parser Context (Int -> Table)
formated =
    row
        |> map (Table None)
        |> andMap format
        |> andMap (many row)


format : Parser Context (List String)
format =
    indentation
        |> ignore (string "|")
        |> keep
            (sepEndBy (string "|")
                (choice
                    [ regex "[\t ]*:-{3,}:[\t ]*" |> onsuccess "center"
                    , regex "[\t ]*:-{3,}[\t ]*" |> onsuccess "left"
                    , regex "[\t ]*-{3,}:[\t ]*" |> onsuccess "right"
                    , regex "[\t ]*-{3,}[\t ]*" |> onsuccess "left"
                    ]
                )
            )
        |> ignore (regex "[\t ]*\\n")


modify_State : Parser Context (Int -> Table) -> Parser Context Table
modify_State =
    andMap (withState (.table_vector >> Array.length >> succeed))
        >> ignore
            (modifyState
                (\s ->
                    { s
                        | table_vector = Array.push (State -1 False False) s.table_vector
                    }
                )
            )
