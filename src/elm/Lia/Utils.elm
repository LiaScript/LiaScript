module Lia.Utils exposing
    ( evaluateJS
    , scrollIntoView
    , stringToHtml
    , string_replace
    , toJSstring
    , toUnixNewline
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Native.Utils


evaluateJS : String -> Result String String
evaluateJS code =
    code
        |> toJSstring
        |> Native.Utils.evaluate


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []


toUnixNewline : String -> String
toUnixNewline code =
    Native.Utils.toUnixNewline code


string_replace : ( String, String ) -> String -> String
string_replace ( search, replace ) string =
    string
        |> String.split search
        |> String.join replace


scrollIntoView : String -> ()
scrollIntoView idx =
    Native.Utils.scrollIntoView idx


toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"
