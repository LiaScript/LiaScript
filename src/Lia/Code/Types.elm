module Lia.Code.Types exposing (Code(..), Element, EvalString, Vector)

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


type alias EvalString =
    List String


type Code
    = Highlight String String -- Lang Code
    | Evaluate String ID EvalString -- Lang ID EvalString
