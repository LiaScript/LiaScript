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
import Lia.Markdown.Quiz.SingleChoice.Types as SingleChoice


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


type Type
    = Empty_Type
    | Block_Type Block.Quiz
    | SingleChoice_Type SingleChoice.Quiz
    | MultipleChoice_Type MultipleChoice.Quiz


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

        Block_Type b ->
            b
                |> Block.initState
                |> Block_State

        SingleChoice_Type s ->
            s
                |> SingleChoice.initState
                |> SingleChoice_State

        MultipleChoice_Type m ->
            m
                |> MultipleChoice.initState
                |> MultipleChoice_State


toState : Type -> State
toState quiz =
    case quiz of
        Empty_Type ->
            Empty_State

        Block_Type b ->
            Block_State b.solution

        SingleChoice_Type s ->
            SingleChoice_State s.solution

        MultipleChoice_Type m ->
            MultipleChoice_State m.solution


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

            _ ->
                False
    then
        Solved

    else
        Open


solved : Element -> Bool
solved e =
    e.solved /= Open
