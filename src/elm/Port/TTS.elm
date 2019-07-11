module Port.TTS exposing
    ( Msg(..)
    , cancel
    , decode
    , event
    , speak
    )

import Json.Decode as JD
import Json.Encode as JE
import Port.Event as Event exposing (Event)


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


speak : Bool -> String -> String -> Event
speak loud voice text =
    [ voice
    , text
    , if loud then
        "true"

      else
        "false"
    ]
        |> JE.list JE.string
        |> Event "speak" -1
