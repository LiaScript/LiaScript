module Service.Sync exposing (chat, checkPassword, code, codes, connect, cursor, deleteClassroom, disconnect, generateOwnerToken, join, listClassrooms, markOwner, publish, quiz, survey, updateClassroomMeta)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Sync.Via as Via
import Library.IPFS as IPFS
import Service.Event as Event exposing (Event)


connect :
    { backend : Via.Backend
    , course : String
    , room : String
    , password : String
    , persistent : Bool
    , name : String
    , title : String
    , notes : String
    , mode : Int
    , ownerTokenHash : String
    , pwSalt : String
    , pwCheck : String
    , ownerToken : Maybe String
    }
    -> Event
connect param =
    [ ( "backend"
      , param.backend
            |> Via.toString False
            |> String.toLower
            |> JE.string
      )
    , ( "config"
      , JE.object
            [ -- the network identity of a room, an IPFS-course is identified
              -- by its origin, no matter which gateway is used to load it
              ( "course"
              , param.course
                    |> IPFS.origin
                    |> Maybe.withDefault param.course
                    |> JE.string
              )

            -- the name of the local database, which is always the plain
            -- course-URL, see `Service.Database`
            , ( "uidDB", JE.string param.course )
            , ( "room", JE.string param.room )
            , ( "mode", JE.int param.mode )
            , ( "password"
              , if String.isEmpty param.password then
                    JE.null

                else
                    JE.string param.password
              )
            , ( "persistent", JE.bool param.persistent )
            , ( "fullBackend", JE.string (Via.toString True param.backend) )
            , ( "name"
              , param.name
                    |> JE.string
              )
            , ( "title", JE.string param.title )
            , ( "notes", JE.string param.notes )
            , ( "ownerTokenHash", JE.string param.ownerTokenHash )
            , ( "pwSalt", JE.string param.pwSalt )
            , ( "pwCheck", JE.string param.pwCheck )
            , ( "ownerToken"
              , param.ownerToken
                    |> Maybe.map JE.string
                    |> Maybe.withDefault JE.null
              )
            , ( "config"
              , case param.backend of
                    Via.GUN { urls, persistent } ->
                        JE.object
                            [ ( "persistent", JE.bool persistent )
                            , ( "urls"
                              , urls
                                    |> String.split ","
                                    |> List.map String.trim
                                    |> List.filter (String.isEmpty >> not)
                                    |> JE.list JE.string
                              )
                            ]

                    -- Via.Jitsi domain ->
                    --     domain
                    --         |> JE.string
                    -- Via.Matrix { baseURL, userId, accessToken } ->
                    --     JE.object
                    --         [ ( "baseURL", JE.string baseURL )
                    --         , ( "userId", JE.string userId )
                    --         , ( "accessToken", JE.string accessToken )
                    --         ]
                    Via.PubNub { pubKey, subKey } ->
                        JE.object
                            [ ( "publishKey", JE.string pubKey )
                            , ( "subscribeKey", JE.string subKey )
                            ]

                    Via.Ably { apiKey, persistent } ->
                        JE.object
                            [ ( "apiKey", JE.string apiKey )
                            , ( "persistent", JE.bool persistent )
                            ]

                    Via.P2PT urls ->
                        urls
                            |> String.split ","
                            |> JE.list (String.trim >> JE.string)

                    Via.WebSocket { url } ->
                        JE.object
                            [ ( "url", JE.string url )
                            ]

                    Via.PeerJS { host, port_, path, iceServers } ->
                        JE.object
                            [ ( "host", JE.string host )
                            , ( "port", JE.string port_ )
                            , ( "path", JE.string path )
                            , ( "iceServers", JE.string iceServers )
                            ]

                    Via.SimplePeer { signaling, iceServers } ->
                        JE.object
                            [ ( "signaling", JE.string signaling )
                            , ( "iceServers", JE.string iceServers )
                            ]

                    Via.NoStr { relayUrls, turnConfig } ->
                        trysteroConfig relayUrls turnConfig

                    Via.MQTT { relayUrls, turnConfig } ->
                        trysteroConfig relayUrls turnConfig

                    Via.Torrent { relayUrls, turnConfig } ->
                        trysteroConfig relayUrls turnConfig

                    Via.IPFS { turnConfig } ->
                        trysteroConfig "" turnConfig

                    _ ->
                        JE.null
              )
            ]
      )
    ]
        |> JE.object
        |> publish "connect"


