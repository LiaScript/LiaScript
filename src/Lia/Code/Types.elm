module Lia.Code.Types exposing (Code(..), CodeVector)

import Array exposing (Array)


type alias CodeVector =
    Array ( String, Maybe (Result String String), Bool )


type Code
    = Highlight String String
    | EvalJS Int
