module Lia.Code.Types
    exposing
        ( Code(..)
        , EvalString
        , File
        , Project
        , Rslt
        , Vector
        , noResult
        )

import Array exposing (Array)
import Json.Decode as JD
import Lia.Helper exposing (ID)


type alias Vector =
    Array Project


type alias Project =
    { file : Array File
    , version : Array ( Array String, Result Rslt Rslt )
    , evaluation : String
    , version_active : Int
    , result : Result Rslt Rslt
    , running : Bool
    }


noResult : Result Rslt Rslt
noResult =
    Ok
        { message = ""
        , details = Array.empty
        }


type alias Rslt =
    { message : String
    , details : Array JD.Value
    }


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    }


type alias EvalString =
    List String


type Code
    = Highlight (List ( String, String, String )) -- Lang Title Code
    | Evaluate ID --EvalString -- Lang Title ID EvalString
