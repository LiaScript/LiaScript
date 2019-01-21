module Lia.Quiz.Json exposing
    ( jsonToVector
    , vectorToJson
    )

--import Array exposing (Array)

import Json.Decode as JD
import Json.Encode as JE
import Lia.Quiz.Types exposing (..)


vectorToJson : Vector -> JE.Value
vectorToJson vector =
    JE.array elementToJson vector


elementToJson : Element -> JE.Value
elementToJson element =
    JE.object
        [ ( "solved"
          , JE.int
                (case element.solved of
                    Open ->
                        0

                    Solved ->
                        1

                    ReSolved ->
                        -1
                )
          )

        --, ( "solution", stateToJson element.solution )
        , ( "state", stateToJson element.state )
        , ( "trial", JE.int element.trial )
        , ( "hint", JE.int element.hint )
        , ( "error_msg", JE.string element.error_msg )
        ]


stateToJson : State -> JE.Value
stateToJson state =
    JE.object <|
        case state of
            EmptyState ->
                [ ( "type", JE.string "Empty" ) ]

            TextState x ->
                [ ( "type", JE.string "Text" )
                , ( "value", JE.string x )
                ]

            SingleChoiceState x ->
                [ ( "type", JE.string "SingleChoice" )
                , ( "value", JE.int x )
                ]

            MultipleChoiceState m ->
                [ ( "type", JE.string "MultipleChoice" )
                , ( "value", JE.array JE.bool m )
                ]


jsonToVector : JD.Value -> Result JD.Error Vector
jsonToVector json =
    JD.decodeValue (JD.array jsonToElement) json


jsonToElement : JD.Decoder Element
jsonToElement =
    let
        solved_decoder i =
            case i of
                0 ->
                    JD.succeed Open

                1 ->
                    JD.succeed Solved

                _ ->
                    JD.succeed ReSolved
    in
    JD.map5 Element
        (JD.field "solved" JD.int |> JD.andThen solved_decoder)
        --(JD.field "solution" jsonToState)
        (JD.field "state" jsonToState)
        (JD.field "trial" JD.int)
        (JD.field "hint" JD.int)
        (JD.field "error_msg" JD.string)


jsonToState : JD.Decoder State
jsonToState =
    let
        state_decoder type_ =
            case type_ of
                "Empty" ->
                    JD.succeed EmptyState

                "Text" ->
                    JD.map TextState (JD.field "value" JD.string)

                "SingleChoice" ->
                    JD.map SingleChoiceState (JD.field "value" JD.int)

                "MultipleChoice" ->
                    JD.map MultipleChoiceState (JD.field "value" (JD.array JD.bool))

                _ ->
                    JD.fail <|
                        "not supported type: "
                            ++ type_
    in
    JD.field "type" JD.string
        |> JD.andThen state_decoder
