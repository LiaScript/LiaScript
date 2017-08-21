module Lia.Quiz.Type
    exposing
        ( QuizElement
        , QuizState(..)
        , QuizVector
        )

import Array exposing (Array)


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
