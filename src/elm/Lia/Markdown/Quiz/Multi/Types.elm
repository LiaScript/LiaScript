module Lia.Markdown.Quiz.Multi.Types exposing
    ( Quiz
    , State
    , comp
    , comp2
    , getClass
    , init
    , initState
    , isEmpty
    , push
    )

import Array exposing (Array)
import Lia.Markdown.Quiz.Block.Types as Block


type alias State =
    Array Block.State


type alias Quiz block inline =
    { elements : List block
    , options : Array (List inline)
    , solution : State
    }


init : Quiz block inline
init =
    Quiz [] Array.empty Array.empty


isEmpty : Quiz block inline -> Bool
isEmpty quiz =
    Array.isEmpty quiz.options


push : Block.Quiz inline -> Quiz block inline -> Quiz block inline
push { options, solution } quiz =
    { quiz
        | options = Array.push options quiz.options
        , solution = Array.push solution quiz.solution
    }


initState : State -> State
initState =
    Array.map Block.initState


comp2 : Quiz block inline -> State -> List Bool
comp2 quiz state =
    let
        list1 =
            quiz.solution
                |> Array.toList
                |> List.map (Block.Quiz [])

        list2 =
            Array.toList state
    in
    List.map2 Tuple.pair list1 list2
        |> List.indexedMap
            (\i ( x, y ) ->
                Block.comp (Just i) x y
            )


comp : Quiz block inline -> State -> Bool
comp quiz =
    comp2 quiz >> List.all identity


getClass : State -> String
getClass _ =
    "multi"
