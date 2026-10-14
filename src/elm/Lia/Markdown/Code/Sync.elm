module Lia.Markdown.Code.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    )

{-| What a project shares in a classroom: the code of its files.
-}

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Types as Code


type alias Sync =
    Array String


{-| The original code of the course (version 0), the common starting point.
-}
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
