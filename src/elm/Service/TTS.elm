module Service.TTS exposing
    ( Msg(..)
    , abort
    , cancel
    , decode
    , playback
    , preferBrowser
    , readFrom
    )

import Json.Decode as JD
import Json.Encode as JE
import Service.Event as Event exposing (Event)
import String


type Msg
    = Start
    | Stop
    | Error String
    | BrowserTTS Bool
    | ResponsiveVoiceTTS Bool


{-| Simple abort of any talking without sending a response
-}
abort : Event
abort =
    cancel
        |> Event.withNoReply


{-| Like abort, but a response is send to the sending module
-}
cancel : Event
cancel =
    event "cancel" JE.null


{-| Read the content from a specific HTML element, which is marked with
`id="lia-tts-{number}"`. The number is passed as the id and represents the
current animation step. The additional meta data such as language and voice
have to be added to the HTML element as attributes:

  - `data-voice`
  - `data-lang`

-}
readFrom : Int -> Event
readFrom id =
    "lia-tts-"
        ++ String.fromInt id
        |> JE.string
        |> event "read"


{-| Used for inline playback, the text and the voice can be passed as
parameters...
-}
playback : { voice : String, lang : String, text : String } -> Event
playback { voice, lang, text } =
    [ ( "voice", JE.string voice )
    , ( "lang", JE.string lang )
    , ( "text", JE.string text )
    ]
        |> JE.object
        |> event "playback"


{-| Switch tts
-}
preferBrowser : Bool -> Event
preferBrowser =
    JE.bool >> event "preferBrowserTTS"


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

                "browserTTS" ->
                    case JD.decodeValue JD.bool e.message.param of
                        Ok support ->
                            BrowserTTS support

                        Err _ ->
                            BrowserTTS False

                "responsiveVoiceTTS" ->
                    case JD.decodeValue JD.bool e.message.param of
                        Ok support ->
                            ResponsiveVoiceTTS support

                        Err _ ->
                            ResponsiveVoiceTTS False

                unknown ->
                    Error <| "unknown cmd => " ++ unknown

        _ ->
            Error <| "Wrong Service -> " ++ e.service


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Slide.ts`.
-}
event : String -> JE.Value -> Event
event cmd message =
    Event.init "tts" { cmd = cmd, param = message }
