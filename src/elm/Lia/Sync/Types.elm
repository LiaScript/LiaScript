module Lia.Sync.Types exposing (..)


type Status
    = Connecting
    | Connected
    | Disconnected


type Via
    = Beaker


type alias Sync =
    { sync : Via
    , status : Status
    , room : String
    , course : String
    , username : String
    , password : String
    }
