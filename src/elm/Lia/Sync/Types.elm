module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Via
    , init
    , isConnected
    , title
    )

import Return exposing (sync)
import Set exposing (Set)


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
    , peers : Set String
    }


init : Settings
init =
    { sync = Beaker
    , state = Disconnected
    , course = "www"
    , room = "test"
    , username = "anonymous"
    , password = ""
    , peers = Set.empty
    }


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
