module Helper.Array exposing (..)

import Array exposing (Array)


update : Int -> (a -> a) -> Array a -> Array a
update i fn array =
    case Array.get i array of
        Just a ->
            Array.set i (fn a) array

        Nothing ->
            array
