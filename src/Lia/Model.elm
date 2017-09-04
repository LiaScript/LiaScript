module Lia.Model exposing (..)

import Lia.Code.Model
import Lia.Effect.Model
import Lia.Index.Model
import Lia.Quiz.Model
import Lia.Types exposing (Mode, Slide)


type alias Model =
    { script : String
    , error : String
    , slides : List Slide
    , quiz_model : Lia.Quiz.Model.Model
    , code_model : Lia.Code.Model.Model
    , current_slide : Int
    , mode : Mode
    , effect_model : Lia.Effect.Model.Model
    , narator : String
    , contents : Bool
    , index : Lia.Index.Model.Model
    }
