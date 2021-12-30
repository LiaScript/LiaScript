module Port.Service.Resource exposing (link, script)

import Json.Encode as JE
import Port.Event as Event exposing (Event)


link : String -> Event
link =
    load "link"


script : String -> Event
script =
    load "script"


load : String -> String -> Event
load type_ url =
    { cmd = type_, param = JE.string url }
        |> Event.initX "resource"
        |> Event.withNoReply
