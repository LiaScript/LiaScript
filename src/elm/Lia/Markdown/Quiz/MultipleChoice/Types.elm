module Lia.Markdown.Quiz.MultipleChoice.Types exposing
    ( Quiz
    , State
    , comp
    , initState
    )

import Lia.Markdown.Inline.Types exposing (Inlines)


type alias State =
    List Bool


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : Quiz -> State
initState =
    .solution >> List.map (\_ -> False)


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
