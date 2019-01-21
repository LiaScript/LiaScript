module Lia.Quiz.Types exposing
    ( Element
    , Hints
    , Quiz(..)
    , Solution(..)
    , State(..)
    , Vector
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


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
    = EmptyState
    | TextState String
    | SingleChoiceState Int
    | MultipleChoiceState (List Bool)


type Quiz
    = Empty Int Hints (Maybe String)
    | Text String Int Hints (Maybe String)
    | SingleChoice Int MultInlines Int Hints (Maybe String)
    | MultipleChoice (List Bool) MultInlines Int Hints (Maybe String)


type alias QuizAdd =
    { idx : Int, hints : Hints, eval_string : Maybe String }
