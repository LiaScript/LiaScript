module Lia.Markdown.Quiz.Vector.Json exposing
    ( encode
    , fromState
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))


encode : (body -> JE.Value) -> Quiz body -> ( String, JE.Value )
encode encoder quiz =
    ( case quiz.solution of
        SingleChoice _ ->
            "SingleChoice"

        MultipleChoice _ ->
            "MultipleChoice"
    , JE.object
        [ ( "options", JE.list (JE.list encoder) quiz.options )
        , ( "solution", fromState quiz.solution )
        ]
    )


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
