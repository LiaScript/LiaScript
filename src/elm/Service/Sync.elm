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
            |> Via.toString
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
        |> Event.init "sync"
