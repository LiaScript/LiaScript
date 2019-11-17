module Model exposing (Model, State(..))

import Browser
import Browser.Navigation as Nav
import Index.Model as Index
import Lia.Script
import Session exposing (Session)
import Url


type alias Model =
    { size : Float
    , code : Maybe String
    , index : Index.Model
    , session : Session
    , state : State
    , lia : Lia.Script.Model
    }


type State
    = Idle -- Wait for user Input
    | Loading -- Start to download the course if course url is defined
    | Parsing Bool Int -- Running the PreParser and loading the imports
    | Running -- Pass all action to Lia
    | Error String -- What has happend
