module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Via
    , init
    , isConnected
    )


type State
    = Pending
    | Connected
    | Closed


type Via
    = Beaker


type alias Settings =
    { sync : Via
    , state : State
    , course : String
    , room : String
    , username : String
    , password : String
    }


init : Settings
init =
    { sync = Beaker
    , state = Closed
    , course = "www"
    , room = "test123"
    , username = "unknown"
    , password = ""
    }


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected ->
            True

        _ ->
            False
