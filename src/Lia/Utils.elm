module Lia.Utils exposing (formula, highlight)

--this is where we import the native module

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Native.Utils


highlight : String -> String -> Html msg
highlight language code =
    toHtml <| Native.Utils.highlight language code


formula : Bool -> String -> Html msg
formula displayMode string =
    toHtml <| Native.Utils.formula displayMode string


toHtml : String -> Html msg
toHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []
