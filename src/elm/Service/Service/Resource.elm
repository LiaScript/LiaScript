module Service.Service.Resource exposing
    ( link
    , script
    )

import Json.Encode as JE
import Service.Event as Event exposing (Event)


{-| Generate an event that will dynamically load (inject) a custom
`style-sheet.css` into the head of the document.
-}
link : String -> Event
link url =
    event "link" url


{-| Generate an event that will dynamically load (inject) a custom
JavaScript file/library into the head of the document.
-}
script : String -> Event
script url =
    event "script" url


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Resource.ts`.
-}
event : String -> String -> Event
event type_ url =
    { cmd = type_, param = JE.string url }
        |> Event.initX "resource"
        |> Event.withNoReply
