module Lia.Utils exposing
    ( blockKeydown
    , stopPropagationOn
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
