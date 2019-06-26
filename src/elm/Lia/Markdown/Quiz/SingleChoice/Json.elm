module Lia.Markdown.Quiz.SingleChoice.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.SingleChoice.Types exposing (State)


uid : String
uid =
    "SingleChoice"


fromState : State -> JE.Value
fromState state =
    JE.object [ ( uid, JE.int state ) ]


toState : JD.Decoder State
toState =
    JD.field uid JD.int
