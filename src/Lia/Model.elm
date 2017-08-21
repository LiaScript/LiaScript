module Lia.Model exposing (..)

import Lia.Quiz.Model
import Lia.Type exposing (Mode, Slide)


type alias Model =
    { script : String
    , error : String
    , slides : List Slide
    , quiz : Lia.Quiz.Model.Model
    , current_slide : Int
    , mode : Mode
    , visible : Int
    , effects : Int
    , contents : Bool
    , search : String
    , index : List String
    , search_results : Maybe (List Int)
    }
