module Lia.Markdown.Code.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Types as Code
import Service.Event as Event exposing (Event)
import Service.Sync


type alias Sync =
    Array String


sync : Code.Project -> Maybe Sync
sync =
    (Code.loadVersion 0 >> .file >> Array.map .code) >> Just


decoder : JD.Decoder Sync
decoder =
    JD.array JD.string


encoder : Sync -> JE.Value
encoder =
    JE.array JE.string
