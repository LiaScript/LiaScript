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
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
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
    = Empty
    | Block Block.Quiz
    | SingleChoice SingleChoice.Quiz
    | MultipleChoice MultipleChoice.Quiz


type alias Quiz =
    { quiz : Type
    , id : Int
    , hints : Hints
    , javascript : Maybe String
    }


initState : Type -> State
initState quiz =
    case quiz of
        Empty ->
            Empty_State

        Block b ->
            b
                |> Block.initState
                |> Block_State

        SingleChoice s ->
            s
                |> SingleChoice.initState
                |> SingleChoice_State

        MultipleChoice m ->
            m
                |> MultipleChoice.initState
                |> MultipleChoice_State


toState : Type -> State
toState quiz =
    case quiz of
        Empty ->
            Empty_State

        Block b ->
            Block_State b.solution

        SingleChoice s ->
            SingleChoice_State s.solution

        MultipleChoice m ->
            MultipleChoice_State m.solution


comp : Type -> State -> Solution
comp quiz state =
    if
        case ( quiz, state ) of
            ( Block q, Block_State s ) ->
                Block.comp q s

            ( SingleChoice q, SingleChoice_State s ) ->
                SingleChoice.comp q s

            ( MultipleChoice q, MultipleChoice_State s ) ->
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
