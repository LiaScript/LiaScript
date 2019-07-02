module Lia.Markdown.Quiz.Types exposing
    ( Element
    , Hints
    , Quiz
    , Solution(..)
    , State(..)
    , Type(..)
    , Vector
    , comp
    , initState
    , solved
    , toState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (MultInlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.MultipleChoice.Types as MultipleChoice
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Types as MultipleChoiceMatrix
import Lia.Markdown.Quiz.SingleChoice.Types as SingleChoice
import Lia.Markdown.Quiz.SingleChoiceMatrix.Types as SingleChoiceMatrix


type alias Vector =
    Array Element


type alias Hints =
    MultInlines


type Solution
    = Open
    | Solved
    | ReSolved


type alias Element =
    { solved : Solution
    , state : State
    , trial : Int
    , hint : Int
    , error_msg : String
    }


type State
    = Empty_State
    | Block_State Block.State
    | SingleChoice_State SingleChoice.State
    | MultipleChoice_State MultipleChoice.State
    | SingleChoiceMatrix_State SingleChoiceMatrix.State
    | MultipleChoiceMatrix_State MultipleChoiceMatrix.State


type Type
    = Empty_Type
    | Block_Type Block.Quiz
    | SingleChoice_Type SingleChoice.Quiz
    | MultipleChoice_Type MultipleChoice.Quiz
    | SingleChoiceMatrix_Type SingleChoiceMatrix.Quiz
    | MultipleChoiceMatrix_Type MultipleChoiceMatrix.Quiz


type alias Quiz =
    { quiz : Type
    , id : Int
    , hints : Hints
    , javascript : Maybe String
    }


initState : Type -> State
initState quiz =
    case quiz of
        Empty_Type ->
            Empty_State

        Block_Type q ->
            q
                |> Block.initState
                |> Block_State

        SingleChoice_Type q ->
            q
                |> SingleChoice.initState
                |> SingleChoice_State

        MultipleChoice_Type q ->
            q
                |> MultipleChoice.initState
                |> MultipleChoice_State

        SingleChoiceMatrix_Type q ->
            q
                |> SingleChoiceMatrix.initState
                |> SingleChoiceMatrix_State

        MultipleChoiceMatrix_Type q ->
            q
                |> MultipleChoiceMatrix.initState
                |> MultipleChoiceMatrix_State


toState : Type -> State
toState quiz =
    case quiz of
        Empty_Type ->
            Empty_State

        Block_Type q ->
            Block_State q.solution

        SingleChoice_Type q ->
            SingleChoice_State q.solution

        MultipleChoice_Type q ->
            MultipleChoice_State q.solution

        SingleChoiceMatrix_Type q ->
            SingleChoiceMatrix_State q.solution

        MultipleChoiceMatrix_Type q ->
            MultipleChoiceMatrix_State q.solution


comp : Type -> State -> Solution
comp quiz state =
    if
        case ( quiz, state ) of
            ( Block_Type q, Block_State s ) ->
                Block.comp q s

            ( SingleChoice_Type q, SingleChoice_State s ) ->
                SingleChoice.comp q s

            ( MultipleChoice_Type q, MultipleChoice_State s ) ->
                MultipleChoice.comp q s

            ( SingleChoiceMatrix_Type q, SingleChoiceMatrix_State s ) ->
                SingleChoiceMatrix.comp q s

            ( MultipleChoiceMatrix_Type q, MultipleChoiceMatrix_State s ) ->
                MultipleChoiceMatrix.comp q s

            _ ->
                False
    then
        Solved

    else
        Open


solved : Element -> Bool
solved e =
    e.solved /= Open
