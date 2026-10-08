module Lia.Markdown.Table.Parser exposing
    ( classify
    , parse
    )

import Array exposing (Array)
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
import Const
import Helper.List as List
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes as Param exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (annotations, line2)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Multi.Types as Input
import Lia.Markdown.Table.Matrix as Matrix exposing (Matrix)
import Lia.Markdown.Table.Types
    exposing
        ( Cell
        , Class(..)
        , State
        , Table
        , className
        , isNumber
        , toCell
        , toMatrix
        )
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (spaces)
import Lia.Parser.Indentation as Indent
import Set


parse : Parser Context Table
parse =
    Indent.skip
        |> keep (or formatted simple)
        |> modify_State


{-| Set `sortable` and the diagram type, either given by `data-type`, a map
for `data-src`, or guessed from the cell contents. `data-transpose` swaps rows
and columns before guessing.
-}
classify : Parameters -> Table -> ( Scripts a, Maybe { i | solution : Input.State, options : Array (List Inlines) } ) -> Table
classify attr table config =
    { table
        | sortable =
            attr
                |> Param.isSetMaybe "data-sortable"
                |> Maybe.withDefault True
        , class =
            case diagramType attr of
                Just class ->
                    class

                Nothing ->
                    if Param.get "data-src" attr /= Nothing then
                        Map

                    else
                        let
                            ( head, body ) =
                                if Param.isSet "data-transpose" attr then
                                    table.head
                                        :: table.body
                                        |> Matrix.transpose
                                        |> Matrix.split

                                else
                                    ( table.head, table.body )
                        in
                        checkDiagram
                            (if head == [] then
                                Nothing

                             else
                                Just (List.map (toCell (initConfig config)) head)
                            )
                            (toMatrix (initConfig config) body)
    }


{-| Stringify cells with the quiz solutions, tables within quizzes are
classified by their solved state.
-}
initConfig :
    ( Scripts a
    , Maybe { i | solution : Array x, options : Array y }
    )
    ->
        { scripts : Scripts a
        , visible : Maybe Int
        , input :
            { state : Array x
            , options : Array y
            }
        }
initConfig ( scripts, input ) =
    { scripts = scripts
    , visible = Nothing
    , input =
        { state =
            input
                |> Maybe.map .solution
                |> Maybe.withDefault Array.empty
        , options =
            input
                |> Maybe.map .options
                |> Maybe.withDefault Array.empty
        }
    }


{-| The `data-type` attribute, also accepts the short names line, scatter,
bar and pie.
-}
diagramType : Parameters -> Maybe Class
diagramType attr =
    case attr |> Param.get "data-type" |> Maybe.map (String.trim >> String.toLower) of
        Just "line" ->
            Just LinePlot

        Just "scatter" ->
            Just ScatterPlot

        Just "bar" ->
            Just BarChart

        Just "pie" ->
            Just PieChart

        Just name ->
            [ None, LinePlot, ScatterPlot, BarChart, PieChart, HeatMap, Radar, Parallel, Sankey, BoxPlot, Graph, Map, Funnel ]
                |> List.filter (className >> (==) name)
                |> List.head

        Nothing ->
            Nothing


{-| Guess the diagram type of a table with the header `headLine` (`Nothing`
for simple tables) and the rows `rows`. Tables without numbers outside of the
first column stay plain tables.
-}
checkDiagram : Maybe (List Cell) -> Matrix Cell -> Class
checkDiagram headLine rows =
    let
        firstColumn =
            List.map (List.head >> Maybe.andThen .float) rows

        -- all columns but the first, truncated to the shortest row
        values =
            rows
                |> Matrix.transpose
                |> Matrix.tail

        mostlyNumbers =
            Matrix.some 0.3 isNumber values

        -- at least two numeric column names, numbers on both axes
        numericHead =
            case headLine |> Maybe.andThen List.tail of
                Just ((_ :: _ :: _) as names) ->
                    List.all isNumber names

                _ ->
                    False
    in
    if not (rows |> List.filterMap List.tail |> Matrix.any isNumber) then
        None

    else if List.all ((/=) Nothing) firstColumn then
        -- the first column holds x values
        if headLine /= Nothing && List.isSingleton rows then
            PieChart

        else if
            firstColumn
                |> List.filterMap identity
                |> Set.fromList
                |> Set.size
                |> (==) (List.length rows)
        then
            if numericHead then
                HeatMap

            else if mostlyNumbers then
                LinePlot

            else
                None

        else if mostlyNumbers then
            ScatterPlot

        else
            None

    else
        -- the first column holds categories
        case headLine of
            Nothing ->
                None

            Just head ->
                if List.isSingleton rows then
                    PieChart

                else if
                    -- an adjacency matrix with equal row and column names
                    Just (List.map .string (List.drop 1 head))
                        == Maybe.map (List.map .string) (Matrix.column 0 rows)
                then
                    Graph

                else if List.length rows * List.length head >= 50 then
                    Parallel

                else
                    let
                        maxima =
                            values
                                |> Matrix.map .float
                                |> List.filterMap (List.filterMap identity >> List.maximum)

                        bound =
                            Maybe.withDefault 0 >> abs
                    in
                    -- the column maxima differ by more than an order of magnitude
                    if bound (List.maximum maxima) > 10 * bound (List.minimum maxima) then
                        Radar

                    else
                        BarChart


row : Parser Context (List ( Parameters, Inlines ))
row =
    Indent.check
        |> keep
            (manyTill
                (string "|"
                    |> ignore spaces
                    |> ignore macro
                    |> keep annotations
                    |> map Tuple.pair
                    |> andMap (optional [] line2)
                )
                (regex "\\|[\t ]*\n")
            )


simple : Parser Context (Int -> Table)
simple =
    row
        |> many1
        |> map (Table None True [] [])


formatted : Parser Context (Int -> Table)
formatted =
    row
        |> map (Table None True)
        |> andMap format
        |> andMap (many row)


format : Parser Context (List String)
format =
    Indent.check
        |> ignore (string "|")
        |> keep
            (sepEndBy (string "|")
                (choice
                    [ regex "[\t ]*:-+:[\t ]*" |> onsuccess Const.align.center
                    , regex "[\t ]*:-+[\t ]*" |> onsuccess Const.align.left
                    , regex "[\t ]*-+:[\t ]*" |> onsuccess Const.align.right
                    , regex "[\t ]*-+[\t ]*" |> onsuccess Const.align.default
                    ]
                )
            )
        |> ignore (regex "[\t ]*\n")


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
