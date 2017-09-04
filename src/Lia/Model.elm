module Lia.Model exposing (..)

import Lia.Code.Model
import Lia.Effect.Model
import Lia.Index.Model
import Lia.Quiz.Model
import Lia.Types exposing (Mode, Slide)


type alias Model =
    { script : String
    , error : String
    , mode : Mode
    , slides : List Slide
    , current_slide : Int
    , quiz_model : Lia.Quiz.Model.Model
    , code_model : Lia.Code.Model.Model
    , effect_model : Lia.Effect.Model.Model
    , index_model : Lia.Index.Model.Model
    , narator : String
    , contents : Bool
    }
