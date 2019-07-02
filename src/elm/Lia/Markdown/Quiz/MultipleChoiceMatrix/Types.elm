module Lia.Markdown.Quiz.MultipleChoiceMatrix.Types exposing
    ( Quiz
    , State
    , comp
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias State =
    Array (Array Bool)


type alias Quiz =
    { headers : List Inlines
    , options : List Inlines
    , solution : State
    }


initState : Quiz -> State
initState =
    .solution >> Array.map (\row -> Array.map (\_ -> False) row)


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
