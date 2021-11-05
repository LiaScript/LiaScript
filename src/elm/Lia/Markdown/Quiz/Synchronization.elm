module Lia.Markdown.Quiz.Synchronization exposing
    ( State
    , decoder
    , encoder
    , toState
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)


type State
    = Trials Int
    | Resolved


toState : { quiz | trial : Int, solved : Solution } -> Maybe State
toState quiz =
    case quiz.solved of
        Solution.Solved ->
            Just (Trials quiz.trial)

        Solution.ReSolved ->
            Just Resolved

        Solution.Open ->
            Nothing


encoder : State -> JE.Value
encoder state =
    case state of
        Trials i ->
            JE.int i

        Resolved ->
            JE.null


decoder : JD.Decoder State
decoder =
    [ JD.int |> JD.map Trials
    , JD.null Resolved
    ]
        |> JD.oneOf
