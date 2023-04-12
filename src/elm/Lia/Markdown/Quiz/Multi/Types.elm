module Lia.Markdown.Quiz.Multi.Types exposing
    ( Quiz
    , State
    , comp
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


type alias Quiz opt =
    { elements : List opt
    , options : Array (List opt)
    , solution : State
    }


init : Quiz opt
init =
    Quiz [] Array.empty Array.empty


isEmpty : Quiz opt -> Bool
isEmpty quiz =
    Array.isEmpty quiz.options


push : Block.Quiz opt -> Quiz opt -> Quiz opt
push { options, solution } quiz =
    { quiz
        | options = Array.push options quiz.options
        , solution = Array.push solution quiz.solution
    }


initState : State -> State
initState =
    Array.map Block.initState


comp : Quiz opt -> State -> Bool
comp quiz state =
    let
        list1 =
            quiz.solution
                |> Array.toList
                |> List.map (Block.Quiz [])

        list2 =
            Array.toList state
    in
    List.map2 Block.comp list1 list2
        |> List.all identity


getClass : State -> String
getClass _ =
    "multi"
