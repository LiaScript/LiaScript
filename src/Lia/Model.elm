module Lia.Model exposing (..)

import Lia.Effect.Model
import Lia.Quiz.Model
import Lia.Type exposing (Mode, Slide)


type alias Model =
    { script : String
    , error : String
    , slides : List Slide
    , quiz : Lia.Quiz.Model.Model
    , current_slide : Int
    , mode : Mode
    , effects : Lia.Effect.Model.Model
    , contents : Bool
    , search : String
    , index : List String
    , search_results : Maybe (List Int)
    }
