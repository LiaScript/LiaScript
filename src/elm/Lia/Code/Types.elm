module Lia.Code.Types exposing
    ( Code(..)
    , EventMsg
    , File
    , Log
    , Project
    , Vector
    , Version
    , log_append
    , message_append
    , noLog
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Terminal exposing (Terminal)


type alias Vector =
    Array Project


type alias EventMsg =
    List JE.Value


type alias Version =
    ( Array String, Log )


type alias Project =
    { file : Array File
    , version : Array Version
    , evaluation : String
    , version_active : Int
    , log : Log
    , running : Bool
    , terminal : Maybe Terminal
    }


noLog : Log
noLog =
    Log True "" Array.empty


type alias Log =
    { ok : Bool
    , message : String
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
    | Evaluate Int --EvalString -- Lang Title ID EvalString


log_append : Log -> Log -> Log
log_append old new =
    { new
        | message = append old.message new.message
        , details = Array.append old.details new.details
    }


message_append : String -> Log -> Log
message_append str log =
    { log | message = append log.message str }


append : String -> String -> String
append str1 str2 =
    let
        str =
            str1 ++ str2

        lines =
            String.lines str

        len =
            List.length lines
    in
    if len < 500 then
        str

    else
        lines
            |> List.drop (len - 500)
            |> List.intersperse "\n"
            |> String.concat
