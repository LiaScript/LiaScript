module Service.Local exposing
    ( clear
    , download
    , store
    )

import Json.Encode as JE
import Service.Event as Event exposing (Event)


store : String -> Event
store uri =
    event "store" (JE.string uri)


clear : Event
clear =
    event "clear" JE.null


download : String -> Event
download url =
    event "download" (JE.string url)


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Slide.ts`.
-}
event : String -> JE.Value -> Event
event cmd message =
    { cmd = cmd, param = message }
        |> Event.init "local"
        |> Event.withNoReply
