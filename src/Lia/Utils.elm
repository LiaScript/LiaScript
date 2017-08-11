module Lia.Utils exposing (highlight, mathjax)

--this is where we import the native module

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode
import Native.Utils


highlight : String -> String -> Html msg
highlight language code =
    let
        html =
            Native.Utils.highlight language code
                |> Json.Encode.string
    in
    Html.span [ Attr.property "innerHTML" html ] []


mathjax : a -> ()
mathjax s =
    let
        void =
            Native.Utils.mathjax ()
    in
    ()
