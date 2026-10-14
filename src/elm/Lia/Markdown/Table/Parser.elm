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
            [ None, LinePlot, ScatterPlot, BarChart, PieChart, HeatMap, Radar, Parallel, Sankey, BoxPlot, Graph, Map, Funnel, WordCloud ]
                |> List.filter (className >> (==) name)
                |> List.head

        _ ->
            Nothing


{-| Guess the diagram type of a table with the header `headLine` (`Nothing`
for simple tables) and the rows `rows`. Tables need more numeric than text
columns besides the first one, otherwise they stay plain tables.
-}
checkDiagram : Maybe (List Cell) -> Matrix Cell -> Class
checkDiagram headLine rows =
    let
        firstColumn =
            List.map (List.head >> Maybe.andThen .float) rows

        -- all columns but the first, truncated to the shortest row, a column
        -- is numeric if most of its filled cells are numbers
        ( numeric, text ) =
            rows
                |> Matrix.transpose
                |> Matrix.tail
                |> List.map (List.filter (.string >> (/=) ""))
                |> List.filter ((/=) [])
                |> List.partition (\column -> 2 * List.length (List.filter isNumber column) > List.length column)

        numbers =
            numeric
                |> Matrix.map .float
                |> List.map (List.filterMap identity)

        -- at least two numeric column names, numbers on both axes
        numericHead =
            case headLine |> Maybe.andThen List.tail of
                Just ((_ :: _ :: _) as names) ->
                    List.all isNumber names

                _ ->
                    False
    in
    if List.length numeric <= List.length text then
        None

    else if
        -- an adjacency matrix with equal row and column names, self-references
        -- on the diagonal are not supported by graphs
        Maybe.map (List.drop 1 >> List.map .string) headLine
            == Maybe.map (List.map .string) (Matrix.column 0 rows)
    then
        if
            rows
                |> List.indexedMap (\i -> List.drop (i + 1) >> List.head >> Maybe.andThen .float)
                |> List.all (Maybe.withDefault 0 >> (==) 0)
        then
            Graph

        else
            HeatMap

    else if List.all (List.all (\x -> x == 0 || x == 1)) (List.filterMap identity firstColumn :: numbers) then
        -- truth tables
        None

    else if List.isSingleton rows then
        -- the shares of a pie are positive, digits of place value tables not
        if
            headLine
                /= Nothing
                && List.all (List.all (.float >> Maybe.withDefault 0 >> (<) 0) << List.drop 1) rows
        then
            PieChart

        else
            None

    else if List.all ((/=) Nothing) firstColumn then
        -- the first column holds x values
        if
            numericHead
                && (firstColumn
                        |> List.filterMap identity
                        |> Set.fromList
                        |> Set.size
                        |> (==) (List.length rows)
                   )
        then
            HeatMap

        else if monotonic (List.filterMap identity firstColumn) then
            LinePlot

        else
            ScatterPlot

    else
        -- the first column holds categories
        case headLine of
            Nothing ->
                None

            Just head ->
                let
                    maxima =
                        numbers
                            |> List.filterMap (List.map abs >> List.maximum)
                            |> List.filter ((<) 0)
                in
                if
                    -- dates and times like 2024-03-01, 01.05.2024 or 08:00
                    rows
                        |> List.filterMap (List.head >> Maybe.map .string)
                        |> List.filter ((/=) "")
                        |> List.all (String.left 1 >> String.all Char.isDigit)
                then
                    LinePlot

                else if List.length numeric >= 3 && List.length rows * List.length head >= 50 then
                    Parallel

                else if
                    -- the column maxima differ by more than an order of magnitude
                    Maybe.withDefault 0 (List.maximum maxima) > 10 * Maybe.withDefault 0 (List.minimum maxima)
                then
                    if List.length numeric >= 3 then
                        Radar

                    else
                        Parallel

                else
                    BarChart


{-| Strictly increasing or decreasing x values can be connected by lines.
-}
monotonic : List Float -> Bool
monotonic xs =
    let
        steps =
            List.map2 (-) (List.drop 1 xs) xs
    in
    List.all ((<) 0) steps || List.all ((>) 0) steps


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
