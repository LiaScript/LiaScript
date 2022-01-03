module Port.Service.Console exposing
    ( error
    , log
    , warn
    )

import Json.Encode as JE
import Port.Event as Event exposing (Event)


{-| Create a log event, that will output the message string with `console.log`.

_This type of event will not generate a reply message._

-}
log : String -> Event
log message =
    console "log" message


{-| Create a log event, that will output the message string with `console.warn`.

_This type of event will not generate a reply message._

-}
warn : String -> Event
warn message =
    console "warn" message


{-| Create a log event, that will output the message string with `console.error`.

_This type of event will not generate a reply message._

-}
error : String -> Event
error message =
    console "error" message


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Console.ts`.
-}
console : String -> String -> Event
console cmd message =
    { cmd = cmd, param = JE.string message }
        |> Event.initX "console"
        |> Event.withNoReply
