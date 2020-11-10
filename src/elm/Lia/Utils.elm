module Lia.Utils exposing
    ( blockKeydown
    , get
    , onEnter
    , toEscapeString
    , toJSstring
    )

import Html
import Html.Events as Events
import Json.Decode as JD



{-
   string_replace : ( String, String ) -> String -> String
   string_replace ( search, replace ) string =
       string
           |> String.split search
           |> String.join replace
-}


toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"


toEscapeString : String -> String
toEscapeString str =
    str
        |> String.replace "\"" "\\\""
        |> String.replace "'" "\\'"
        |> String.replace "`" "\\`"
        |> String.replace "\n" "\\n"


blockKeydown : msg -> Html.Attribute msg
blockKeydown =
    stopPropagationOn "keydown"


stopPropagationOn : String -> msg -> Html.Attribute msg
stopPropagationOn name msg =
    Events.stopPropagationOn name (JD.succeed ( msg, True ))


get : Int -> List x -> Maybe x
get i list =
    case list of
        [] ->
            Nothing

        r :: rs ->
            if i <= 0 then
                Just r

            else
                get (i - 1) rs


isEnter : msg -> Int -> JD.Decoder msg
isEnter msg code =
    if code == 13 then
        JD.succeed msg

    else
        JD.fail "not ENTER"


onEnter : msg -> Html.Attribute msg
onEnter msg =
    JD.andThen (isEnter msg) Events.keyCode
        |> Events.on "keyup"
