module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Sync
    , filter
    , id
    , init
    , isConnected
    , isSupported
    , title
    )

--import Lia.Sync.Update exposing (Msg(..))

import Dict exposing (Dict)
import Lia.Sync.Via as Via
import Return exposing (sync)
import Set exposing (Set)


type State
    = Pending
    | Connected String
    | Disconnected


type alias Settings =
    { state : State
    , sync : Sync
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


filter : Maybe Settings -> Dict String sync -> Maybe (List sync)
filter settings container =
    case ( Maybe.andThen (.state >> id) settings, settings ) of
        ( Just main, Just s ) ->
            container
                |> Dict.filter (filter_ (Set.insert main s.peers))
                |> Dict.values
                |> Just

        _ ->
            Nothing


filter_ : Set String -> String -> sync -> Bool
filter_ ids key _ =
    Set.member key ids


id : State -> Maybe String
id state =
    case state of
        Connected hash ->
            Just hash

        _ ->
            Nothing


isSupported : Settings -> Bool
isSupported =
    .sync >> .support >> List.isEmpty >> not


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected _ ->
            True

        _ ->
            False


title : Settings -> String
title sync =
    case sync.state of
        Disconnected ->
            "Classroom"

        Connected _ ->
            "Classroom (" ++ String.fromInt (Set.size sync.peers) ++ ")"

        Pending ->
            "Classroom (pending)"
