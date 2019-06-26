module Lia.Markdown.Quiz.MultipleChoice.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.MultipleChoice.Types exposing (State)


uid : String
uid =
    "MultipleChoice"


fromState : State -> JE.Value
fromState state =
    JE.object [ ( uid, JE.list JE.bool state ) ]


toState : JD.Decoder State
toState =
    JD.field uid (JD.list JD.bool)
