module Lia.Sync.Update exposing
    ( Msg(..)
    , SyncMsg(..)
    , handle
    , isConnected
    , update
    )

import Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Section as Section exposing (Sections)
import Lia.Sync.Container.Global as Global
import Lia.Sync.Types exposing (Settings, State(..), id)
import Lia.Sync.Via as Via exposing (Backend)
import Port.Event as Event exposing (Event, message)
import Return exposing (Return)
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


handle :
    { model | sync : Settings, sections : Sections }
    -> Event
    -> Return { model | sync : Settings, sections : Sections } Msg sub
handle model =
    Handle >> update model


update :
    { model | sync : Settings, sections : Sections }
    -> Msg
    -> Return { model | sync : Settings, sections : Sections } Msg sub
update model msg =
    let
        sync =
            model.sync
    in
    case msg of
        Handle event ->
            case Event.destructure event |> Debug.log "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS" of
                Just ( "connect", _, message ) ->
                    { model
                        | sync =
                            case JD.decodeValue JD.string message of
                                Ok hashID ->
                                    { sync
                                        | state = Connected hashID
                                        , peers = Set.empty
                                    }

                                _ ->
                                    { sync
                                        | state = Disconnected
                                        , peers = Set.empty
                                    }
                    }
                        |> join

                Just ( "disconnect", _, _ ) ->
                    { model
                        | sync =
                            { sync
                                | state = Disconnected
                                , peers = Set.empty
                            }
                    }
                        |> Return.val

                --|> leave (id model.sync.state)
                Just ( "join", _, message ) ->
                    case
                        ( JD.decodeValue (JD.field "id" JD.string) message
                        , message
                            |> JD.decodeValue (JD.field "quiz" (Global.decoder Quiz.syncDecoder))
                            |> Result.map (Global.union (globalGet .quiz model.sections))
                        )
                    of
                        ( Ok peerID, Ok ( sendUpdate, state ) ) ->
                            { model
                                | sync = { sync | peers = Set.insert peerID sync.peers }
                                , sections = Section.sync state model.sections
                            }
                                |> (if sendUpdate then
                                        globalSync

                                    else
                                        Return.val
                                   )

                        _ ->
                            Return.val model

                Just ( "leave", _, message ) ->
                    { model
                        | sync =
                            { sync
                                | peers =
                                    case JD.decodeValue JD.string message of
                                        Ok peerID ->
                                            Set.remove peerID sync.peers

                                        _ ->
                                            sync.peers
                            }
                    }
                        |> Return.val

                _ ->
                    model
                        |> Return.val

        Password str ->
            { model | sync = { sync | password = str } }
                |> Return.val

        Username str ->
            { model | sync = { sync | username = str } }
                |> Return.val

        Room str ->
            { model | sync = { sync | room = str } }
                |> Return.val

        Backend sub ->
            { model | sync = { sync | sync = updateSync sub sync.sync } }
                |> Return.val

        Connect ->
            case ( sync.sync.select, sync.state ) of
                ( Just backend, Disconnected ) ->
                    { model | sync = { sync | state = Pending } }
                        |> Return.val
                        |> Return.sync
                            ([ ( "backend"
                               , backend
                                    |> Via.toString
                                    |> String.toLower
                                    |> JE.string
                               )
                             , ( "course", JE.string sync.course )
                             , ( "room", JE.string sync.room )
                             , ( "username", JE.string sync.username )
                             , ( "password"
                               , if String.isEmpty sync.password then
                                    JE.null

                                 else
                                    JE.string sync.password
                               )
                             ]
                                |> JE.object
                                |> Event.init "connect"
                            )

                _ ->
                    model |> Return.val

        Disconnect ->
            { model | sync = { sync | state = Pending } }
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


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected _ ->
            True

        _ ->
            False


join : { model | sync : Settings, sections : Sections } -> Return { model | sync : Settings, sections : Sections } msg sub
join model =
    case model.sync.state of
        Connected id ->
            { model | sections = Array.map (Section.synchronize id) model.sections }
                |> globalSync

        _ ->
            Return.val model


globalSync :
    { model | sync : Settings, sections : Sections }
    -> Return { model | sync : Settings, sections : Sections } msg sub
globalSync model =
    case model.sync.state of
        Connected id ->
            model
                |> Return.val
                |> Return.sync
                    ([ ( "id", JE.string id )
                     , ( "quiz"
                       , model.sections
                            |> globalGet .quiz
                            |> Global.encode Quiz.syncEncoder
                       )
                     ]
                        |> JE.object
                        |> Event.init "join"
                        |> Event.push "sync"
                    )

        _ ->
            Return.val model


globalGet fn =
    Array.map (.sync >> Maybe.andThen fn)
