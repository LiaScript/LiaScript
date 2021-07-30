module Lia.Sync.Types exposing (..)


type Status
    = Connecting
    | Connected
    | Closed


type Via
    = Beaker


type alias Sync =
    { sync : Via
    , room : String
    , course : String
    }
