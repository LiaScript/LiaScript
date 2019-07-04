module Lia.Markdown.Quiz.Matrix.Types exposing
    ( Quiz
    , State
    , comp
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Vector.Types as Vector


type alias State =
    Array Vector.State


type alias Quiz =
    { headers : List Inlines
    , options : List Inlines
    , solution : State
    }


initState : State -> State
initState =
    Array.map Vector.initState


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
