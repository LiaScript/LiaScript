module Service.Resource exposing
    ( link
    , offline
    , offlineOpen
    , script
    , script_module
    , style
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


script_module : String -> Event
script_module url =
    event "module" url


{-| Generate an event that will dynamically load (inject) a custom
<style> - tag into the head of the document.
-}
style : String -> Event
style body =
    event "style" body


{-| Store all media of a course for offline use, `body` contains the parsed
sections. The progress is replied as `{slides, total, failed}`.
-}
offline : JE.Value -> Event
offline body =
    Event.init "resource" { cmd = "offline", param = body }


{-| Open the course behind `href` and run `offline` as soon as it is loaded.
-}
offlineOpen : { url : String, href : String } -> Event
offlineOpen { url, href } =
    { cmd = "offline_open"
    , param = JE.object [ ( "url", JE.string url ), ( "href", JE.string href ) ]
    }
        |> Event.init "resource"
        |> Event.withNoReply


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Resource.ts`.
-}
event : String -> String -> Event
event type_ param_ =
    { cmd = type_, param = JE.string param_ }
        |> Event.init "resource"
        |> Event.withNoReply
