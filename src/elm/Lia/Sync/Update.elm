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
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Lia.Chat.Model as Chat
import Lia.Chat.Sync as Chat
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Sync as Code
import Lia.Markdown.Quiz.Sync as Quiz
import Lia.Markdown.Survey.Sync as Survey
import Lia.Section as Section exposing (Sections)
import Lia.Settings.Types as Lia
import Lia.Settings.Update exposing (updatedChatMessages)
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Container as Container
import Lia.Sync.Room as Room
import Lia.Sync.Types
    exposing
        ( ClassroomMode(..)
        , Settings
        , State(..)
        , decodeCursors
        , decodePeers
        , fromClassroomMode
        , id
        , toClassroomMode
        )
import Lia.Sync.Via as Backend exposing (Backend)
import Random
import Return exposing (Return)
import Service.Console as Console
import Service.Event as Event exposing (Event)
import Service.Database
import Service.Share
import Service.Slide
import Service.Sync
import Session exposing (Session)


type Msg
    = Room String
    | Password String
    | Name String
    | LocalName String
    | LocalNote String
    | Backend SyncMsg
    | Connect
    | Disconnect
    | Handle Event
    | Random_Generate
    | Random_Result String
    | EnabledScript Bool
    | TogglePersistent
    | LoadClassroom Classroom.Entry
    | AskDeleteClassroom String String
    | CancelDeleteClassroom
    | ConfirmDeleteClassroom String String
    | OpenNotes
    | ClassroomMode String
    | EditMeta Classroom.Entry { title : String, notes : String, name : String }
    | SaveMeta Classroom.Entry
    | TogglePasswordVisibility
    | CopyOwnerLink
    | GenerateOwnerToken


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
            , settings : Lia.Settings
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
                , settings : Lia.Settings
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
            , settings : Lia.Settings
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
                , settings : Lia.Settings
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
                                        , peers = Dict.empty
                                        , peersHistory = Dict.empty
                                        , error = Just message
                                    }
                            }
                                |> Return.val

                        _ ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Dict.empty
                                        , peersHistory = Dict.empty
                                        , error = Just "unknown"
                                    }
                            }
                                |> Return.val

                ( "warning", param ) ->
                    -- Advisory only (e.g. the password-mismatch heuristic) -
                    -- unlike "error", the connection is not actually down,
                    -- so state/peers must stay untouched.
                    case JD.decodeValue JD.string param of
                        Ok message ->
                            { model | sync = { sync | error = Just message } }
                                |> Return.val

                        Err _ ->
                            model |> Return.val

                ( "owner_token", param ) ->
                    case JD.decodeValue ownerTokenGenerated param of
                        Ok info ->
                            { model
                                | sync =
                                    { sync
                                        | ownerToken = Just info.token
                                        , ownerTokenHash = info.hash
                                    }
                            }
                                |> Return.val

                        Err _ ->
                            model |> Return.val

                ( "connect", param ) ->
                    case ( JD.decodeValue connectAck param, sync.sync.select ) of
                        ( Ok info, Just ( True, backend ) ) ->
                            { model
                                | sync =
                                    { sync
                                        | state = Connected info.id
                                        , peers = Dict.singleton info.id sync.name
                                        , peersHistory = Dict.singleton info.id sync.name
                                        , error = Nothing
                                        , ownerTokenHash = info.ownerTokenHash
                                        , pwSalt = info.pwSalt
                                        , pwCheck = info.pwCheck
                                        , ownerToken = info.ownerToken
                                    }
                            }
                                |> join
                                |> Return.cmd
                                    (session
                                        |> Session.setClass
                                            { backend = Backend.toString True backend
                                            , course = model.readme
                                            , room = sync.room
                                            , mode = fromClassroomMode sync.mode
                                            , ownerTokenHash = info.ownerTokenHash
                                            , pwSalt = info.pwSalt
                                            , pwCheck = info.pwCheck

                                            -- never re-materialize the raw
                                            -- secret into the address bar,
                                            -- even though `encodeRoom`
                                            -- itself would already drop it
                                            , ownerToken = Nothing
                                            }
                                        |> Session.update
                                    )

                        _ ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Dict.empty
                                        , peersHistory = Dict.empty
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
                                , peers = Dict.empty
                                , peersHistory = Dict.empty
                                , error = Nothing
                                , data =
                                    { cursor = []
                                    , survey = Dict.empty
                                    , quiz = Dict.empty
                                    , code = Dict.empty
                                    }
                            }
                        , chat = Chat.init
                    }
                        |> Return.val
                        |> Return.cmd
                            (session
                                |> Session.setQuery model.readme
                                |> Session.update
                            )

                ( "classrooms", param ) ->
                    let
                        saved =
                            param
                                |> JD.decodeValue Classroom.decoder
                                |> Result.withDefault sync.saved

                        -- prefill "Your name" from the most recently used
                        -- classroom, so returning users don't have to
                        -- retype it every time they open the dialog
                        name =
                            if String.isEmpty sync.name then
                                saved
                                    |> List.head
                                    |> Maybe.andThen .name
                                    |> Maybe.withDefault sync.name

                            else
                                sync.name
                    in
                    { model | sync = { sync | saved = saved, name = name } }
                        |> Return.val

                _ ->
                    model
                        |> Return.val

        Password str ->
            { model | sync = { sync | password = str } }
                |> Return.val

        Room str ->
            { model | sync = { sync | room = str } }
                |> Return.val

        Name str ->
            { model | sync = { sync | name = str } }
                |> Return.val

        LocalName str ->
            { model | sync = { sync | title = str } }
                |> Return.val

        LocalNote str ->
            { model | sync = { sync | notes = str } }
                |> Return.val

        ClassroomMode mode ->
            { model
                | sync =
                    { sync
                        | mode =
                            mode
                                |> String.toInt
                                |> Maybe.map toClassroomMode
                                |> Maybe.withDefault sync.mode
                    }
            }
                |> Return.val

        Random_Generate ->
            model
                |> Return.val
                |> Return.cmd (Random.generate Random_Result Room.generator)

        Random_Result roomName ->
            { model | sync = { sync | room = roomName } }
                |> Return.val

        Backend (Select Nothing) ->
            { model
                | sync =
                    { sync
                        | sync = updateSync (Select Nothing) sync.sync
                        , room = ""
                        , password = ""
                        , title = ""
                        , notes = ""
                        , mode = Shared
                        , persistent = False
                        , locked = False
                        , passwordLocked = False
                        , ownerTokenHash = ""
                        , pwSalt = ""
                        , pwCheck = ""
                        , ownerToken = Nothing
                    }
            }
                |> Return.val
                |> Return.cmd
                    (session
                        |> Session.setQuery model.readme
                        |> Session.update
                    )

        Backend sub ->
            { model | sync = { sync | sync = updateSync sub sync.sync } }
                |> Return.val

        EnabledScript enabled ->
            { model | sync = { sync | scriptsEnabled = not enabled } }
                |> Return.val

        TogglePersistent ->
            { model | sync = { sync | persistent = not sync.persistent } }
                |> Return.val

        TogglePasswordVisibility ->
            { model | sync = { sync | passwordVisible = not sync.passwordVisible } }
                |> Return.val

        GenerateOwnerToken ->
            model
                |> Return.val
                |> Return.batchEvent Service.Sync.generateOwnerToken

        CopyOwnerLink ->
            -- Available as soon as a token exists - either freshly minted
            -- here before ever connecting, or confirmed as owner after the
            -- fact (`sync.owner`) - not only once actually connected.
            case ( sync.ownerToken, sync.sync.select ) of
                ( Just token, Just ( _, backend ) ) ->
                    let
                        room =
                            { backend = Backend.toString True backend
                            , course = model.readme
                            , room = sync.room
                            , mode = fromClassroomMode sync.mode
                            , ownerTokenHash = sync.ownerTokenHash
                            , pwSalt = sync.pwSalt
                            , pwCheck = sync.pwCheck
                            , ownerToken = Just token
                            }
                    in
                    model
                        |> Return.val
                        |> Return.batchEvent
                            (Service.Share.link
                                { title = "Classroom owner link"
                                , text = "Use this link to manage \"" ++ sync.room ++ "\" as its owner."
                                , url = Session.urlWithQuery (Session.encodeOwnerLink room) session
                                , image = Nothing
                                }
                            )

                _ ->
                    model |> Return.val

        EditMeta entry meta ->
            let
                update_ e =
                    if e.room == entry.room && e.backend == entry.backend then
                        { e
                            | title = nonEmpty meta.title
                            , notes = nonEmpty meta.notes
                            , name = nonEmpty meta.name
                        }

                    else
                        e

                nonEmpty str =
                    if String.isEmpty str then
                        Nothing

                    else
                        Just str
            in
            { model | sync = { sync | saved = List.map update_ sync.saved } }
                |> Return.val

        SaveMeta entry ->
            -- fired on blur, so the (already locally updated by `EditMeta`)
            -- title/notes/name only get written to IndexedDB once editing
            -- settles, not on every keystroke
            let
                current =
                    sync.saved
                        |> List.filter (\e -> e.room == entry.room && e.backend == entry.backend)
                        |> List.head
                        |> Maybe.withDefault entry
            in
            model
                |> Return.val
                |> Return.batchEvent
                    (Service.Sync.updateClassroomMeta model.readme
                        entry.room
                        entry.backend
                        { title = current.title |> Maybe.withDefault ""
                        , notes = current.notes |> Maybe.withDefault ""
                        , name = current.name |> Maybe.withDefault ""
                        }
                    )

        LoadClassroom entry ->
            case Backend.fromString entry.backend of
                Just backend ->
                    let
                        innerSync =
                            sync.sync
                    in
                    { model
                        | sync =
                            { sync
                                | sync = { innerSync | select = Just ( True, backend ), open = False }
                                , room = entry.room
                                , password = entry.password |> Maybe.withDefault ""
                                , name = entry.name |> Maybe.withDefault sync.name
                                , title = entry.title |> Maybe.withDefault ""
                                , notes = entry.notes |> Maybe.withDefault ""
                                , persistent = True

                                -- mode is folded into the network room identity
                                -- (see TS Sync.uniqueID), so reconnecting has to
                                -- reuse the same mode the classroom was saved
                                -- under, otherwise it joins a different room and
                                -- loses the CRDT ownership history
                                , mode = toClassroomMode entry.mode
                                , locked = True
                                , passwordLocked = True
                            }
                    }
                        |> Return.val

                Nothing ->
                    model |> Return.val

        OpenNotes ->
            let
                innerSync =
                    sync.sync
            in
            { model
                | sync =
                    { sync
                        | sync = { innerSync | select = Just ( True, Backend.Local ), open = False }
                        , room = Classroom.notesRoomName
                        , password = ""
                        , title = ""
                        , notes = ""
                        , persistent = True
                        , locked = False
                        , passwordLocked = False
                    }
            }
                |> Return.val

        AskDeleteClassroom room backend ->
            { model | sync = { sync | deletePopup = Just ( room, backend ) } }
                |> Return.val

        CancelDeleteClassroom ->
            { model | sync = { sync | deletePopup = Nothing } }
                |> Return.val

        ConfirmDeleteClassroom room backend ->
            { model
                | sync =
                    { sync
                        | deletePopup = Nothing
                        , saved =
                            List.filter
                                (\entry -> entry.room /= room || entry.backend /= backend)
                                sync.saved
                    }
            }
                |> Return.val
                |> Return.batchEvent (Service.Sync.deleteClassroom model.readme room backend)

        Connect ->
            case ( sync.sync.select, sync.state ) of
                ( Just ( True, backend ), Disconnected ) ->
                    { model | sync = { sync | state = Pending, sync = closeSelect sync.sync, name = String.trim sync.name } }
                        |> Return.val
                        |> Return.batchEvent
                            (Service.Sync.connect
                                { backend = backend
                                , course = model.readme
                                , room = sync.room
                                , password = sync.password

                                -- the "Own Notes" checkbox is always shown as
                                -- checked (and disabled) for a Local backend,
                                -- so it must always actually persist too
                                , persistent = sync.persistent || backend == Backend.Local
                                , name = String.trim sync.name
                                , title = String.trim sync.title
                                , notes = String.trim sync.notes
                                , mode = fromClassroomMode sync.mode
                                , ownerTokenHash = sync.ownerTokenHash
                                , pwSalt = sync.pwSalt
                                , pwCheck = sync.pwCheck
                                , ownerToken = sync.ownerToken
                                }
                            )
                        |> Return.batchEvent
                            -- only a join brings along a pwCheck hint to
                            -- verify against - a freshly created room has
                            -- nothing yet to check
                            (if String.isEmpty sync.pwCheck then
                                Event.none

                             else
                                Service.Sync.checkPassword
                                    { password = sync.password
                                    , pwSalt = sync.pwSalt
                                    , pwCheck = sync.pwCheck
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
            let
                sync =
                    model.sync
            in
            { model | sync = { sync | preloaded = True } }
                |> Return.val
                |> Return.batchEvent
                    (model.sections
                        |> JE.array (Section.sync id)
                        |> Service.Sync.join
                    )
                |> Return.batchEvents
                    (if sync.preloaded then
                        []

                     else
                        preloadEvents model.sections
                    )

        _ ->
            Return.val model


{-| Request persisted quiz/survey answers for every section that hasn't been
parsed yet, so a joining peer's history reaches the CRDT even for slides
nobody has visited this session - without paying for a full-course parse.
Replies are routed through the existing `Quiz.Update`/`Survey.Update`
`"load"` handler via the same `Event.pushWithId` convention `add_load` uses.
-}
preloadEvents : Sections -> List Event
preloadEvents =
    Array.toList
        >> List.indexedMap
            (\i sec ->
                if sec.parsed then
                    []

                else
                    [ Service.Database.load "quiz" i |> Event.pushWithId "quiz" i
                    , Service.Database.load "survey" i |> Event.pushWithId "survey" i
                    ]
            )
        >> List.concat


synchronize :
    { model
        | sync : Settings
        , sections : Sections
        , chat : Chat.Model
        , search_index : String -> String
        , definition : Definition
        , settings : Lia.Settings
        , readme : String
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
                , settings : Lia.Settings
                , readme : String
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
            let
                ( todo, chat ) =
                    param
                        |> JD.decodeValue Chat.decoder
                        |> Result.map (Chat.insert model.sync model.sync.scriptsEnabled model.search_index model.definition model.chat)
                        |> Result.withDefault ( [], model.chat )
            in
            { model | chat = chat, settings = updatedChatMessages model.settings }
                |> Return.val
                |> Return.batchEvents todo
                |> Return.batchEvent (Service.Slide.scrollDown "lia-chat-messages" 350)

        Ok ( "peer", param ) ->
            let
                sync =
                    model.sync

                peers =
                    param
                        |> JD.decodeValue decodePeers
                        |> Result.withDefault sync.peers
            in
            { model
                | sync =
                    { sync
                        | peers = peers
                        , peersHistory = Dict.union peers sync.peersHistory
                    }
            }
                |> Return.val

        Ok ( "identity", param ) ->
            let
                sync =
                    model.sync

                identities =
                    param
                        |> JD.decodeValue decodePeers
                        |> Result.withDefault Dict.empty
            in
            { model
                | sync =
                    { sync
                        | peersHistory = Dict.union sync.peersHistory identities
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

        Ok ( "ownership", param ) ->
            case JD.decodeValue JD.bool param of
                Ok ownership ->
                    let
                        sync =
                            model.sync
                    in
                    { model | sync = { sync | owner = ownership } }
                        |> Return.val
                        |> Return.batchEvent
                            (case ( sync.persistent, sync.sync.select ) of
                                ( True, Just ( _, backend ) ) ->
                                    Service.Sync.markOwner model.readme sync.room (Backend.toString True backend) ownership

                                _ ->
                                    Event.none
                            )

                Err info ->
                    model
                        |> Return.val
                        |> warn "decoding ownership" (JD.errorToString info)

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


{-| Reply of the `"owner_token"` event - a freshly minted secret and its
hash, generated together so they're correct by construction, see
`Service.Sync.generateOwnerToken`.
-}
ownerTokenGenerated : JD.Decoder { token : String, hash : String }
ownerTokenGenerated =
    JD.map2 (\token hash -> { token = token, hash = hash })
        (JD.field "token" JD.string)
        (JD.field "hash" JD.string)


{-| Ack payload of the `"connect"` event. `ownerToken` is only ever the raw
secret we already hold by then - reported back so a plain reconnect (page
reload, "Your classrooms") can still display/copy it even though Elm itself
never received it via a generate action or an owner-link this time; never a
route for one browser to learn another's secret, see `Session.Room`.
-}
connectAck :
    JD.Decoder
        { id : String
        , ownerTokenHash : String
        , pwSalt : String
        , pwCheck : String
        , ownerToken : Maybe String
        }
connectAck =
    JD.succeed
        (\id_ hash salt check token ->
            { id = id_
            , ownerTokenHash = hash
            , pwSalt = salt
            , pwCheck = check
            , ownerToken =
                if String.isEmpty token then
                    Nothing

                else
                    Just token
            }
        )
        |> JDP.required "id" JD.string
        |> JDP.optional "ownerTokenHash" JD.string ""
        |> JDP.optional "pwSalt" JD.string ""
        |> JDP.optional "pwCheck" JD.string ""
        |> JDP.optional "ownerToken" JD.string ""


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
