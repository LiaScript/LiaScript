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


type alias Sync =
    Array String


sync : Code.Project -> Sync
sync project =
    project
        |> Code.loadVersion 0
        |> .file
        |> Array.map .code


decoder : JD.Decoder Sync
decoder =
    JD.array JD.string


encoder : Sync -> JE.Value
encoder =
    JE.array JE.string
