module Lia.Quiz.Type
    exposing
        ( Quiz(..)
        , QuizBlock
        , QuizElement
        , QuizState(..)
        , QuizVector
        )

import Array exposing (Array)
import Lia.Inline.Type exposing (Inline)


type alias QuizVector =
    Array QuizElement


type alias QuizElement =
    { solved : Maybe Bool
    , state : QuizState
    , trial : Int
    , hint : Int
    }


type QuizState
    = Single Int Int
    | Multi (Array ( Bool, Bool ))
    | Text String String


type Quiz
    = SingleChoice Int (List (List Inline))
    | MultipleChoice (List ( Bool, List Inline ))
    | TextInput String


type alias QuizBlock =
    { quiz : Quiz
    , idx : Int
    , hints : List (List Inline)
    }
