module Lia.Code.Model exposing (Model, get_result, init)

import Array exposing (Array)


type alias Model =
    Array (Maybe (Result String String))


init : Int -> Model
init i =
    Array.repeat i Nothing


get_result : Int -> Model -> Maybe (Result String String)
get_result idx model =
    Array.get idx model |> Maybe.andThen (\a -> a)
