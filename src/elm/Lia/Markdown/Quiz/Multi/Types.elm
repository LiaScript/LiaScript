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


{-| The states of all inputs of a gap-text.
-}
type alias State =
    Array Block.State


{-| The block (paragraph, table, ...) that contains the inputs (only the first
element is used), the options and the solution of every input.
-}
type alias Quiz block inline =
    { elements : List block
    , options : Array (List inline)
    , solution : State
    }


{-| A gap-text without inputs, the inline parser `push`es the inputs.
-}
init : Quiz block inline
init =
    Quiz [] Array.empty Array.empty


{-| -}
isEmpty : Quiz block inline -> Bool
isEmpty quiz =
    Array.isEmpty quiz.options


{-| Add an input.
-}
push : Block.Quiz inline -> Quiz block inline -> Quiz block inline
push { options, solution } quiz =
    { quiz
        | options = Array.push options quiz.options
        , solution = Array.push solution quiz.solution
    }


{-| -}
initState : State -> State
initState =
    Array.map Block.initState


{-| Which inputs are correct, see `Block.comp`.
-}
comp2 : Quiz block inline -> State -> List Bool
comp2 quiz state =
    List.map2 Tuple.pair (Array.toList quiz.solution) (Array.toList state)
        |> List.indexedMap (\i ( solution, input ) -> Block.comp (Just i) (Block.Quiz [] solution) input)


{-| All inputs have to be correct.
-}
comp : Quiz block inline -> State -> Bool
comp quiz =
    comp2 quiz >> List.all identity


{-| -}
getClass : State -> String
getClass _ =
    "multi"
