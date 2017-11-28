module Lia.Helper exposing (..)

import Array exposing (Array)


type alias ID =
    Int


type alias ID2 =
    ( ID, ID )


type alias Array2D a =
    Array (Array a)


get : ID2 -> Array2D a -> Maybe a
get ( id1, id2 ) array =
    case Array.get id1 array of
        Just array_ ->
            Array.get id2 array_

        Nothing ->
            Nothing


set : ID2 -> a -> Array2D a -> Array2D a
set ( id1, id2 ) a array =
    case Array.get id1 array of
        Just array_ ->
            Array.set id1 (Array.set id2 a array_) array

        Nothing ->
            array