trysteroConfig : String -> String -> JE.Value
trysteroConfig relayUrls turnConfig =
    JE.object
        [ ( "relayUrls"
          , relayUrls
                |> String.split ","
                |> List.map String.trim
                |> List.filter (String.isEmpty >> not)
                |> JE.list JE.string
          )
        , ( "turnConfig", JE.string turnConfig )
        ]


{-| Persist a saved classroom's user-editable title/notes/name, without
touching its password/mode/connection settings. See `listClassrooms` on why
the `course` is not normalized, and `deleteClassroom` on the `backend`
string.
-}
updateClassroomMeta : String -> String -> String -> { title : String, notes : String, name : String } -> Event
updateClassroomMeta course room backend meta =
    [ ( "course", JE.string course )
    , ( "room", JE.string room )
    , ( "backend", JE.string backend )
    , ( "title", JE.string meta.title )
    , ( "notes", JE.string meta.notes )
    , ( "name", JE.string meta.name )
    ]
        |> JE.object
        |> publish "update_classroom_meta"


{-| Mirror the live CRDT-ownership flag (see the `"ownership"` event in
`Lia.Sync.Update`) into the saved classroom entry, so it can be shown on its
card without having to reconnect. Reuses the `update_classroom_meta` command,
but — unlike `updateClassroomMeta` — omits `title`/`notes` so the TS side's
partial update leaves them untouched.
-}
markOwner : String -> String -> String -> Bool -> Event
markOwner course room backend owner =
    [ ( "course", JE.string course )
    , ( "room", JE.string room )
    , ( "backend", JE.string backend )
    , ( "owner", JE.bool owner )
    ]
        |> JE.object
        |> publish "update_classroom_meta"


disconnect : String -> Event
disconnect id =
    id
        |> JE.string
        |> publish "disconnect"


{-| Ask TS to mint a fresh, cryptographically random owner secret (and its
hash) before ever connecting - the only other way to become owner is via an
owner-link, see `Session.encodeOwnerLink`. The reply arrives as an
`"owner_token"` event carrying `{ token, hash }`.
-}
generateOwnerToken : Event
generateOwnerToken =
    publish "generate_owner_token" JE.null


{-| Ask TS whether a typed password matches the room's `pwCheck` hint, purely
advisory (see peerCrypto.verifyPasswordCheck) - a mismatch comes back on the
existing `"warning"` channel, success stays silent.
-}
checkPassword : { password : String, pwSalt : String, pwCheck : String } -> Event
checkPassword param =
    [ ( "password", JE.string param.password )
    , ( "pwSalt", JE.string param.pwSalt )
    , ( "pwCheck", JE.string param.pwCheck )
    ]
        |> JE.object
        |> publish "check_password"


join : JE.Value -> Event
join =
    publish "join"


{-| The `course` is used as the name of the local database (`uidDB`), thus it
must be the plain course-URL — exactly like in `Service.Database` and like the
`uidDB` that is passed along with `connect`. It must **not** be normalized via
`IPFS.origin`, otherwise the classrooms of an IPFS-course would be written
into a different database than the one they are read from.
-}
listClassrooms : String -> Event
listClassrooms course =
    course
        |> JE.string
        |> publish "list_classrooms"


{-| The `backend` is the full (pipe-encoded) backend string, as it was stored
within the `classrooms` table. It is part of the primary key of a classroom
entry as well as of the id of its local cache. See `listClassrooms` on why the
`course` is not normalized.
-}
deleteClassroom : String -> String -> String -> Event
deleteClassroom course room backend =
    [ ( "course", JE.string course )
    , ( "room", JE.string room )
    , ( "backend", JE.string backend )
    ]
        |> JE.object
        |> publish "delete_classroom"


publish : String -> JE.Value -> Event
publish cmd message =
    { cmd = cmd, param = message }
        |> Event.init "sync"


survey : Int -> JE.Value -> Event
survey id =
    publish "survey" >> Event.pushWithId "id" id


quiz : Int -> JE.Value -> Event
quiz id =
    publish "quiz" >> Event.pushWithId "id" id


code : Int -> Int -> JE.Value -> Event
code id1 id2 msg =
    [ ( "j", JE.int id2 )
    , ( "msg", msg )
    ]
        |> JE.object
        |> publish "code"
        |> Event.pushWithId "id" id1


cursor : Int -> Int -> JE.Value -> Event
cursor id1 id2 msg =
    [ ( "project", JE.int id1 )
    , ( "file", JE.int id2 )
    , ( "state", msg )
    ]
        |> JE.object
        |> publish "cursor"
        |> Event.push "cursor"


codes : Array (Array String) -> Event
codes =
    JE.array (JE.array JE.string) >> publish "codes"


chat : String -> Event
chat =
    JE.string >> publish "chat"
