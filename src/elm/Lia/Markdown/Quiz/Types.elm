module Lia.Markdown.Quiz.Types exposing
    ( Element
    , Hints
    , Quiz(..)
    , QuizAdds(..)
    , Solution(..)
    , State(..)
    , Vector
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (MultInlines)


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
    | SelectionState Int
    | SingleChoiceState Int
    | MultipleChoiceState (List Bool)


type Quiz
    = Empty QuizAdds
    | Text String QuizAdds
    | Selection Int (List String) QuizAdds
    | SingleChoice Int MultInlines QuizAdds
    | MultipleChoice (List Bool) MultInlines QuizAdds


type QuizAdds
    = QuizAdds Int Hints (Maybe String)
