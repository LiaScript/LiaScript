module Lia.Utils exposing
    ( stringToHtml
    , string_replace
    , toJSstring
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []


string_replace : ( String, String ) -> String -> String
string_replace ( search, replace ) string =
    string
        |> String.split search
        |> String.join replace


toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"
