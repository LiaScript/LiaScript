module Lia.Markdown.Quiz.Types exposing
    ( Element
    , Hints
    , Options
    , Quiz
    , State(..)
    , Type(..)
    , Vector
    , comp
    , comp2
    , getClass
    , initState
    , isSolved
    , reset
    , toState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Matrix.Types as Matrix
import Lia.Markdown.Quiz.Multi.Types as Multi
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
    , opt : Options
    , partiallySolved : Array Bool
    , deactivated : Bool
    }


type alias Options =
    { randomize : Maybe (List Int)
    , maxTrials : Maybe Int
    , score : Maybe Float
    , showResolveAt : Int
    , showHintsAt : Int
    , showPartialSolution : Bool
    , text_solved : Maybe Inlines
    , text_failed : Maybe Inlines
    , text_resolved : Maybe Inlines
    }


type State
    = Generic_State
    | Block_State Block.State
    | Multi_State Multi.State
    | Vector_State Vector.State
    | Matrix_State Matrix.State


type Type x
    = Generic_Type
    | Block_Type (Block.Quiz Inlines)
    | Multi_Type (Multi.Quiz x Inlines)
    | Vector_Type Vector.Quiz
    | Matrix_Type Matrix.Quiz


type alias Quiz x =
    { quiz : Type x
    , id : Int
    , hints : Hints
    }


initState : Type x -> State
initState quiz =
    case quiz of
        Generic_Type ->
            Generic_State

        Block_Type q ->
            q.solution
                |> Block.initState
                |> Block_State

        Multi_Type q ->
            q.solution
                |> Multi.initState
                |> Multi_State

        Vector_Type q ->
            q.solution
                |> Vector.initState
                |> Vector_State

        Matrix_Type q ->
            q.solution
                |> Matrix.initState
                |> Matrix_State


reset : State -> State
reset state =
    case state of
        Block_State s ->
            s
                |> Block.initState
                |> Block_State

        Multi_State s ->
            s
                |> Multi.initState
                |> Multi_State

        Vector_State s ->
            s
                |> Vector.initState
                |> Vector_State

        Matrix_State s ->
            s
                |> Matrix.initState
                |> Matrix_State

        _ ->
            state


toState : Type x -> State
toState quiz =
    case quiz of
        Generic_Type ->
            Generic_State

        Block_Type q ->
            Block_State q.solution

        Multi_Type q ->
            Multi_State q.solution

        Vector_Type q ->
            Vector_State q.solution

        Matrix_Type q ->
            Matrix_State q.solution


comp : Type x -> State -> Solution
comp quiz state =
    if
        case ( quiz, state ) of
            ( Block_Type q, Block_State s ) ->
                Block.comp Nothing q s

            ( Multi_Type q, Multi_State s ) ->
                Multi.comp q s

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


comp2 : Bool -> Type x -> State -> Array Bool
comp2 perform quiz state =
    if perform then
        Array.fromList <|
            case ( quiz, state ) of
                ( Multi_Type q, Multi_State s ) ->
                    Multi.comp2 q s

                ( Matrix_Type q, Matrix_State s ) ->
                    Matrix.comp2 q s

                _ ->
                    []

    else
        Array.empty


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

        Multi_State s ->
            Multi.getClass s

        Vector_State s ->
            Vector.getClass s

        Matrix_State s ->
            Matrix.getClass s

        Generic_State ->
            "generic"
