module Lia.Utils exposing
    ( string_replace
    , toJSstring
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode


string_replace : ( String, String ) -> String -> String
string_replace ( search, replace ) string =
    string
        |> String.split search
        |> String.join replace


toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"
