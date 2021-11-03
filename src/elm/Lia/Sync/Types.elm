module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Via
    , init
    , isConnected
    , isSupported
    , title
    )

import Lia.Sync.Via as Via
import Return exposing (sync)
import Set exposing (Set)


type State
    = Pending
    | Connected
    | Closed


type alias Settings =
    { state : Sync
    , course : String
    , room : String
    , username : String
    , password : String
    , peers : Set String
    }


type alias Sync =
    { support : List Via.Backend
    , select : Maybe Via.Backend
    , open : Bool
    }


init : List String -> Settings
init supportedBackends =
    { sync =
        { support = List.filterMap Via.fromString supportedBackends
        , select = Nothing
        , open = False
        }
    , state = Disconnected
    , course = "www"
    , room = "test123"
    , username = "unknown"
    , password = ""
    , peers = Set.empty
    }


isSupported : Settings -> Bool
isSupported =
    .sync >> .support >> List.isEmpty >> not


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected ->
            True

        _ ->
            False


title : Settings -> String
title sync =
    case sync.state of
        Disconnected ->
            "Classroom"

        Connected ->
            "Classroom (" ++ String.fromInt (Set.size sync.peers) ++ ")"

        Pending ->
            "Classroom (pending)"
