module Lia.Sync.Update exposing
    ( Msg(..)
    , SyncMsg(..)
    , handle
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Types exposing (Settings, State(..))
import Lia.Sync.Via exposing (Backend)
import Port.Event as Event exposing (Event)
import Return exposing (Return)
import Session exposing (Session)
import Set


type Msg
    = Room String
    | Username String
    | Password String
    | Backend SyncMsg
    | Connect
    | Disconnect
    | Handle Event


type SyncMsg
    = Open Bool -- Backend selection
    | Select (Maybe Backend)


handle : Session -> Event -> Settings -> Return Settings Msg sub
handle session event =
    update session (Handle event)


update : Session -> Msg -> Settings -> Return Settings Msg sub
update session msg model =
    case msg of
        Handle event ->
            Return.val <|
                case Event.destructure event of
                    Just ( "connect", _, message ) ->
                        if bool message then
                            { model
                                | state = Connected
                                , peers = Set.empty
                            }

                        else
                            { model
                                | state = Disconnected
                                , peers = Set.empty
                            }

                    Just ( "disconnect", _, _ ) ->
                        { model
                            | state = Disconnected
                            , peers = Set.empty
                        }

                    Just ( "join", _, message ) ->
                        { model
                            | peers =
                                case JD.decodeValue JD.string message of
                                    Ok peerID ->
                                        Set.insert peerID model.peers

                                    _ ->
                                        model.peers
                        }

                    Just ( "leave", _, message ) ->
                        { model
                            | peers =
                                case JD.decodeValue JD.string message of
                                    Ok peerID ->
                                        Set.remove peerID model.peers

                                    _ ->
                                        model.peers
                        }

                    _ ->
                        model

        Password str ->
            { model | password = str }
                |> Return.val

        Username str ->
            { model | username = str }
                |> Return.val

        Room str ->
            { model | room = str }
                |> Return.val

        Backend sub ->
            { model | sync = updateSync sub model.sync }
                |> Return.val

        Connect ->
            { model | state = Pending }
                |> Return.val
                |> Return.sync
                    ([ ( "course", JE.string model.course )
                     , ( "room", JE.string model.room )
                     , ( "username", JE.string model.username )
                     , ( "password"
                       , if String.isEmpty model.password then
                            JE.null

                         else
                            JE.string model.password
                       )
                     ]
                        |> JE.object
                        |> Event.init "connect"
                    )

        Disconnect ->
            { model | state = Pending }
                |> Return.val
                |> Return.sync (Event.empty "disconnect")


updateSync msg sync =
    case msg of
        Open open ->
            { sync | open = open }

        Select backend ->
            { sync
                | select = backend
                , open = False
            }


bool : JE.Value -> Bool
bool =
    JD.decodeValue JD.bool
        >> Result.toMaybe
        >> Maybe.withDefault False
