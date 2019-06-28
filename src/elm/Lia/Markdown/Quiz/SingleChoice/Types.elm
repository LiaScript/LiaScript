module Lia.Markdown.Quiz.SingleChoice.Types exposing
    ( Quiz
    , State
    , comp
    , initState
    )

import Lia.Markdown.Inline.Types exposing (Inlines)


type alias State =
    Int


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : Quiz -> State
initState _ =
    -1


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
