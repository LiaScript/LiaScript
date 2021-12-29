module Port.Service.Console exposing
    ( error
    , log
    , warn
    )

import Json.Encode as JE
import Port.Event as Event exposing (Event)


log : String -> Event
log message =
    console "log" message


warn : String -> Event
warn message =
    console "warn" message


error : String -> Event
error message =
    console "error" message


console : String -> String -> Event
console cmd message =
    { cmd = cmd, param = JE.string message }
        |> Event.initX "console"
        |> Event.withNoReply
