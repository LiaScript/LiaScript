module Lia.Markdown.Chart.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andMap
        , ignore
        , keep
        , many1
        , map
        , maybe
        , optional
        , or
        , regex
        , string
        , whitespace
        )
import Combine.Num exposing (float, int)
import Dict exposing (Dict)
import Lia.Markdown.Chart.Types exposing (Chart, Diagram(..), Point)
import Lia.Parser.Context exposing (Context)
import Set


parse : Parser Context Chart
parse =
    let
        chart title y_max rows y_min ( x_label, ( x0, x_segment ) ) =
            let
                ( y0, y_segment ) =
                    segmentation (List.length rows) y_min y_max

                ( label, data ) =
                    List.unzip rows

                ( y_label, data_labels ) =
                    List.unzip label

                labels =
                    data_labels
                        |> List.filterMap identity
                        |> Dict.fromList
            in
            data
                |> List.reverse
                |> List.indexedMap Tuple.pair
                |> List.map
                    (\( y, l ) ->
                        l
                            |> Dict.map
                                (\_ xs ->
                                    xs
                                        |> List.map
                                            (\x ->
                                                Point (toFloat x * x_segment + x0)
                                                    (toFloat y * y_segment + y0)
                                            )
                                )
                    )
                |> List.foldr magicMerge Dict.empty
                |> Dict.map (\_ v -> List.sortBy .x v)
                |> Dict.map
                    (\k v ->
                        if v |> List.map .x |> unique Nothing then
                            labels
                                |> Dict.get (String.fromChar k)
                                |> Lines v

                        else
                            labels
                                |> Dict.get (String.fromChar k)
                                |> Dots v
                    )
                |> Chart
                    title
                    (y_label |> String.concat |> String.trim)
                    x_label
                    (Dict.values labels)
    in
    optional "" (regex "[\t ]*[a-zA-Z0-9 .\\\\()\\-]+\\n")
        |> map (String.trim >> chart)
        |> andMap (regex "[\t ]*" |> keep number |> optional 1.0)
        |> andMap (many1 row)
        |> andMap (regex "[\t ]*" |> keep number |> optional 0.0)
        |> andMap x_axis


unique : Maybe a -> List a -> Bool
unique start list =
    case ( list, start ) of
        ( x :: xs, Nothing ) ->
            unique (Just x) xs

        ( x :: xs, Just s ) ->
            if x == s then
                False

            else
                unique (Just x) xs

        _ ->
            True


magicMerge : Dict comparable (List a) -> Dict comparable (List a) -> Dict comparable (List a)
magicMerge left right =
    Dict.merge Dict.insert (\key l r dict -> Dict.insert key (l ++ r) dict) Dict.insert left right Dict.empty


row : Parser Context ( ( String, Maybe ( String, String ) ), Dict Char (List Int) )
row =
    let
        indexes y_label str label =
            ( ( y_label
                    |> String.trim
                    |> (\w ->
                            if w == "" then
                                " "

                            else
                                w
                       )
              , label
              )
            , str
                |> String.toList
                |> Set.fromList
                |> Set.remove ' '
                |> Set.toList
                |> List.map (\c -> ( c, String.indexes (String.fromChar c) str ))
                |> Dict.fromList
            )
    in
    regex "[^\n|]*"
        |> ignore (string "|")
        |> map indexes
        |> andMap (regex "[ \\*a-zA-Z\\+#]*")
        |> andMap
            (maybe
                (string "("
                    |> ignore whitespace
                    |> keep (regex "[A-Za-z\\+\\*#]?")
                    |> map Tuple.pair
                    |> andMap (regex "[^)]+")
                    |> ignore (string ")")
                )
            )
        |> ignore (regex "[\t ]*\\n")


segmentation : Int -> Float -> Float -> ( Float, Float )
segmentation elements i0 i1 =
    ( i0, (i1 - i0) / toFloat elements )


x_axis : Parser Context ( String, ( Float, Float ) )
x_axis =
    regex "[\t ]*\\+"
        |> keep (regex "\\-+")
        |> ignore (regex "[\t ]*\\n[\t ]*")
        |> map (\e x0 x_label x1 -> ( String.trim x_label, segmentation (String.length e) x0 x1 ))
        |> andMap (optional 0.0 number)
        |> andMap (optional "" (regex "[a-zA-Z_ .\\\\()\\-]+"))
        |> andMap (optional 1.0 (regex "[\t ]*" |> keep number |> ignore (regex "[\t ]*\\n")))


number : Parser Context Float
number =
    int
        |> ignore (string "." |> optional ".")
        |> map toFloat
        |> or float
