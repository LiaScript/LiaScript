module Lia.Event.TTS exposing
    ( Msg(..)
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
    | Repeat
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
        |> Event.toJson
        |> Event "effect" -1


decode : JD.Value -> Msg
decode json =
    case JD.decodeValue JD.string json of
        Ok "start" ->
            Start

        Ok "stop" ->
            Stop

        Ok "repeat" ->
            Repeat

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
