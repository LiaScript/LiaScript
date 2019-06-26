module Lia.Markdown.Quiz.Block.Types exposing
    ( Quiz
    , State(..)
    , comp
    , initState
    )

import Lia.Markdown.Inline.Types exposing (Inlines)


type State
    = Text String
    | Select Bool Int


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : Quiz -> State
initState quiz =
    case quiz.solution of
        Text _ ->
            Text ""

        Select _ _ ->
            Select False -1


comp : Quiz -> State -> Bool
comp quiz state =
    case ( quiz.solution, state ) of
        ( Text str1, Text str2 ) ->
            str1 == str2

        ( Select _ i1, Select _ i2 ) ->
            i1 == i2

        _ ->
            False
