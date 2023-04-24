module Lia.Markdown.Quiz.Block.Types exposing
    ( Quiz
    , State(..)
    , comp
    , getClass
    , initState
    )


type State
    = Text String
    | Select Bool (List Int)


type alias Quiz opt =
    { options : List opt
    , solution : State
    }


initState : State -> State
initState state =
    case state of
        Text _ ->
            Text ""

        Select _ _ ->
            Select False [ -1 ]


comp : Quiz opt -> State -> Bool
comp quiz state =
    case ( quiz.solution, state ) of
        ( Text str1, Text str2 ) ->
            str1 == str2

        ( Select _ list, Select _ [ i ] ) ->
            list
                |> List.filter ((==) i)
                |> List.isEmpty
                |> not

        _ ->
            False


getClass : State -> String
getClass state =
    case state of
        Text _ ->
            "text"

        Select _ _ ->
            "select"
