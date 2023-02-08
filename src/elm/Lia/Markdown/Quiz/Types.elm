module Lia.Markdown.Quiz.Types exposing
    ( Element
    , Hints
    , Quiz
    , State(..)
    , Type(..)
    , Vector
    , comp
    , getClass
    , initState
    , isSolved
    , toState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Matrix.Types as Matrix
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Lia.Markdown.Quiz.Vector.Types as Vector


type alias Vector =
    Array Element


type alias Hints =
    List Inlines


type alias Element =
    { solved : Solution
    , state : State
    , trial : Int
    , hint : Int
    , error_msg : String
    , scriptID : Maybe Int
    , randomize : Maybe (List Int)
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
        Solution.Solved

    else
        Solution.Open


{-| Returns `True` if the quiz is in solved or resolved state.
-}
isSolved : Element -> Bool
isSolved e =
    e.solved /= Solution.Open


getClass : State -> String
getClass state =
    case state of
        Block_State s ->
            Block.getClass s

        Vector_State s ->
            Vector.getClass s

        Matrix_State s ->
            Matrix.getClass s

        Generic_State ->
            "generic"
