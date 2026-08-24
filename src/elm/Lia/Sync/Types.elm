module Lia.Sync.Types exposing
    ( ClassroomMode(..)
    , Cursor
    , Data
    , Settings
    , State(..)
    , Sync
    , decodeCursors
    , decodePeers
    , disconnected
    , fromClassroomMode
    , get
    , id
    , init
    , initRoom
    , isConnected
    , isRoot
    , isSupported
    , title
    , toClassroomMode
    )

import Array exposing (Array)
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as JD
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Sync as Code
import Lia.Markdown.Quiz.Sync as Quiz
import Lia.Markdown.Survey.Sync as Survey
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Container as Container exposing (Container)
import Lia.Sync.Via as Via exposing (Backend)
import Lia.Utils exposing (icon)


type State
    = Pending
    | Connected String
    | Disconnected


type alias Cursor =
    { id : String
    , color : String
    , section : Int
    , project : Int
    , file : Int
    , state : Editor.Cursor
    , name : String
    }


type ClassroomMode
    = Shared
    | Summary
    | Details


type alias Data =
    { cursor : List Cursor
    , survey : Dict Int (Container Survey.Sync)
    , quiz : Dict Int (Container Quiz.Sync)
    , code : Dict Int (Array Code.Sync)
    }


type alias Settings =
    { sync : Sync
    , state : State
    , room : String
    , password : String
    , name : String
    , peers : Dict String String
    , peersHistory : Dict String String
    , error : Maybe String
    , data : Data
    , scriptsEnabled : Bool
    , persistent : Bool
    , saved : List Classroom.Entry
    , deletePopup : Maybe ( String, String )
    , mode : ClassroomMode
    , owner : Bool
    , passwordVisible : Bool

    -- local-only labels for the saved classroom entry (not shared via URL,
    -- unlike room/password/mode) - help re-recognize a room in the "Your
    -- classrooms" grid independently of its actual (often generated) name
    , title : String
    , notes : String
    }


type alias Sync =
    { support : List ( Bool, Backend )
    , select : Maybe ( Bool, Backend )
    , open : Bool
    }


{-| A minimal, always-disconnected/no-data classroom context, for places
outside classroom scope (e.g. nested subsections) that still need to satisfy
the `{ state : State, data : Data }` shape.
-}
disconnected : { state : State, data : Data }
disconnected =
    { state = Disconnected
    , data =
        { cursor = []
        , survey = Dict.empty
        , quiz = Dict.empty
        , code = Dict.empty
        }
    }


isConnected : State -> Bool
isConnected state =
    case state of
        Connected _ ->
            True

        _ ->
            False


init : List String -> Settings
init supportedBackends =
    let
        supported =
            List.filterMap Via.fromString supportedBackends
    in
    { sync =
        { support =
            [ Via.GUN { urls = Const.gunDB_ServerURL, persistent = False }

            --, Via.Jitsi Const.jitsi_Domain
            --, Via.Matrix { baseURL = "", userId = "", accessToken = "" }
            , Via.IPFS { turnConfig = "" }
            , Via.MQTT { relayUrls = "", turnConfig = "" }
            , Via.NoStr { relayUrls = "", turnConfig = "" }

            --, Via.P2PT Const.webTorrent_TrackerURLs
            , Via.PubNub { pubKey = "", subKey = "" }
            , Via.Ably { apiKey = "", persistent = False }
            , Via.Torrent { relayUrls = "", turnConfig = "" }
            , Via.Edrys
            , Via.WebSocket { url = "" }
            , Via.PeerJS { host = "", port_ = "", path = "", iceServers = "" }
            , Via.SimplePeer { signaling = "", iceServers = "" }
            ]
                |> List.map (isMember supported)
                |> (::) ( True, Via.Local )
        , select = Nothing
        , open = False
        }
    , state = Disconnected
    , room = ""
    , password = ""
    , name = ""
    , peers = Dict.empty
    , peersHistory = Dict.empty
    , error = Nothing
    , data =
        { cursor = []
        , survey = Dict.empty
        , quiz = Dict.empty
        , code = Dict.empty
        }
    , scriptsEnabled = False
    , persistent = False
    , saved = []
    , deletePopup = Nothing
    , mode = Shared
    , owner = False
    , passwordVisible = False
    , title = ""
    , notes = ""
    }


isMember : List Via.Backend -> Via.Backend -> ( Bool, Via.Backend )
isMember list element =
    case ( list, element ) of
        ( [], _ ) ->
            ( False, element )

        ( (Via.GUN _) :: _, Via.GUN _ ) ->
            ( True, element )

        -- ( (Via.Matrix _) :: _, Via.Matrix _ ) ->
        --     ( True, element )
        ( (Via.PubNub _) :: _, Via.PubNub _ ) ->
            ( True, element )

        ( (Via.Ably _) :: _, Via.Ably _ ) ->
            ( True, element )

        -- ( (Via.Jitsi _) :: _, Via.Jitsi _ ) ->
        --     ( True, element )
        ( (Via.P2PT _) :: _, Via.P2PT _ ) ->
            ( True, element )

        ( e :: es, _ ) ->
            if e == element then
                ( True, element )

            else
                isMember es element


