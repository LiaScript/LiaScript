module Service.Sync exposing (..)

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
