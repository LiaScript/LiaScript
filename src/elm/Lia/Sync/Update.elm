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
import Lia.Markdown.Update exposing (synchronize)
import Lia.Section as Section exposing (Sections)
import Lia.Sync.Room as Room
import Lia.Sync.Types exposing (Settings, State(..), id)
import Lia.Sync.Via as Backend exposing (Backend)
import Random
import Return exposing (Return)
import Service.Event as Event exposing (Event)
import Service.Sync
import Session exposing (Session)
import Set


type Msg
    = Room String
    | Password String
    | Backend SyncMsg
    | Connect
    | Disconnect
    | Handle Event
    | Random_Generate
    | Random_Result String


type SyncMsg
    = Open Bool -- Backend selection
    | Select (Maybe ( Bool, Backend ))
    | Config Backend.Msg


handle :
    Session
    -> { model | sync : Settings, sections : Sections, readme : String }
    -> Event
    -> Return { model | sync : Settings, sections : Sections, readme : String } Msg sub
handle session model =
    Handle >> update session model


update :
    Session
    -> { model | sync : Settings, sections : Sections, readme : String }
    -> Msg
    -> Return { model | sync : Settings, sections : Sections, readme : String } Msg sub
update session model msg =
    let
        sync =
            model.sync
    in
    case msg of
        Handle event ->
            case Event.message event of
                ( "update", param ) ->
                    synchronize model param

                ( "error", param ) ->
                    case ( JD.decodeValue JD.string param, sync.sync.select ) of
                        ( Ok message, Just ( True, _ ) ) ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Set.empty
                                        , error = Just message
                                    }
                            }
                                |> Return.val

                        _ ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Set.empty
                                        , error = Just "unknown"
                                    }
                            }
                                |> Return.val

                ( "connect", param ) ->
                    case ( JD.decodeValue JD.string param, sync.sync.select ) of
                        ( Ok hashID, Just ( True, backend ) ) ->
                            { model
                                | sync =
                                    { sync
                                        | state = Connected hashID
                                        , peers = Set.empty
                                        , error = Nothing
                                    }
                            }
                                |> join
                                |> Return.cmd
                                    (session
                                        |> Session.setClass
                                            { backend = Backend.toString True backend
                                            , course = model.readme
                                            , room = sync.room
                                            }
                                        |> Session.update
                                    )

                        _ ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Set.empty
                                    }
                            }
                                |> Return.val
                                |> Return.cmd
                                    (session
                                        |> Session.setQuery model.readme
                                        |> Session.update
                                    )

                ( "disconnect", _ ) ->
                    { model
                        | sync =
                            { sync
                                | state = Disconnected
                                , peers = Set.empty
                                , error = Nothing
                            }
                    }
                        |> Return.val
                        |> Return.cmd
                            (session
                                |> Session.setQuery model.readme
                                |> Session.update
                            )

                _ ->
                    model
                        |> Return.val

        Password str ->
            { model | sync = { sync | password = str } }
                |> Return.val

        Room str ->
            { model | sync = { sync | room = str } }
                |> Return.val

        Random_Generate ->
            model
                |> Return.val
                |> Return.cmd (Random.generate Random_Result Room.generator)

        Random_Result roomName ->
            { model | sync = { sync | room = roomName } }
                |> Return.val

        Backend sub ->
            { model | sync = { sync | sync = updateSync sub sync.sync } }
                |> Return.val

        Connect ->
            case ( sync.sync.select, sync.state ) of
                ( Just ( True, backend ), Disconnected ) ->
                    { model | sync = { sync | state = Pending, sync = closeSelect sync.sync } }
                        |> Return.val
                        |> Return.batchEvent
                            (Service.Sync.connect
                                { backend = backend
                                , course = model.readme
                                , room = sync.room
                                , password = sync.password
                                }
                            )

                _ ->
                    model |> Return.val

        Disconnect ->
            --
            { model | sync = { sync | state = Pending } }
                |> Return.val
                |> Return.batchEvent
                    (model.sync.state
                        |> id
                        |> Maybe.map Service.Sync.disconnect
                        |> Maybe.withDefault Event.none
                    )


updateSync msg sync =
    case msg of
        Open open ->
            { sync | open = open }

        Select backend ->
            { sync
                | select = backend
                , open = False
            }

        Config childMsg ->
            case sync.select of
                Just ( True, select ) ->
                    { sync
                        | select =
                            Just
                                ( True
                                , Backend.update childMsg select
                                )
                    }

                _ ->
                    sync


closeSelect sync =
    { sync | open = False }


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected _ ->
            True

        _ ->
            False


join :
    { model | sync : Settings, sections : Sections }
    -> Return { model | sync : Settings, sections : Sections } msg sub
join model =
    case model.sync.state of
        Connected id ->
            model
                |> Return.val
                |> Return.batchEvent
                    (model.sections
                        |> JE.array (Section.sync id)
                        |> Service.Sync.join
                    )

        _ ->
            Return.val model


synchronize : { model | sync : Settings, sections : Sections } -> JD.Value -> Return { model | sync : Settings, sections : Sections } msg sub
synchronize model json =
    { model
        | sections =
            json
                |> JD.decodeValue
                    (JD.field "data" (JD.list Section.syncDecoder)
                        |> JD.andThen
                            (\list ->
                                if List.isEmpty list then
                                    JD.fail "empty lists cannot be state vectors"

                                else
                                    JD.succeed list
                            )
                    )
                |> Result.map (List.map2 Section.syncUpdate (Array.toList model.sections) >> Array.fromList)
                |> Result.withDefault model.sections
        , sync =
            json
                |> JD.decodeValue (JD.field "peers" (JD.list JD.string))
                |> Result.map (setPeers model.sync)
                |> Result.withDefault model.sync
    }
        |> Return.val


setPeers : Settings -> List String -> Settings
setPeers sync peers =
    { sync | peers = Set.fromList peers }
