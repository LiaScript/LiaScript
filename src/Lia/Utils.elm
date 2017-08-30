module Lia.Utils exposing (evaluateJS, formula, highlight, stringToHtml)

--this is where we import the native module

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Native.Utils


highlight : String -> String -> Html msg
highlight language code =
    stringToHtml <| Native.Utils.highlight language code


formula : Bool -> String -> Html msg
formula displayMode string =
    stringToHtml <| Native.Utils.formula displayMode string


evaluateJS : String -> Result String String
evaluateJS code =
    Native.Utils.evaluate code


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []
