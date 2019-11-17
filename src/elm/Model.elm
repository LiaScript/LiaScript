module Model exposing (Model, State(..))

import Browser
import Browser.Navigation as Nav
import Index.Model as Index
import Lia.Script
import Url


type alias Model =
    { key : Nav.Key
    , size : Float
    , code : Maybe String
    , index : Index.Model
    , state : State
    , url : Url.Url
    , lia : Lia.Script.Model
    }


type State
    = Idle -- Wait for user Input
    | Loading -- Start to download the course if course url is defined
    | Parsing Bool Int -- Running the PreParser and loading the imports
    | Running -- Pass all action to Lia
    | Error String -- What has happend
