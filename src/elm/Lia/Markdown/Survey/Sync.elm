module Lia.Markdown.Survey.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Types as Survey


type Sync
    = Sync Survey.State


sync : Survey.Element -> Maybe Sync
sync survey =
    if survey.submitted then
        Just (Sync survey.state)

    else
        Nothing


encoder : Sync -> JE.Value
encoder (Sync state) =
    Json.fromState state


decoder : JD.Decoder Sync
decoder =
    JD.map Sync Json.toState
