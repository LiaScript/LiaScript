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
            SingleChoice length value ->
                [ ( "SingleChoice", JE.list JE.int [ length, value ] ) ]

            MultipleChoice x ->
                [ ( "MultipleChoice", JE.array JE.bool x ) ]


toState : JD.Decoder State
toState =
    JD.oneOf
        [ JD.int
            |> JD.list
            |> JD.field "SingleChoice"
            |> JD.andThen toSingleChoice
        , JD.array JD.bool
            |> JD.field "MultipleChoice"
            |> JD.map MultipleChoice
        ]


toSingleChoice : List Int -> JD.Decoder State
toSingleChoice params =
    case params of
        [ length, value ] ->
            JD.succeed <| SingleChoice length value

        _ ->
            JD.fail "SingleChoice decoding ... not enough parameters"
