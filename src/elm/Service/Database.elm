module Service.Database exposing
    ( load
    , settings
    )

import Json.Encode as JE
import Service.Event as Event exposing (Event)


load : String -> Int -> Event
load table id =
    [ ( "table", JE.string table )
    , ( "id", JE.int id )
    ]
        |> JE.object
        |> event "load"


settings : Maybe String -> JE.Value -> Event
settings customStyle config =
    [ ( "custom"
      , customStyle
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null
      )
    , ( "config", config )
    ]
        |> JE.object
        |> event "settings"


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Database.ts`.
-}
event : String -> JE.Value -> Event
event cmd param =
    Event.init "db" { cmd = cmd, param = param }
