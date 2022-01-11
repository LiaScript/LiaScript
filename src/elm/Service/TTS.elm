module Service.TTS exposing
    ( Msg(..)
    , cancel
    , decode
    , playback
    , readFrom
    , repeat
    )

import Json.Decode as JD
import Json.Encode as JE
import Service.Event as Event exposing (Event)
import String


type Msg
    = Start
    | Stop
    | Error String


repeat : Event
repeat =
    event "repeat" JE.null


decode : Event -> Msg
decode e =
    case e.service of
        "tts" ->
            case e.message.cmd of
                "start" ->
                    Start

                "stop" ->
                    Stop

                "error" ->
                    case JD.decodeValue JD.string e.message.param of
                        Ok msg ->
                            Error msg

                        Err msg ->
                            Error <| JD.errorToString msg

                unknown ->
                    Error <| "unknown cmd => " ++ unknown

        _ ->
            Error <| "Wrong Service -> " ++ e.service


playback : String -> String -> Event
playback voice text =
    [ ( "voice", JE.string voice )
    , ( "text", JE.string text )
    ]
        |> JE.object
        |> event "playback"


readFrom : Int -> Event
readFrom id =
    "lia-tts-"
        ++ String.fromInt id
        |> JE.string
        |> event "read"


cancel : Event
cancel =
    event "cancel" JE.null


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Slide.ts`.
-}
event : String -> JE.Value -> Event
event cmd message =
    Event.init "tts" { cmd = cmd, param = message }
