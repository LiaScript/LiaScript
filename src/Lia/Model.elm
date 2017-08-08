module Lia.Model exposing (..)

import Lia.Type exposing (Mode, Slide)


type alias Model =
    { script : String
    , error : String
    , lia : List Slide
    , slide : Int
    , mode : Mode
    }
