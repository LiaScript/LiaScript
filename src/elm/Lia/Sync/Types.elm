module Lia.Sync.Types exposing
    ( Cursor
    , Data
    , Settings
    , State(..)
    , Sync
    , decodeCursors
    , decodePeers
    , get
    , id
    , init
    , initRoom
    , isConnected
    , isSupported
    , title
    )

import Array exposing (Array)
import Browser exposing (element)
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Json.Decode as JD
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Sync as Code
import Lia.Markdown.Quiz.Sync as Quiz
import Lia.Markdown.Survey.Sync as Survey
import Lia.Sync.Container as Container exposing (Container)
import Lia.Sync.Via as Via exposing (Backend)
import Lia.Utils exposing (icon)
import Set exposing (Set)


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
    }


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
    , peers : Set String
    , error : Maybe String
    , data : Data
    }


type alias Sync =
    { support : List ( Bool, Backend )
    , select : Maybe ( Bool, Backend )
    , open : Bool
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
            , Via.MQTT
            , Via.NoStr
            , Via.P2PT Const.webTorrent_TrackerURLs
            , Via.PubNub { pubKey = "", subKey = "" }
            , Via.Torrent
            , Via.Edrys
            ]
                |> List.map (isMember supported)
        , select = Nothing
        , open = False
        }
    , state = Disconnected
    , room = ""
    , password = ""
    , peers = Set.empty
    , error = Nothing
    , data =
        { cursor = []
        , survey = Dict.empty
        , quiz = Dict.empty
        , code = Dict.empty
        }
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

        -- ( (Via.Jitsi _) :: _, Via.Jitsi _ ) ->
        --     ( True, element )
        ( (Via.P2PT _) :: _, Via.P2PT _ ) ->
            ( True, element )

        ( e :: es, _ ) ->
            if e == element then
                ( True, element )

            else
                isMember es element


initRoom : { backend : String, course : String, room : String } -> Settings -> Settings
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
                        | select =
                            Just
                                ( settings.sync.support
                                    |> List.filter
                                        (\( support, for ) ->
                                            if Via.eq for backend then
                                                support

                                            else
                                                False
                                        )
                                    |> List.head
                                    |> Maybe.map Tuple.first
                                    |> Maybe.withDefault False
                                , backend
                                )
                    }
                , room = config.room
            }

        Nothing ->
            { settings | error = Just ("Unknown Backend type: " ++ config.backend) }


filter : Settings -> Dict String sync -> Maybe (List sync)
filter settings container =
    case id settings.state of
        Just main ->
            -- only show the result of a voting or quizzes if the user has also solved it ...
            if
                container
                    |> Dict.keys
                    |> List.member main
            then
                container
                    |> Dict.filter (filter_ (Set.insert main settings.peers))
                    |> Dict.values
                    |> Just

            else
                Nothing

        _ ->
            Nothing


get : Maybe Settings -> (Data -> Dict Int (Container sync)) -> Int -> Int -> Maybe (List sync)
get settings selector id1 id2 =
    settings
        |> Maybe.andThen (.data >> selector >> Dict.get id1)
        |> Maybe.andThen (Container.get id2 >> Maybe.map2 filter settings)
        |> Maybe.withDefault Nothing



-- case settings |> Maybe.map (.data >> selector ) of
--     ( Just s, Just local ) ->
--         local
--             |> Container.get id_
--             |> Maybe.andThen (filter s)
--     _ ->
--         Nothing


filter_ : Set String -> String -> sync -> Bool
filter_ ids key _ =
    Set.member key ids


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
                , icon "icon-person icon-sm" [ Attr.style "padding-right" "4px" ]
                , sync.peers
                    |> Set.size
                    |> String.fromInt
                    |> Html.text
                , Html.text ")"
                ]

        Pending ->
            Html.text "Classroom (pending)"


decodePeers : JD.Decoder (List String)
decodePeers =
    JD.list JD.string


decodeCursors : JD.Decoder (List Cursor)
decodeCursors =
    JD.list decodeCursor


decodeCursor : JD.Decoder Cursor
decodeCursor =
    JD.map6 Cursor
        (JD.field "id" JD.string)
        (JD.field "color" JD.string)
        (JD.field "section" JD.int)
        (JD.field "project" JD.int)
        (JD.field "file" JD.int)
        (JD.field "state" Editor.decodeCursor)
