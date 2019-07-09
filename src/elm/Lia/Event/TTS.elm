module Lia.Event.TTS exposing
    ( Msg(..)
    , backup
    , cancel
    , decode
    , event
    , speak
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Event.Base as Event exposing (Event)
import Lia.Utils exposing (toJSstring)


type Msg
    = Start
    | Stop
    | Error String


event : Bool -> Event
event on =
    (if on then
        "repeat"

     else
        "cancel"
    )
        |> JE.string
        |> Event "speak" -1
        |> Event.encode
        |> Event "effect" -1


decode : JD.Value -> Msg
decode json =
    case JD.decodeValue JD.string json of
        Ok "start" ->
            Start

        Ok "stop" ->
            Stop

        Ok msg ->
            Error msg

        Err msg ->
            Error <| JD.errorToString msg


cancel : Event.Event
cancel =
    "cancel"
        |> JE.string
        |> Event "speak" -1


speak : String -> String -> Event
speak voice text =
    [ voice, text ]
        |> JE.list JE.string
        |> Event "speak" -1


backup : String -> String -> Event
backup voice text =
    [ voice, text ]
        |> JE.list JE.string
        |> Event "backup" -1
