module Lia.Markdown.Quiz.SingleChoiceMatrix.Types exposing
    ( Quiz
    , State
    , comp
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias State =
    Array Int


type alias Quiz =
    { headers : List Inlines
    , size : Int
    , options : List Inlines
    , solution : State
    }


initState : Quiz -> State
initState =
    .solution >> Array.map (\_ -> -1)


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
