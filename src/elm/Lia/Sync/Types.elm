module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Via
    , init
    , isConnected
    )

import Lia.Sync.Chat as Chat exposing (Chat)


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
    , chat : Chat
    }


init : Settings
init =
    { sync = Beaker
    , state = Disconnected
    , course = "www"
    , room = "test123"
    , username = "unknown"
    , password = ""
    , chat = Chat.init
    }


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected ->
            True

        _ ->
            False
