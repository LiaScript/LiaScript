module Lia.Markdown.Code.Types exposing
    ( Code(..)
    , EventMsg
    , File
    , Project
    , Snippet
    , Vector
    , Version
    , log_append
    , message_append
    , noLog
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event as Event
import Lia.Markdown.Code.Terminal exposing (Terminal)


type alias Vector =
    Array Project


type alias EventMsg =
    List JE.Value


type alias Version =
    ( Array String, Event.Eval )


type alias Project =
    { file : Array File
    , version : Array Version
    , evaluation : String
    , version_active : Int
    , log : Event.Eval
    , running : Bool
    , terminal : Maybe Terminal
    }


noLog : Event.Eval
noLog =
    Event.Eval True "" []


type alias File =
    { lang : String
    , name : String
    , code : String
    , visible : Bool
    , fullscreen : Bool
    }


type alias Snippet =
    { lang : String
    , name : String
    , code : String
    }


type Code
    = Highlight (List Snippet)
    | Evaluate Int


log_append : Event.Eval -> Event.Eval -> Event.Eval
log_append old new =
    { new
        | result = append old.result new.result
        , details = List.append old.details new.details
    }


message_append : String -> Event.Eval -> Event.Eval
message_append str log =
    { log | result = append log.result str }


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
