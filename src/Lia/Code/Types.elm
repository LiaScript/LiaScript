module Lia.Code.Types exposing (Code(..), CodeElement, CodeVector)

import Array exposing (Array)
import Lia.Helper exposing (ID)


type alias CodeVector =
    Array CodeElement


type alias CodeElement =
    { code : String
    , version : Array String
    , version_active : Int
    , result : Result String String
    , editing : Bool
    , running : Bool
    }


type Code
    = Highlight String String -- Lang Code
    | Evaluate String ID (List String) -- Lang ID EvalString
