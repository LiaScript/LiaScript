module Lia.Markdown.Quiz.Json exposing
    ( fromVector
    , toVector
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Block.Json as Block
import Lia.Markdown.Quiz.Matrix.Json as Matrix
import Lia.Markdown.Quiz.Types exposing (Element, Solution(..), State(..), Vector)
import Lia.Markdown.Quiz.Vector.Json as Vector


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
        Generic_State ->
            JE.object [ ( "Generic", JE.null ) ]

        Block_State s ->
            Block.fromState s

        Vector_State s ->
            Vector.fromState s

        Matrix_State s ->
            Matrix.fromState s


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
        , Vector.toState |> JD.map Vector_State
        , Matrix.toState |> JD.map Matrix_State
        , JD.field "Generic" JD.value |> JD.andThen (\_ -> JD.succeed Generic_State)
        ]
