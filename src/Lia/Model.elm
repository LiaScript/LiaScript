module Lia.Model exposing (..)

import Lia.Type exposing (Mode, QuizVector, Slide)


type alias Model =
    { script : String
    , error : String
    , lia : List Slide
    , quiz : QuizVector
    , slide : Int
    , mode : Mode
    , visible : Int
    , effects : Int
    , contents : Bool
    , search : Maybe String
    }
