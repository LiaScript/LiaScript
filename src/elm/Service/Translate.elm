module Service.Translate exposing (google)

import Json.Encode as JE
import Service.Event as Event exposing (Event)


google : Event
google =
    { cmd = "google", param = JE.null }
        |> Event.initX "translate"
        |> Event.withNoReply
