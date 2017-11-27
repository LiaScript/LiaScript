module Lia.Code.Types exposing (Code(..), CodeElement, Codes)

import Array exposing (Array)
import Lia.Helper exposing (ID2)


type alias Codes =
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
    | Evaluate String ID2 (List String) -- Lang ID EvalString
