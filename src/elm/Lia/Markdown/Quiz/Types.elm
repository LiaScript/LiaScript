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

{-| A quiz is split into its definition (`Quiz`, part of the parsed Markdown)
and its current state (`Element`), which is stored per section in a `Vector`.
The `id` of a quiz is its index within this vector.
-}

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Matrix.Types as Matrix
import Lia.Markdown.Quiz.Multi.Types as Multi
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Lia.Markdown.Quiz.Vector.Types as Vector


{-| The states of all quizzes of a section.
-}
type alias Vector =
    Array Element


{-| Hints (`[[?]]`), every hint is a list of blocks.
-}
type alias Hints x =
    List (List x)


{-| The state of a quiz:

  - `solved`: open, solved or resolved
  - `state`: the current input of the user
  - `trial`: the number of checks
  - `hint`: the number of revealed hints
  - `error_msg`: an error of the checking script
  - `scriptID`: the script that checks the quiz, instead of comparing it
    with the solution
  - `opt`: the options defined by the course
  - `partiallySolved`: which parts are correct, only with
    `data-show-partial-solution`
  - `deactivated`: a checking script is running, no further input

-}
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


{-| Options defined by the `data-*` attributes of a quiz:

  - `randomize`: the order of the options (`data-randomize`)
  - `maxTrials`: resolve the quiz after this many failed trials
    (`data-max-trials`)
  - `score`: shown in the classroom (`data-score`)
  - `showResolveAt` and `showHintsAt`: number of trials before the solution and
    the hint button appear (`data-solution-button`, `data-hint-button`)
  - `showPartialSolution`: mark the correct parts after a check
    (`data-show-partial-solution`)
  - `text_solved`, `text_failed`, `text_resolved`: custom feedback texts
    (`data-text-solved`, ...)

-}
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


{-| The current input of a quiz, per type:

  - `Generic_State`: no input, checked by a script or solved by the solution
    button (`[[!]]`)
  - `Block_State`: text input, selection, or drop
  - `Multi_State`: a gap-text with multiple inputs
  - `Vector_State`: single or multiple choice
  - `Matrix_State`: a matrix of single or multiple choice rows

-}
type State
    = Generic_State
    | Block_State Block.State
    | Multi_State Multi.State
    | Vector_State Vector.State
    | Matrix_State Matrix.State


{-| The definition of a quiz, including its solution.
-}
type Type x
    = Generic_Type
    | Block_Type (Block.Quiz Inlines)
    | Multi_Type (Multi.Quiz x Inlines)
    | Vector_Type (Vector.Quiz x)
    | Matrix_Type Matrix.Quiz


{-| A quiz as part of the Markdown, `id` refers to its `Element` in the
`Vector`.
-}
type alias Quiz x =
    { quiz : Type x
    , id : Int
    , hints : Hints x
    }


{-| The empty input of a quiz.
-}
initState : Type x -> State
initState =
    toState >> reset


{-| Clear the input.
-}
reset : State -> State
reset state =
    case state of
        Generic_State ->
            Generic_State

        Block_State s ->
            Block_State (Block.initState s)

        Multi_State s ->
            Multi_State (Multi.initState s)

        Vector_State s ->
            Vector_State (Vector.initState s)

        Matrix_State s ->
            Matrix_State (Matrix.initState s)


{-| The solution of a quiz as input.
-}
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


{-| Compare the input with the solution of a quiz. A generic quiz can only be
solved by a script.
-}
comp : Type x -> State -> Solution
comp quiz state =
    let
        correct =
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
    in
    if correct then
        Solution.Solved

    else
        Solution.Open


{-| Which parts of a gap-text or matrix quiz are correct, if `perform` is set
(`data-show-partial-solution`). Empty for other types.
-}
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


{-| The type of a quiz as class name, e.g. `single-choice`.
-}
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
