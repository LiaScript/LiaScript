module Port.TTS exposing
    ( Msg(..)
    , cancel
    , decode
    , event
    , mute
    , playback
    , readFrom
    )

import Json.Decode as JD
import Json.Encode as JE
import Port.Event as Event exposing (Event)
import String


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
        |> Event.init "speak"
        |> Event.addTopic "effect"


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
        |> Event.init "speak"


playback : Int -> String -> String -> Event
playback id voice text =
    [ voice
    , text
    , "true"
    ]
        |> JE.list JE.string
        |> Event.initWithId "speak" id


readFrom : Int -> Int -> Event
readFrom id effectID =
    "lia-tts-"
        ++ String.fromInt effectID
        |> JE.string
        |> Event.initWithId "speak" id


mute : Int -> Event.Event
mute id =
    "cancel"
        |> JE.string
        |> Event.initWithId "speak" id
