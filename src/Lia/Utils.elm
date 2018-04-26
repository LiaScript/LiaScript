module Lia.Utils
    exposing
        ( evaluateJS
        , evaluateJS2
        , execute
        , formula
        , get_local
        , load_js
        , scrollIntoView
        , set_local
        , set_title
        , stringToHtml
        , string_replace
        , toUnixNewline
        )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Lia.Helper exposing (ID)
import Native.Utils
import Task exposing (attempt)


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


load_js : String -> Result String String
load_js url =
    Native.Utils.load_js url


evaluateJS2 : (Result err ok -> msg) -> ID -> String -> Cmd msg
evaluateJS2 resultToMessage idx code =
    code
        |> toJSstring
        |> Native.Utils.evaluate2 idx
        |> attempt resultToMessage


stringToHtml : String -> Html msg
stringToHtml str =
    Html.span [ Attr.property "innerHTML" (Json.Encode.string str) ] []


get_local : String -> Maybe String
get_local key =
    Native.Utils.get_local key


set_local : String -> a -> a
set_local key value =
    let
        unused =
            Native.Utils.set_local key (toString value)
    in
    value


toUnixNewline : String -> String
toUnixNewline code =
    Native.Utils.toUnixNewline code


set_title : String -> ()
set_title title =
    Native.Utils.set_title title


string_replace : String -> String -> String -> String
string_replace search replace string =
    Native.Utils.string_replace search replace string


scrollIntoView : String -> ()
scrollIntoView idx =
    Native.Utils.scrollIntoView idx


toJSstring : String -> String
toJSstring str =
    str |> String.split "\\" |> String.join "\\\\"
