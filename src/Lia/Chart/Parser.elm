module Lia.Chart.Parser exposing (parse)

import Combine exposing (..)
import Combine.Num exposing (float, int)
import Dict exposing (Dict)
import Lia.Chart.Types exposing (..)
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
                |> List.indexedMap (,)
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
                |> Chart title
                    (y_label
                        |> List.map String.trim
                        |> List.map
                            (\w ->
                                if w == "" then
                                    " "
                                else
                                    w
                            )
                        |> String.concat
                        |> String.trim
                    )
                    x_label
    in
    chart
        <$> optional "" (regex "( )*[a-zA-Z0-9 .\\\\()\\-]+\\n")
        <*> optional 1.0 (regex "( )*" *> number)
        <*> many1 row
        <*> optional 0.0 (regex "( )*" *> number)
        <*> x_axis


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


label : Parser s String
label =
    optional "" (regex "( )*\\(" *> regex "[^\\n)]+" <* regex "\\)( )*")


row : Parser PState ( String, Dict Char (List Int) )
row =
    let
        indexes y_label str =
            ( y_label
            , str
                |> String.toList
                |> Set.fromList
                |> Set.remove ' '
                |> Set.toList
                |> List.map (\c -> ( c, String.indexes (String.fromChar c) str ))
                |> Dict.fromList
            )
    in
    indexes <$> (regex "[^\\n|]*" <* string "|") <*> (regex "[ \\*a-zA-Z\\+#]*" <* regex "( )*\\n")


segmentation : Int -> Float -> Float -> ( Float, Float )
segmentation elements i0 i1 =
    ( i0, (i1 - i0) / toFloat elements )


x_axis : Parser PState ( String, ( Float, Float ) )
x_axis =
    (\e x0 x_label x1 -> ( x_label, segmentation (String.length e) x0 x1 ))
        <$> (regex "( )*\\+" *> regex "\\-+" <* regex "( )*\\n( )*")
        <*> optional 0.0 number
        <*> label
        <*> optional 1.0 (regex "( )*" *> number <* regex "( )*\\n")


number : Parser PState Float
number =
    float <|> (toFloat <$> (int <* optional "." (string ".")))
