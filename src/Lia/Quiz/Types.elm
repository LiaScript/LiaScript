module Lia.Quiz.Types
    exposing
        ( Hints
        , Quiz(..)
        , QuizElement
        , QuizState(..)
        , QuizVector
        )

import Array exposing (Array)
import Lia.Inline.Types exposing (ID, Line)


type alias QuizVector =
    Array QuizElement


type alias Hints =
    List Line


type alias QuizElement =
    { solved : Bool
    , state : QuizState
    , hints : Int
    , trial : Int
    }


type QuizState
    = TextState String
    | SingleChoiceState Int
    | MultipleChoiceState (Array Bool)


type Quiz
    = Text String ID Hints
    | SingleChoice Int (List Line) ID Hints
    | MultipleChoice (Array Bool) (List Line) ID Hints
