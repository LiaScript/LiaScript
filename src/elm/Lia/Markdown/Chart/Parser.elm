module Lia.Markdown.Chart.Parser exposing (parse)

import Combine exposing (..)
import Combine.Num exposing (float, int)
import Dict exposing (Dict)
import Lia.Helper exposing (..)
import Lia.Markdown.Chart.Types exposing (..)
import Lia.PState exposing (PState)
import Set


parse : Parser PState Chart
parse =
    let
        chart title y_max rows y_min ( x_label, ( x0, x_segment ) ) =
            let
                ( y0, y_segment ) =
                    segmentation (List.length rows) y_min y_max

                ( y_label, data ) =
                    List.unzip rows
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
                    (\_ v ->
                        if v |> List.map .x |> unique Nothing then
                            Line v

                        else
                            Dots v
                    )
                |> Chart
                    title
                    (y_label |> String.concat |> String.trim)
                    x_label
    in
    optional "" (regex "[\t ]*[a-zA-Z0-9 .\\\\()\\-]+\\n")
        |> map chart
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

        ( x, _ ) ->
            True


magicMerge : Dict comparable (List a) -> Dict comparable (List a) -> Dict comparable (List a)
magicMerge left right =
    Dict.merge Dict.insert (\key l r dict -> Dict.insert key (l ++ r) dict) Dict.insert left right Dict.empty


row : Parser PState ( String, Dict Char (List Int) )
row =
    let
        indexes y_label str =
            ( y_label
                |> String.trim
                |> (\w ->
                        if w == "" then
                            " "

                        else
                            w
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
        |> andMap
            (regex "[ \\*a-zA-Z\\+#]*" |> ignore (regex "[\t ]*\\n"))


segmentation : Int -> Float -> Float -> ( Float, Float )
segmentation elements i0 i1 =
    ( i0, (i1 - i0) / toFloat elements )


x_axis : Parser PState ( String, ( Float, Float ) )
x_axis =
    regex "[\t ]*\\+"
        |> keep (regex "\\-+")
        |> ignore (regex "[\t ]*\\n[\t ]*")
        |> map (\e x0 x_label x1 -> ( String.trim x_label, segmentation (String.length e) x0 x1 ))
        |> andMap (optional 0.0 number)
        |> andMap (optional "" (regex "[a-zA-Z_ .\\\\()\\-]+"))
        |> andMap (optional 1.0 (regex "[\t ]*" |> keep number |> ignore (regex "[\t ]*\\n")))


number : Parser PState Float
number =
    int
        |> ignore (string "." |> optional ".")
        |> map toFloat
        |> or float
