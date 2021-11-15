module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Sync
    , filter
    , id
    , init
    , isSupported
    , title
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Sync.Via as Via exposing (Backend)
import Lia.Utils exposing (icon)
import Return exposing (sync)
import Set exposing (Set)
import Translations exposing (Lang(..))


type State
    = Pending
    | Connected String
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


title : Settings -> Html msg
title sync =
    case sync.state of
        Disconnected ->
            Html.text "Classroom"

        Connected _ ->
            Html.span []
                [ Html.text "Classroom ("
                , icon "icon-person icon-sm" [ Attr.style "padding-right" "4px" ]
                , sync.peers
                    |> Set.size
                    |> String.fromInt
                    |> Html.text
                , Html.text ")"
                ]

        Pending ->
            Html.text "Classroom (pending)"