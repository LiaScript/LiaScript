module Lia.Markdown.Quiz.Json exposing
    ( fromVector
    , toVector
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Types exposing (..)


fromVector : Vector -> JE.Value
fromVector vector =
    JE.array fromElement vector


fromElement : Element -> JE.Value
fromElement element =
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
        , ( "state", fromState element.state )
        , ( "trial", JE.int element.trial )
        , ( "hint", JE.int element.hint )
        , ( "error_msg", JE.string element.error_msg )
        ]


fromState : State -> JE.Value
fromState state =
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
                , ( "value", JE.list JE.bool m )
                ]


toVector : JD.Value -> Result JD.Error Vector
toVector json =
    JD.decodeValue (JD.array toElement) json


toElement : JD.Decoder Element
toElement =
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
        (JD.field "state" toState)
        (JD.field "trial" JD.int)
        (JD.field "hint" JD.int)
        (JD.field "error_msg" JD.string)


toState : JD.Decoder State
toState =
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
                    JD.map MultipleChoiceState (JD.field "value" (JD.list JD.bool))

                _ ->
                    JD.fail <|
                        "not supported type: "
                            ++ type_
    in
    JD.field "type" JD.string
        |> JD.andThen state_decoder
