module Lia.Markdown.Quiz.Vector.Types exposing
    ( Quiz
    , State(..)
    , comp
    , initState
    )

import Lia.Markdown.Inline.Types exposing (Inlines)


type State
    = SingleChoice (List Bool)
    | MultipleChoice (List Bool)


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : State -> State
initState state =
    case state of
        SingleChoice list ->
            list
                |> List.map (\_ -> False)
                |> SingleChoice

        MultipleChoice list ->
            list
                |> List.map (\_ -> False)
                |> MultipleChoice


comp : Quiz -> State -> Bool
comp quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice list1, SingleChoice list2 ) ->
            List.map2 (\l1 l2 -> l1 == True && l2 == True) list1 list2
                |> List.any identity

        ( MultipleChoice list1, MultipleChoice list2 ) ->
            list1 == list2

        _ ->
            False
