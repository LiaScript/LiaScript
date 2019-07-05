module Lia.Markdown.Quiz.Vector.Types exposing
    ( Quiz
    , State(..)
    , comp
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type State
    = SingleChoice Int (List Int)
    | MultipleChoice (Array Bool)


type alias Quiz =
    { options : List Inlines
    , solution : State
    }


initState : State -> State
initState state =
    case state of
        SingleChoice length _ ->
            SingleChoice length [ -1 ]

        MultipleChoice array ->
            array
                |> Array.map (\_ -> False)
                |> MultipleChoice


comp : Quiz -> State -> Bool
comp quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _ solution, SingleChoice _ [ i ] ) ->
            solution
                |> List.filter ((==) i)
                |> List.isEmpty
                |> not

        ( MultipleChoice a1, MultipleChoice a2 ) ->
            a1 == a2

        _ ->
            False