initRoom : { backend : String, course : String, room : String, mode : Int } -> Settings -> Settings
initRoom config settings =
    case Via.fromString config.backend of
        Just backend ->
            let
                sync =
                    settings.sync
            in
            { settings
                | sync =
                    { sync
                        | select = Just ( isSupportedBy settings.sync.support backend, backend )
                    }
                , room = config.room

                -- a room is only encoded into the URL after a successful
                -- connect, thus reconnecting to it should also continue to
                -- use (and update) its local cache
                , persistent = True
                , mode = toClassroomMode config.mode
            }

        Nothing ->
            { settings | error = Just ("Unknown Backend type: " ++ config.backend) }


{-| Check if a backend is generally usable. `Via.Local` is not part of the
`support` list, since it is not offered within the backend-selection, but it
never depends on any external library or configuration, thus it is always
supported.
-}
isSupportedBy : List ( Bool, Backend ) -> Backend -> Bool
isSupportedBy support backend =
    case backend of
        Via.Local ->
            True

        _ ->
            support
                |> List.filter (Tuple.second >> Via.eq backend)
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault False


filter : Bool -> Settings -> Dict String sync -> Maybe (Dict String sync)
filter shouldFilter settings container =
    case ( id settings.state, shouldFilter ) of
        ( Just main, True ) ->
            -- only show the result of a voting or quizzes if the user has also solved it ...
            if
                container
                    |> Dict.keys
                    |> List.member main
            then
                container
                    |> Dict.filter (filter_ (Dict.insert main settings.name settings.peers))
                    |> Just

            else
                Nothing

        ( Just _, False ) ->
            Just container

        _ ->
            Nothing


get : Maybe Settings -> (Data -> Dict Int (Container sync)) -> Int -> Int -> Maybe (Dict String sync)
get settings selector id1 id2 =
    case settings of
        Just s ->
            if s.mode == Shared then
                s.data
                    |> selector
                    |> Dict.get id1
                    |> Maybe.andThen (Container.get id2 >> Maybe.map2 (filter True) settings)
                    |> Maybe.withDefault Nothing

            else if s.owner then
                s.data
                    |> selector
                    |> Dict.get id1
                    |> Maybe.andThen (Container.get id2 >> Maybe.map2 (filter False) settings)
                    |> Maybe.withDefault Nothing

            else
                Nothing

        _ ->
            Nothing



-- case settings |> Maybe.map (.data >> selector ) of
--     ( Just s, Just local ) ->
--         local
--             |> Container.get id_
--             |> Maybe.andThen (filter s)
--     _ ->
--         Nothing


filter_ : Dict String String -> String -> sync -> Bool
filter_ ids key _ =
    Dict.member key ids


{-| Get the own unique user-id only if a connection was established.
-}
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
                , icon "icon-person icon-sm" [ Attr.style "padding-inline-end" "4px" ]
                , sync.peers
                    |> Dict.size
                    |> String.fromInt
                    |> Html.text
                , Html.text ")"
                , Html.text <|
                    if sync.owner && sync.mode /= Shared then
                        " ✨"

                    else
                        ""
                ]

        Pending ->
            Html.text "Classroom (pending)"


decodePeers : JD.Decoder (Dict String String)
decodePeers =
    JD.dict (JD.maybe JD.string |> JD.map (Maybe.withDefault ""))


decodeCursors : JD.Decoder (List Cursor)
decodeCursors =
    JD.list decodeCursor


decodeCursor : JD.Decoder Cursor
decodeCursor =
    JD.map7 Cursor
        (JD.field "id" JD.string)
        (JD.field "color" JD.string)
        (JD.field "section" JD.int)
        (JD.field "project" JD.int)
        (JD.field "file" JD.int)
        (JD.field "state" Editor.decodeCursor)
        (JD.field "name" JD.string)


fromClassroomMode : ClassroomMode -> Int
fromClassroomMode mode =
    case mode of
        Shared ->
            0

        Summary ->
            1

        Details ->
            2


toClassroomMode : Int -> ClassroomMode
toClassroomMode mode =
    case mode of
        1 ->
            Summary

        2 ->
            Details

        _ ->
            Shared


{-| Check if the user is the owner of Kremlin mode.
-}
isRoot : Settings -> Bool
isRoot settings =
    settings.owner && settings.mode == Details
