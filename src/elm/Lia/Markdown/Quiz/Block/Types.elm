module Lia.Markdown.Quiz.Block.Types exposing
    ( Quiz
    , State(..)
    , comp
    , getClass
    , initState
    )

{-| The input of a block quiz:

  - `Text`: the text of an input field
  - `Select`: whether the dropdown is open and the selected option
  - `Drop`: whether the drop zone is highlighted, whether an option is being
    dragged and the dropped option (gap-texts store `[ input, option ]`)

As solution, `Select` and `Drop` contain all correct options.

-}


type State
    = Text String
    | Select Bool (List Int)
    | Drop Bool Bool (List Int)


{-| -}
type alias Quiz opt =
    { options : List opt
    , solution : State
    }


{-| Nothing entered or selected.
-}
initState : State -> State
initState state =
    case state of
        Text _ ->
            Text ""

        Select _ _ ->
            Select False [ -1 ]

        Drop _ _ _ ->
            Drop False False []


{-| Compare the input with the solution. Within a gap-text (`id` is the index of
the input), a dropped option is only correct if it was dropped onto this input.
-}
comp : Maybe Int -> Quiz opt -> State -> Bool
comp id quiz state =
    case ( id, quiz.solution, state ) of
        ( _, Text str1, Text str2 ) ->
            str1 == str2

        ( _, Select _ list, Select _ [ i ] ) ->
            List.member i list

        ( Nothing, Drop _ _ list, Drop _ _ [ i ] ) ->
            List.member i list

        ( Just i, Drop _ _ list, Drop _ _ [ j, k ] ) ->
            i == j && List.member k list

        _ ->
            False


{-| -}
getClass : State -> String
getClass state =
    case state of
        Text _ ->
            "text"

        Select _ _ ->
            "select"

        Drop _ _ _ ->
            "drop"
