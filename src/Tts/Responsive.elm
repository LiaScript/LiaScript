module Tts.Responsive exposing (cancel, getVoices, speak, voiceSupport)

{-| A native Html5 Text-To-Speech wrapper library.


# Basic access

@docs voiceSupport, getVoices, speak, cancel

-}

import Json.Decode as Dec
import Native.Responsive
import Result exposing (Result)
import Task exposing (Task)


{-| -}
voiceSupport : () -> Bool
voiceSupport _ =
    Native.Responsive.voiceSupport ()


{-| -}
cancel : () -> Bool
cancel _ =
    case Native.Responsive.cancel () of
        Ok _ ->
            True

        Err _ ->
            False


{-| -}
getVoices : () -> Result String (List String)
getVoices _ =
    case Native.Responsive.getVoices () of
        Ok list ->
            Dec.decodeValue (Dec.list Dec.string) list

        Err msg ->
            Err msg


{-| -}
speak : (Result err ok -> msg) -> String -> String -> Cmd msg
speak resultToMessage voice text =
    Task.attempt resultToMessage (Native.Responsive.speak voice text)
