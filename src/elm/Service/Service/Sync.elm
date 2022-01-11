module Service.Service.Sync exposing (..)

import Json.Encode as JE
import Lia.Sync.Via as Via
import Service.Event as Event exposing (Event)


connect :
    { backend : Via.Backend
    , course : String
    , room : String
    , username : String
    , password : String
    }
    -> Event
connect param =
    [ ( "backend"
      , param.backend
            |> Via.toString
            |> String.toLower
            |> JE.string
      )
    , ( "config"
      , JE.object
            [ ( "course", JE.string param.course )
            , ( "room", JE.string param.room )
            , ( "username", JE.string param.username )
            , ( "password"
              , if String.isEmpty param.password then
                    JE.null

                else
                    JE.string param.password
              )
            ]
      )
    ]
        |> JE.object
        |> publish "connect"


disconnect : Event
disconnect =
    publish "disconnect" JE.null


join : String -> JE.Value -> Event
join id message =
    [ ( "id", JE.string id )
    , ( "data", message )
    ]
        |> JE.object
        |> publish "join"


publish : String -> JE.Value -> Event
publish cmd message =
    { cmd = cmd, param = message }
        |> Event.initX "sync"
