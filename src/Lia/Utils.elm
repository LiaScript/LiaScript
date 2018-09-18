module Lia.Utils exposing
    ( evaluateJS
    , execute
    , formula
    , load
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


formula : Bool -> String -> Html msg
formula displayMode string =
    stringToHtml <| Native.Utils.formula displayMode string


evaluateJS : String -> Result String String
evaluateJS code =
    code
        |> toJSstring
        |> Native.Utils.evaluate


execute : Int -> String -> ()
execute delay code =
    code
        |> toJSstring
        |> Native.Utils.execute delay


load : String -> String -> Result String String
load elem url =
    Native.Utils.load elem url


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []


toUnixNewline : String -> String
toUnixNewline code =
    Native.Utils.toUnixNewline code


string_replace : ( String, String ) -> String -> String
string_replace ( search, replace ) string =
    Native.Utils.string_replace search replace string


scrollIntoView : String -> ()
scrollIntoView idx =
    Native.Utils.scrollIntoView idx


toJSstring : String -> String
toJSstring str =
    str |> String.split "\\" |> String.join "\\\\"
