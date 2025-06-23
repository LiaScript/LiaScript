module Lia.Markdown.Quiz.Vector.Types exposing
    ( Quiz
    , State(..)
    , comp
    , getClass
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
            if List.any identity list1 then
                -- If the solution is not empty, check if one the selected option matches
                list2
                    |> List.map2 (\l1 l2 -> l1 && l2) list1
                    |> List.any identity

            else
                -- If the solution is empty, we check if all options are unselected
                List.all not list2

        -- If the solution is empty, we check if all options are unselected
        ( MultipleChoice list1, MultipleChoice list2 ) ->
            list1 == list2

        _ ->
            False


getClass : State -> String
getClass state =
    case state of
        SingleChoice _ ->
            "single-choice"

        MultipleChoice _ ->
            "multiple-choice"
