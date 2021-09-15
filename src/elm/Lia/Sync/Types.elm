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
    | Disconnected


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
    , state = Disconnected
    , course = "www"
    , room = "test"
    , username = "anonymous"
    , password = ""
    }


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected ->
            True

        _ ->
            False
