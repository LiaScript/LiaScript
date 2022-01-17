module Service.Database exposing (load)

import Json.Encode as JE
import Service.Event as Event exposing (Event)


load : String -> Int -> Event
load table id =
    [ ( "table", JE.string table ), ( "id", JE.int id ) ]
        |> JE.object
        |> event "load"


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Database.ts`.
-}
event : String -> JE.Value -> Event
event cmd param =
    Event.init "db" { cmd = cmd, param = param }
