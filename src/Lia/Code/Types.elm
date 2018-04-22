module Lia.Code.Types exposing (Code(..), EvalString, File, Project, Vector)

import Array exposing (Array)
import Lia.Helper exposing (ID)


type alias Vector =
    Array Project


type alias Project =
    { file : Array File
    , version : Array ( Array String, Result String String )
    , evaluation : String
    , version_active : Int
    , result : Result String String
    , running : Bool
    }


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    }



--type alias Element =
--    { code : Array String
--  , version : Array ( Array String, Result String String )
--    , version_active : Int
--    , result : Result String String
--    , editing : Bool
--    , visible : Bool
--    , running : Bool
--    }


type alias EvalString =
    List String


type Code
    = Highlight (List ( String, String, String )) -- Lang Title Code
    | Evaluate ID --EvalString -- Lang Title ID EvalString
