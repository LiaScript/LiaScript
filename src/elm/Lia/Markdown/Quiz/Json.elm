module Lia.Markdown.Quiz.Json exposing
    ( fromVector
    , toVector
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Block.Json as Block
import Lia.Markdown.Quiz.MultipleChoice.Json as MultipleChoice
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Json as MultipleChoiceMatrix
import Lia.Markdown.Quiz.SingleChoice.Json as SingleChoice
import Lia.Markdown.Quiz.SingleChoiceMatrix.Json as SingleChoiceMatrix
import Lia.Markdown.Quiz.Types exposing (Element, Solution(..), State(..), Vector)


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
        , ( "state", fromState element.state )
        , ( "trial", JE.int element.trial )
        , ( "hint", JE.int element.hint )
        , ( "error_msg", JE.string element.error_msg )
        ]


fromState : State -> JE.Value
fromState state =
    case state of
        Empty_State ->
            JE.object [ ( "Empty", JE.null ) ]

        Block_State s ->
            Block.fromState s

        SingleChoice_State s ->
            SingleChoice.fromState s

        MultipleChoice_State s ->
            MultipleChoice.fromState s

        SingleChoiceMatrix_State s ->
            SingleChoiceMatrix.fromState s

        MultipleChoiceMatrix_State s ->
            MultipleChoiceMatrix.fromState s


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
        (JD.field "state" toState)
        (JD.field "trial" JD.int)
        (JD.field "hint" JD.int)
        (JD.field "error_msg" JD.string)


toState : JD.Decoder State
toState =
    JD.oneOf
        [ Block.toState |> JD.map Block_State
        , SingleChoice.toState |> JD.map SingleChoice_State
        , MultipleChoice.toState |> JD.map MultipleChoice_State
        , SingleChoiceMatrix.toState |> JD.map SingleChoiceMatrix_State
        , MultipleChoiceMatrix.toState |> JD.map MultipleChoiceMatrix_State
        , JD.field "Empty" JD.value |> JD.andThen (\_ -> JD.succeed Empty_State)
        ]
