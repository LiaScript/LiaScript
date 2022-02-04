module Lia.Markdown.Quiz.Sync exposing
    ( Sync
    , decoder
    , encoder
    , sync
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)


type alias Sync =
    Maybe Int


sync : { quiz | trial : Int, solved : Solution } -> Maybe Sync
sync quiz =
    case quiz.solved of
        Solution.Solved ->
            Just (Just quiz.trial)

        Solution.ReSolved ->
            Just Nothing

        Solution.Open ->
            Nothing


encoder : Sync -> JE.Value
encoder state =
    case state of
        Just i ->
            JE.int i

        Nothing ->
            JE.null


decoder : JD.Decoder Sync
decoder =
    [ JD.int |> JD.map Just
    , JD.null Nothing
    ]
        |> JD.oneOf
