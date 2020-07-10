module Lia.Markdown.Quiz.Types exposing
    ( Element
    , Hints
    , Quiz
    , Solution(..)
    , State(..)
    , Type(..)
    , Vector
    , comp
    , getState
    , initState
    , solved
    , toState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (MultInlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Matrix.Types as Matrix
import Lia.Markdown.Quiz.Vector.Types as Vector


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
    = Generic_State
    | Block_State Block.State
    | Vector_State Vector.State
    | Matrix_State Matrix.State


type Type
    = Generic_Type
    | Block_Type Block.Quiz
    | Vector_Type Vector.Quiz
    | Matrix_Type Matrix.Quiz


type alias Quiz =
    { quiz : Type
    , id : Int
    , hints : Hints
    , javascript : Maybe String
    }


initState : Type -> State
initState quiz =
    case quiz of
        Generic_Type ->
            Generic_State

        Block_Type q ->
            q.solution
                |> Block.initState
                |> Block_State

        Vector_Type q ->
            q.solution
                |> Vector.initState
                |> Vector_State

        Matrix_Type q ->
            q.solution
                |> Matrix.initState
                |> Matrix_State


getState : Vector -> Int -> Maybe Element
getState vector idx =
    vector
        |> Array.get idx


toState : Type -> State
toState quiz =
    case quiz of
        Generic_Type ->
            Generic_State

        Block_Type q ->
            Block_State q.solution

        Vector_Type q ->
            Vector_State q.solution

        Matrix_Type q ->
            Matrix_State q.solution


comp : Type -> State -> Solution
comp quiz state =
    if
        case ( quiz, state ) of
            ( Block_Type q, Block_State s ) ->
                Block.comp q s

            ( Vector_Type q, Vector_State s ) ->
                Vector.comp q s

            ( Matrix_Type q, Matrix_State s ) ->
                Matrix.comp q s

            _ ->
                False
    then
        Solved

    else
        Open


solved : Element -> Bool
solved e =
    e.solved /= Open
