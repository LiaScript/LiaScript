module Lia.Quiz.Model exposing (get_state)

import Array exposing (Array)
import Lia.Quiz.Types exposing (..)


get_state : Vector -> Int -> Maybe Element
get_state vector idx =
    vector
        |> Array.get idx
