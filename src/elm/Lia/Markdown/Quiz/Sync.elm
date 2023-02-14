module Lia.Markdown.Quiz.Sync exposing
    ( Sync
    , decoder
    , encoder
    , event
    , sync
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Service.Event as Event exposing (Event)
import Service.Sync


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


event : Int -> { quiz | trial : Int, solved : Solution } -> Event
event id =
    sync
        >> Maybe.map (encoder >> Service.Sync.quiz id)
        >> Maybe.withDefault Event.none


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
