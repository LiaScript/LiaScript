module Lia.Effect.Model exposing (Model, init)

import Lia.Type exposing (Slide)


type alias Model =
    { visible : Int
    , effects : Int
    }


init : Maybe Slide -> Model
init maybe =
    case maybe of
        Just slide ->
            Model 0 slide.effects

        Nothing ->
            Model 0 0
