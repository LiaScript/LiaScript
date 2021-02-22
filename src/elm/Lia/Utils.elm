module Lia.Utils exposing
    ( blockKeydown
    , get
    , langToString
    , onEnter
    , toEscapeString
    , toJSstring
    )

import Html
import Html.Events as Events
import Json.Decode as JD
import Translations exposing (Lang(..))


{-| Convert JavaScript string escapes for backspace to elm escaped strings:

    toJSstring "javascript \\ escape" == "javascript \\\\ escape"

-}
toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"


{-| Convert common JavaScript string escapes elm escapes:

    toEscapeString "javascript \" \n" == "javascript \\\" \\n"

-}
toEscapeString : String -> String
toEscapeString str =
    str
        |> String.replace "\"" "\\\""
        |> String.replace "'" "\\'"
        |> String.replace "`" "\\`"
        |> String.replace "\n" "\\n"


{-| Avoid event bubbling. Especially key-press left or right should be handled
by some elements itself and not result in a section-switch. Thus, on global
scale the left and right arrow keys should be used in slide-navigation, but
locally it must be surpressed in text inputs, search fields, etc.
-}
blockKeydown : msg -> Html.Attribute msg
blockKeydown =
    stopPropagationOn "keydown"


stopPropagationOn : String -> msg -> Html.Attribute msg
stopPropagationOn name msg =
    Events.stopPropagationOn name (JD.succeed ( msg, True ))


{-| Get the ith element of a list:

    get 2 [ 1, 2, 3, 4, 5 ] == Just 3

-}
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


{-| Release a message if the user hits enter.
-}
onEnter : msg -> Html.Attribute msg
onEnter msg =
    JD.andThen (isEnter msg) Events.keyCode
        |> Events.on "keyup"


{-| Convenience function that returns the appropriate language string from the
given code.
-}
langToString : Lang -> String
langToString code =
    case code of
        Bg ->
            "bg"

        De ->
            "de"

        En ->
            "en"

        Es ->
            "es"

        Fa ->
            "fa"

        Hy ->
            "hy"

        Nl ->
            "nl"

        Ru ->
            "ru"

        Tw ->
            "tw"

        Ua ->
            "ua"

        Zh ->
            "zh"
