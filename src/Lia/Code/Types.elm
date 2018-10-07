module Lia.Code.Types exposing
    ( Code(..)
    , EventMsg
    , File
    , Log
    , Project
    , Vector
    , Version
    , noResult
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Terminal exposing (Terminal)
import Lia.Helper exposing (ID)


type alias Vector =
    Array Project


type alias EventMsg =
    List JE.Value


type alias Version =
    ( Array String, Result Log Log )


type alias Project =
    { file : Array File
    , version : Array Version
    , evaluation : String
    , version_active : Int
    , result : Result Log Log
    , running : Bool
    , terminal : Maybe Terminal
    }


noResult : Result Log Log
noResult =
    Ok
        { message = ""
        , details = Array.empty
        }


type alias Log =
    { message : String
    , details : Array JD.Value
    }


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    , fullscreen : Bool
    }


type Code
    = Highlight (List ( String, String, String )) -- Lang Title Code
    | Evaluate ID --EvalString -- Lang Title ID EvalString
