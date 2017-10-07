module Lia.Utils exposing (evaluateJS, evaluateJS2, formula, highlight, load_js, stringToHtml)

--this is where we import the native module

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Native.Utils
import Task exposing (attempt)


highlight : String -> String -> Html msg
highlight language code =
    stringToHtml <| Native.Utils.highlight language code


formula : Bool -> String -> Html msg
formula displayMode string =
    stringToHtml <| Native.Utils.formula displayMode string


evaluateJS : String -> Result String String
evaluateJS code =
    Native.Utils.evaluate code


load_js : String -> Result String String
load_js url =
    Native.Utils.load_js url


evaluateJS2 : (Result err ok -> msg) -> Int -> String -> Cmd msg
evaluateJS2 resultToMessage idx code =
    attempt resultToMessage (Native.Utils.evaluate2 idx code)


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []
