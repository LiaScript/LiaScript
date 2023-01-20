module Service.Sync exposing (..)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Sync.Via as Via
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
            [ ( "course", JE.string param.course )
            , ( "room", JE.string param.room )
            , ( "password"
              , if String.isEmpty param.password then
                    JE.null

                else
                    JE.string param.password
              )
            , ( "config"
              , case param.backend of
                    Via.GUN urls ->
                        urls
                            |> String.split ","
                            |> List.map String.trim
                            |> List.filter (String.isEmpty >> not)
                            |> JE.list JE.string

                    Via.PubNub pub sub ->
                        JE.object
                            [ ( "publishKey", JE.string pub )
                            , ( "subscribeKey", JE.string sub )
                            ]

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


codes : Array (Array String) -> Event
codes =
    JE.array (JE.array JE.string) >> publish "codes"
