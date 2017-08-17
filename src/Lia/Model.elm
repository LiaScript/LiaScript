module Lia.Model exposing (..)

import Lia.Type exposing (Mode, QuizVector, Slide)


type alias Model =
    { script : String
    , error : String
    , slides : List Slide
    , quiz : QuizVector
    , current_slide : Int
    , mode : Mode
    , visible : Int
    , effects : Int
    , contents : Bool
    , search : Maybe String
    }
