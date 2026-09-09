module Lia.Markdown.Quiz.Sync exposing
    ( Sync
    , decoder
    , encoder
    , event
    , lockAnswered
    , sync
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Json as Json
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Lia.Markdown.Quiz.Types exposing (State)
import Lia.Sync.Container as Container exposing (Container)
import Service.Event as Event exposing (Event)
import Service.Sync


type alias Sync =
    { trial : Maybe Int
    , state : State
    }


sync : { quiz | trial : Int, solved : Solution, state : State } -> Maybe Sync
sync quiz =
    case quiz.solved of
        Solution.Solved ->
            Just { trial = Just quiz.trial, state = quiz.state }

        Solution.ReSolved ->
            Just { trial = Nothing, state = quiz.state }

        Solution.Open ->
            Nothing


event : Int -> { quiz | trial : Int, solved : Solution, state : State } -> Event
event id =
    sync
        >> Maybe.map (encoder >> Service.Sync.quiz id)
        >> Maybe.withDefault Event.none


{-| A quiz answered from another session/device (or synced faster than a
local restore) is already known to the classroom. Lock it here too, so it
can't be silently re-answered and overwrite the shared classroom state.
-}
lockAnswered :
    Maybe String
    -> Dict Int (Container Sync)
    -> Maybe Int
    -> Array { a | solved : Solution, trial : Int, state : State }
    -> Array { a | solved : Solution, trial : Int, state : State }
lockAnswered ownId answered sectionID vector =
    case ( sectionID, ownId ) of
        ( Just sID, Just myId ) ->
            vector
                |> Array.indexedMap
                    (\idx e ->
                        if e.solved /= Solution.Open then
                            e

                        else
                            answered
                                |> Dict.get sID
                                |> Maybe.andThen (Container.get idx)
                                |> Maybe.andThen (Dict.get myId)
                                |> Maybe.map
                                    (\answer ->
                                        { e
                                            | solved =
                                                case answer.trial of
                                                    Just _ ->
                                                        Solution.Solved

                                                    Nothing ->
                                                        Solution.ReSolved
                                            , trial = answer.trial |> Maybe.withDefault e.trial
                                            , state = answer.state
                                        }
                                    )
                                |> Maybe.withDefault e
                    )

        _ ->
            vector


encoder : Sync -> JE.Value
encoder s =
    JE.object
        [ ( "trial", s.trial |> Maybe.map JE.int |> Maybe.withDefault JE.null )
        , ( "state", Json.fromState s.state )
        ]


decoder : JD.Decoder Sync
decoder =
    JD.map2 Sync
        (JD.field "trial" ([ JD.int |> JD.map Just, JD.null Nothing ] |> JD.oneOf))
        (JD.field "state" Json.toState)
