module Lia.Code.Types exposing (Code(..), Element, Vector)

import Array exposing (Array)
import Lia.Helper exposing (ID)


type alias Vector =
    Array Element


type alias Element =
    { code : String
    , version : Array ( String, Result String String )
    , version_active : Int
    , result : Result String String
    , editing : Bool
    , running : Bool
    }


type Code
    = Highlight String String -- Lang Code
    | Evaluate String ID (List String) -- Lang ID EvalString
