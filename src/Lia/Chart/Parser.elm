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
        points rows ( x0, steps ) =
            let
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
                                                (toFloat x * steps + x0)
                                                (toFloat y)
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
    points <$> many1 row <*> x_axis


row : Parser PState (List Int)
row =
    String.indexes "*" <$> (regex "( )*\\|" *> regex "(( )*\\*)*") <* regex "( )*\\n"


x_axis : Parser PState ( Float, Float )
x_axis =
    let
        segmentation elments x0 x1 =
            ( x0, (x1 - x0) / (toFloat <| String.length elments) )
    in
    segmentation <$> (regex "( )*\\|" *> regex "_+" <* regex "( )*\\n( )*") <*> number <*> (regex "( )*" *> number <* regex "( )*\\n")


number : Parser PState Float
number =
    float <|> (toFloat <$> (int <* optional "." (string ".")))
