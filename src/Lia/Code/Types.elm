module Lia.Code.Types exposing
    ( Code(..)
    , EventMsg
    , File
    , Log
    , Project
    , Vector
    , Version
    , details_
    , log_
    , message_
    , message_update
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


message_update : String -> Result Log Log -> Result Log Log
message_update str rslt =
    case rslt of
        Ok log ->
            Ok (Log (append log.message str) log.details)

        Err log ->
            Err (Log (append log.message str) log.details)


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


message_ : Result Log Log -> String
message_ =
    log_ >> .message


details_ : Result Log Log -> Array JD.Value
details_ =
    log_ >> .details


log_ : Result Log Log -> Log
log_ rslt =
    case rslt of
        Ok log ->
            log

        Err log ->
            log


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
