module Lia.Model exposing (..)

import Lia.Type exposing (Mode, QuizMatrix, Slide)


type alias Model =
    { script : String
    , error : String
    , lia : List Slide
    , quiz : QuizMatrix
    , slide : Int
    , mode : Mode
    , visible : Int
    , effects : Int
    }
