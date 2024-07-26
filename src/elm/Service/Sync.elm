module Service.Sync exposing (chat, code, codes, connect, cursor, disconnect, join, publish, quiz, survey)

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
            [ ( "course"
              , param.course
                    |> IPFS.origin
                    |> Maybe.withDefault param.course
                    |> JE.string
              )
            , ( "room", JE.string param.room )
            , ( "password"
              , if String.isEmpty param.password then
                    JE.null

                else
                    JE.string param.password
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

                    Via.P2PT urls ->
                        urls
                            |> String.split ","
                            |> JE.list (String.trim >> JE.string)

                    _ ->
                        JE.null
              )
            ]
      )
    ]
        |> JE.object
        |> publish "connect"


disconnect : String -> Event
disconnect id =
    id
        |> JE.string
        |> publish "disconnect"


join : JE.Value -> Event
join =
    publish "join"


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
