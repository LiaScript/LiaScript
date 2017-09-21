module Lia.Chart.Parser exposing (parse)

import Combine exposing (..)
import Combine.Num exposing (float, int)
import Lia.Chart.Types exposing (Chart(..), Point)
import Lia.PState exposing (PState)


parse : Parser PState Chart
parse =
    chart


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


chart : Parser PState Chart
chart =
    let
        points y_max rows y_min ( x0, x_segment ) =
            let
                ( y0, y_segment ) =
                    segmentation (List.length rows) y_min y_max

                points =
                    rows
                        |> List.reverse
                        |> List.indexedMap (,)
                        |> List.map
                            (\( y, xs ) ->
                                xs
                                    |> List.map
                                        (\x ->
                                            Point
                                                (toFloat x * x_segment + x0)
                                                (toFloat y * y_segment + y0)
                                        )
                            )
                        |> List.concat
                        |> List.sortBy .x
            in
            if points |> List.map .x |> unique Nothing then
                Diagram points
            else
                Points points
    in
    points
        <$> optional 1.0 (regex "( )*" *> number)
        <*> many1 row
        <*> optional 0.0 (regex "( )*" *> number)
        <*> x_axis


row : Parser PState (List Int)
row =
    String.indexes "*" <$> (regex "( )*\\|" *> regex "(( )*\\*)*") <* regex "( )*\\n"


segmentation : Int -> Float -> Float -> ( Float, Float )
segmentation elements i0 i1 =
    ( i0, (i1 - i0) / toFloat elements )


x_axis : Parser PState ( Float, Float )
x_axis =
    (\e x0 x1 -> segmentation (String.length e) x0 x1)
        <$> (regex "( )*\\|" *> regex "_+" <* regex "( )*\\n( )*")
        <*> optional 0.0 number
        <*> optional 1.0 (regex "( )*" *> number <* regex "( )*\\n")


number : Parser PState Float
number =
    float <|> (toFloat <$> (int <* optional "." (string ".")))
