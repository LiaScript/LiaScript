module Lia.Markdown.Quiz.Vector.Json exposing
    ( fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))


fromState : State -> JE.Value
fromState state =
    JE.object <|
        case state of
            SingleChoice list ->
                [ ( "SingleChoice", JE.list JE.bool list ) ]

            MultipleChoice list ->
                [ ( "MultipleChoice", JE.list JE.bool list ) ]


toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.list JD.bool
            |> JD.field "SingleChoice"
            |> JD.map SingleChoice
        , JD.list JD.bool
            |> JD.field "MultipleChoice"
            |> JD.map MultipleChoice
        ]
