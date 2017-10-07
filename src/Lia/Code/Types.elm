module Lia.Code.Types exposing (Code(..), CodeElement, CodeVector)

import Array exposing (Array)


type alias CodeVector =
    Array CodeElement


type alias CodeElement =
    { code : String
    , result : Result String String
    , editing : Bool
    , running : Bool
    }


type Code
    = Highlight String String
    | EvalJS Int
