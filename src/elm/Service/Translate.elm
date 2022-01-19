module Service.Translate exposing (google)

import Json.Encode as JE
import Service.Event as Event exposing (Event)


{-| Simply send this event to the external service `Translate.ts` to enforce a
translation of the entire site by google translate. This will result in a code
injection of the google-translate API.

_Other translate services might be implemented in the future._

-}
google : Event
google =
    { cmd = "google", param = JE.null }
        |> Event.init "translate"
        |> Event.withNoReply
