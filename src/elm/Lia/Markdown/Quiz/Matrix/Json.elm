module Lia.Markdown.Quiz.Matrix.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Matrix.Types exposing (State)
import Lia.Markdown.Quiz.Vector.Json as Vector


uid : String
uid =
    "Matrix"


fromState : State -> JE.Value
fromState state =
    JE.object <|
        [ ( uid, JE.array Vector.fromState state ) ]


toState : JD.Decoder State
toState =
    Vector.toState
        |> JD.array
        |> JD.field uid
