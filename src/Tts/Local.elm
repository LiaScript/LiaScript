module Tts.Local exposing (languages, listen, shut_up, speak, voices)

{-| A native Html5 Text-To-Speech wrapper library.


# Basic access

@docs speak, voices, languages, listen

-}

import Json.Decode as Dec
import Json.Encode as Enc
import Native.Tts
import Result exposing (Result)
import Task


{-| -}
type alias Recognition =
    { confidence : Float
    , transcript : String
    }


{-| -}
speak : (Result err ok -> msg) -> Maybe String -> String -> String -> Cmd msg
speak resultToMessage voice lang text =
    let
        v =
            case voice of
                Just str ->
                    Enc.string str

                Nothing ->
                    Enc.null
    in
    Task.attempt resultToMessage (Native.Tts.speak v lang text)


{-| -}
listen : (Result String String -> msg) -> Bool -> Bool -> String -> Cmd msg
listen resultToMessage continous interimResults lang =
    Task.attempt resultToMessage (Native.Tts.listen continous interimResults lang)


shut_up : Bool -> Bool
shut_up x =
    if x then
        let
            t =
                Native.Tts.shut_up ()
        in
        True
    else
        True


{-| -}
voices : Result String (List String)
voices =
    decode_string_list (Native.Tts.voices ())


{-| -}
languages : Result String (List String)
languages =
    decode_string_list (Native.Tts.languages ())


decode_string_list : Result String Enc.Value -> Result String (List String)
decode_string_list result =
    case result of
        Ok list ->
            Dec.decodeValue (Dec.list Dec.string) list

        Err msg ->
            Err msg
