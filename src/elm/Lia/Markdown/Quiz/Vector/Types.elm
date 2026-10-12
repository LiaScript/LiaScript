module Lia.Markdown.Quiz.Vector.Types exposing
    ( Quiz
    , State(..)
    , comp
    , getClass
    , initState
    )

{-| One boolean per option, `True` if selected.
-}


type State
    = SingleChoice (List Bool)
    | MultipleChoice (List Bool)


{-| The options (each a list of blocks) and the solution.
-}
type alias Quiz body =
    { options : List (List body)
    , solution : State
    }


{-| Nothing selected.
-}
initState : State -> State
initState state =
    case state of
        SingleChoice list ->
            SingleChoice (List.map (always False) list)

        MultipleChoice list ->
            MultipleChoice (List.map (always False) list)


{-| A single choice is correct if one of the correct options is selected, or
nothing if no option is correct. A multiple choice must match exactly.
-}
comp : Quiz body -> State -> Bool
comp quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice list1, SingleChoice list2 ) ->
            if List.any identity list1 then
                -- If the solution is not empty, check if one the selected option matches
                List.map2 (&&) list1 list2
                    |> List.any identity

            else
                -- If the solution is empty, we check if all options are unselected
                List.all not list2

        ( MultipleChoice list1, MultipleChoice list2 ) ->
            list1 == list2

        _ ->
            False


{-| -}
getClass : State -> String
getClass state =
    case state of
        SingleChoice _ ->
            "single-choice"

        MultipleChoice _ ->
            "multiple-choice"
