module Lia.Sync.Update exposing
    ( Msg(..)
    , SyncMsg(..)
    , handle
    , isConnected
    , update
    )

import Array
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Chat.Model as Chat
import Lia.Chat.Sync as Chat
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Sync as Code
import Lia.Markdown.Quiz.Sync as Quiz
import Lia.Markdown.Survey.Sync as Survey
import Lia.Section as Section exposing (Sections)
import Lia.Sync.Container as Container
import Lia.Sync.Room as Room
import Lia.Sync.Types
    exposing
        ( Settings
        , State(..)
        , decodeCursors
        , decodePeers
        , id
        )
import Lia.Sync.Via as Backend exposing (Backend)
import Random
import Return exposing (Return)
import Service.Console as Console
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
    ->
        { model
            | sync : Settings
            , sections : Sections
            , readme : String
            , chat : Chat.Model
            , search_index : String -> String
            , definition : Definition
        }
    -> Event
    ->
        Return
            { model
                | sync : Settings
                , sections : Sections
                , readme : String
                , chat : Chat.Model
                , search_index : String -> String
                , definition : Definition
            }
            Msg
            sub
handle session model =
    Handle >> update session model


update :
    Session
    ->
        { model
            | sync : Settings
            , sections : Sections
            , readme : String
            , chat : Chat.Model
            , search_index : String -> String
            , definition : Definition
        }
    -> Msg
    ->
        Return
            { model
                | sync : Settings
                , sections : Sections
                , readme : String
                , chat : Chat.Model
                , search_index : String -> String
                , definition : Definition
            }
            Msg
            sub
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
                                , data =
                                    { cursor = []
                                    , survey = Dict.empty
                                    , quiz = Dict.empty
                                    , code = Dict.empty
                                    }
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
    { model
        | sync : Settings
        , sections : Sections
    }
    ->
        Return
            { model
                | sync : Settings
                , sections : Sections
            }
            msg
            sub
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


synchronize :
    { model
        | sync : Settings
        , sections : Sections
        , chat : Chat.Model
        , search_index : String -> String
        , definition : Definition
    }
    -> JD.Value
    ->
        Return
            { model
                | sync : Settings
                , sections : Sections
                , chat : Chat.Model
                , search_index : String -> String
                , definition : Definition
            }
            msg
            sub
synchronize model json =
    case
        JD.decodeValue
            (JD.map2 Tuple.pair
                (JD.field "cmd" JD.string)
                (JD.field "param" JD.value)
            )
            json
    of
        Ok ( "cursor", param ) ->
            let
                sync =
                    model.sync

                data =
                    sync.data
            in
            { model
                | sync =
                    { sync
                        | data =
                            { data
                                | cursor =
                                    param
                                        |> JD.decodeValue decodeCursors
                                        |> Result.withDefault data.cursor
                            }
                    }
            }
                |> Return.val

        Ok ( "chat", param ) ->
            { model
                | chat =
                    param
                        |> JD.decodeValue Chat.decoder
                        |> Result.map (Chat.insert model.search_index model.definition model.chat)
                        |> Result.withDefault model.chat
            }
                |> Return.val

        Ok ( "peer", param ) ->
            let
                sync =
                    model.sync
            in
            { model
                | sync =
                    { sync
                        | peers =
                            param
                                |> JD.decodeValue decodePeers
                                |> Result.map Set.fromList
                                |> Result.withDefault sync.peers
                    }
            }
                |> Return.val

        Ok ( "code", param ) ->
            case
                param
                    |> dataDecoder (JD.array Code.decoder)
                    |> Result.map (dataMerge model.sync.data.code)
            of
                Ok dataUpdate ->
                    let
                        sync =
                            model.sync

                        data =
                            sync.data
                    in
                    { model
                        | sync =
                            { sync
                                | data =
                                    { data
                                        | code = dataUpdate
                                    }
                            }
                    }
                        |> Return.val

                Err info ->
                    model
                        |> Return.val
                        |> warn "decoding code" (JD.errorToString info)

        Ok ( "quiz", param ) ->
            case
                param
                    |> dataDecoder (Container.decoder Quiz.decoder)
                    |> Result.map (dataMerge model.sync.data.quiz)
            of
                Ok dataUpdate ->
                    let
                        sync =
                            model.sync

                        data =
                            sync.data
                    in
                    { model
                        | sync =
                            { sync
                                | data =
                                    { data
                                        | quiz = dataUpdate
                                    }
                            }
                    }
                        |> Return.val

                Err info ->
                    model
                        |> Return.val
                        |> warn "decoding quiz" (JD.errorToString info)

        Ok ( "survey", param ) ->
            case
                param
                    |> dataDecoder (Container.decoder Survey.decoder)
                    |> Result.map (dataMerge model.sync.data.survey)
            of
                Ok dataUpdate ->
                    let
                        sync =
                            model.sync

                        data =
                            sync.data
                    in
                    { model
                        | sync =
                            { sync
                                | data =
                                    { data
                                        | survey = dataUpdate
                                    }
                            }
                    }
                        |> Return.val

                Err info ->
                    model
                        |> Return.val
                        |> warn "decoding survey" (JD.errorToString info)

        Ok ( cmd, _ ) ->
            model
                |> Return.val
                |> warn "unknown command" cmd

        Err info ->
            model
                |> Return.val
                |> warn "decoding error" (JD.errorToString info)


warn : String -> String -> Return model msg sub -> Return model msg sub
warn what info =
    Return.batchEvent (Console.warn ("Sync: " ++ what ++ " -> " ++ info))


dataDecoder : JD.Decoder data -> JD.Value -> Result JD.Error (List ( Int, data ))
dataDecoder data =
    JD.decodeValue
        (JD.list
            (JD.map2 Tuple.pair
                (JD.field "id" JD.int)
                (JD.field "data" data)
            )
        )


dataMerge : Dict Int data -> List ( Int, data ) -> Dict Int data
dataMerge data new =
    List.foldl (\( key, value ) store -> Dict.insert key value store) data new
