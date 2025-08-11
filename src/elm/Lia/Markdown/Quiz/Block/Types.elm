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
    | Drop Bool Bool (List Int)


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

        Drop _ _ _ ->
            Drop False False []


comp : Maybe Int -> Quiz opt -> State -> Bool
comp id quiz state =
    case ( id, quiz.solution, state ) of
        ( _, Text str1, Text str2 ) ->
            str1 == str2

        ( _, Select _ list, Select _ [ i ] ) ->
            list
                |> List.filter ((==) i)
                |> List.isEmpty
                |> not

        ( Nothing, Drop _ _ list, Drop _ _ [ i ] ) ->
            list
                |> List.filter ((==) i)
                |> List.isEmpty
                |> not

        ( Just i, Drop _ _ list, Drop _ _ [ j, k ] ) ->
            if i == j then
                list
                    |> List.filter ((==) k)
                    |> List.isEmpty
                    |> not

            else
                False

        _ ->
            False


getClass : State -> String
getClass state =
    case state of
        Text _ ->
            "text"

        Select _ _ ->
            "select"

        Drop _ _ _ ->
            "drop"
