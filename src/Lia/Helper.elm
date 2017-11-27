module Lia.Helper exposing (..)

import Array exposing (Array)


type alias ID =
    Int


type alias ID2 =
    ( ID, ID )


type alias Array2D a =
    Array (Array a)


get : Array2D a -> ID2 -> Maybe a
get array ( id1, id2 ) =
    array
        |> Array.get id1
        |> Maybe.withDefault Array.empty
        |> Array.get id2


set : ID2 -> a -> Array2D a -> Array2D a
set ( id1, id2 ) a array =
    case Array.get id1 array of
        Just array_ ->
            Array.set id1 (Array.set id2 a array_) array

        Nothing ->
            array
