module Lia.Markdown.Quiz.SingleChoiceMatrix.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.SingleChoiceMatrix.Types exposing (State)


uid : String
uid =
    "SingleChoiceMatrix"


fromState : State -> JE.Value
fromState state =
    JE.object [ ( uid, JE.array JE.int state ) ]


toState : JD.Decoder State
toState =
    JD.field uid (JD.array JD.int)
