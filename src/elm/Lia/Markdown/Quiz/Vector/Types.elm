module Lia.Markdown.Quiz.Vector.Types exposing
    ( Quiz
    , State(..)
    , comp
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type State
    = SingleChoice Int Int
    | MultipleChoice (Array Bool)


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : State -> State
initState state =
    case state of
        SingleChoice length _ ->
            SingleChoice length -1

        MultipleChoice array ->
            array
                |> Array.map (\_ -> False)
                |> MultipleChoice


comp : Quiz -> State -> Bool
comp quiz state =
    quiz.solution == state
