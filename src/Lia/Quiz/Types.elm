module Lia.Quiz.Types
    exposing
        ( Element
        , Hints
        , Quiz(..)
        , Solution(..)
        , State(..)
        , Vector
        )

import Array exposing (Array)
import Lia.Code.Types exposing (EvalString)
import Lia.Helper exposing (ID)
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
    | MultipleChoiceState (Array Bool)


type Quiz
    = Empty ID Hints (Maybe EvalString)
    | Text String ID Hints (Maybe EvalString)
    | SingleChoice Int MultInlines ID Hints (Maybe EvalString)
    | MultipleChoice (Array Bool) MultInlines ID Hints (Maybe EvalString)
