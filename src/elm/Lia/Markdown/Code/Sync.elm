module Lia.Markdown.Code.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Types as Code


type alias Sync =
    { file : Array String
    , log : Log
    }


sync : Code.Project -> Sync
sync project =
    { file =
        project
            |> Code.loadVersion 0
            |> .file
            |> Array.map .code
    , log = Log.empty
    }


decoder : JD.Decoder Sync
decoder =
    JD.map2 Sync
        (JD.array JD.string)
        (JD.succeed Log.empty)


encoder : Sync -> JE.Value
encoder =
    .file >> JE.array JE.string
