module Lia.Markdown.Quiz.MultipleChoiceMatrix.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Types exposing (State)


uid : String
uid =
    "MultipleChoiceMatrix"


fromState : State -> JE.Value
fromState state =
    JE.object [ ( uid, JE.array (JE.array JE.bool) state ) ]


toState : JD.Decoder State
toState =
    JD.field uid (JD.array (JD.array JD.bool))
