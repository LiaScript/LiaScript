module Lia.Markdown.Quiz.Json exposing
    ( encode
    , fromVector
    , toVector
    )

import Conditional.List as CList
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Quiz.Block.Json as Block
import Lia.Markdown.Quiz.Matrix.Json as Matrix
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types exposing (Element, Options, Quiz, State(..), Type(..), Vector)
import Lia.Markdown.Quiz.Vector.Json as Vector


encode : Quiz -> JE.Value
encode quiz =
    JE.object
        [ case quiz.quiz of
            Generic_Type ->
                ( "Generic", JE.null )

            Block_Type block ->
                Block.encode block

            Vector_Type vector ->
                Vector.encode vector

            Matrix_Type matrix ->
                Matrix.encode matrix
        , ( "id", JE.int quiz.id )
        , ( "hints", JE.list Inline.encode quiz.hints )
        ]


fromVector : Bool -> Vector -> JE.Value
fromVector withScore =
    JE.array (fromElement withScore)


fromElement : Bool -> Element -> JE.Value
fromElement withScore element =
    [ ( "solved"
      , JE.int
            (case element.solved of
                Solution.Open ->
                    0

                Solution.Solved ->
                    1

                Solution.ReSolved ->
                    -1
            )
      )
    , ( "state", fromState element.state )
    , ( "trial", JE.int element.trial )
    , ( "hint", JE.int element.hint )
    , ( "error_msg", JE.string element.error_msg )
    ]
        |> CList.addIf withScore (fromOptions element.opt)
        |> JE.object


fromOptions : Options -> ( String, JE.Value )
fromOptions opt =
    ( "score"
    , opt.score
        |> Maybe.withDefault 0
        |> JE.float
    )


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
toVector =
    JD.decodeValue (JD.array toElement)


toElement : JD.Decoder Element
toElement =
    let
        solved_decoder i =
            case i of
                0 ->
                    JD.succeed Solution.Open

                1 ->
                    JD.succeed Solution.Solved

                _ ->
                    JD.succeed Solution.ReSolved
    in
    JD.map7 Element
        (JD.field "solved" JD.int |> JD.andThen solved_decoder)
        (JD.field "state" toState)
        (JD.field "trial" JD.int)
        (JD.field "hint" JD.int)
        (JD.field "error_msg" JD.string)
        (JD.succeed Nothing)
        (JD.succeed
            { randomize = Nothing
            , maxTrials = Nothing
            , score = Nothing
            , showResolveAt = 0
            }
        )


toState : JD.Decoder State
toState =
    JD.oneOf
        [ Block.toState |> JD.map Block_State
        , Vector.toState |> JD.map Vector_State
        , Matrix.toState |> JD.map Matrix_State
        , JD.field "Generic" JD.value |> JD.andThen (\_ -> JD.succeed Generic_State)
        ]
