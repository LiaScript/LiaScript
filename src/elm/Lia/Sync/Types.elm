module Lia.Sync.Types exposing
    ( Settings
    , State(..)
    , Sync
    , get
    , id
    , init
    , initRoom
    , isSupported
    , title
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Sync.Container.Local as Local
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
    , room : String
    , username : String
    , password : String
    , peers : Set String
    , error : Maybe String
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
    , room = ""
    , username = ""
    , password = ""
    , peers = Set.empty
    , error = Nothing
    }


initRoom : { backend : String, course : String, room : String } -> Settings -> Settings
initRoom config settings =
    case Via.fromString config.backend of
        Just backend ->
            if List.member backend settings.sync.support then
                let
                    sync =
                        settings.sync
                in
                { settings
                    | sync = { sync | select = Just backend }
                    , room = config.room
                }

            else
                { settings | error = Just ("Unsupported Backend type: " ++ config.backend) }

        Nothing ->
            { settings | error = Just ("Unknown Backend type: " ++ config.backend) }


filter : Settings -> Dict String sync -> Maybe (List sync)
filter settings container =
    case id settings.state of
        Just main ->
            container
                |> Dict.filter (filter_ (Set.insert main settings.peers))
                |> Dict.values
                |> Just

        _ ->
            Nothing


get : Maybe Settings -> Int -> Maybe (Local.Container sync) -> Maybe (List sync)
get settings id_ container =
    case ( settings, container ) of
        ( Just s, Just local ) ->
            local
                |> Local.get id_
                |> Maybe.andThen (filter s)

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
