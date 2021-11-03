module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Sync
    , init
    , isConnected
    , isSupported
    , title
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Sync.Via as Via exposing (Backend)
import Lia.Utils exposing (icon)
import Return exposing (sync)
import Set exposing (Set)
import Translations exposing (Lang(..))


type State
    = Pending
    | Connected
    | Disconnected


type alias Settings =
    { sync : Sync
    , state : State
    , course : String
    , room : String
    , username : String
    , password : String
    , peers : Set String
    }


type alias Sync =
    { support : List Backend
    , select : Maybe Backend
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
    , room = "test"
    , username = "anonymous"
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


title : Settings -> Html msg
title sync =
    case sync.state of
        Disconnected ->
            Html.text "Classrooms"

        Connected ->
            Html.span []
                [ Html.text "Classroom ("
                , icon "icon-person"
                    [ Attr.style "font-size" "smaller"
                    , Attr.style "padding-right" "4px"
                    ]
                , Html.text <| String.fromInt (Set.size sync.peers)
                , Html.text ")"
                ]

        Pending ->
            Html.text "Classroom (pending)"
