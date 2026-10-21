module Lia.Markdown.Quiz.Matrix.Types exposing
    ( Quiz
    , State
    , comp
    , comp2
    , getClass
    , initState
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Vector.Types as Vector


{-| One single or multiple choice per row.
-}
type alias State =
    Array Vector.State


{-| The column `headers`, the row `options` and the solution.
-}
type alias Quiz =
    { headers : List Inlines
    , options : List Inlines
    , solution : State
    }


{-| Nothing selected.
-}
initState : State -> State
initState =
    Array.map Vector.initState


{-| All rows have to be correct.
-}
comp : Quiz -> State -> Bool
comp quiz state =
    comp2 quiz state
        |> List.all identity


{-| Which rows are correct, see `Vector.comp`.
-}
comp2 : Quiz -> State -> List Bool
comp2 quiz state =
    List.map2 (Vector.Quiz [] >> Vector.comp)
        (Array.toList quiz.solution)
        (Array.toList state)


{-| -}
getClass : State -> String
getClass _ =
    "matrix"
