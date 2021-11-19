module Lia.Sync.Via exposing
    ( Backend(..)
    , fromString
    , icon
    , toString
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Utils as Util


type Backend
    = Beaker
    | Matrix
    | Jitsi


toString : Backend -> String
toString via =
    case via of
        Beaker ->
            "Beaker"

        Matrix ->
            "Matrix"

        Jitsi ->
            "JitSi"


icon : Backend -> Html msg
icon via =
    Util.icon
        (case via of
            Beaker ->
                "icon-beaker icon-xs"

            Matrix ->
                "icon-matrix icon-xs"

            Jitsi ->
                "icon-jitsi icon-xs"
        )
        [ Attr.style "padding-right" "5px"
        , Attr.style "font-size" "inherit"
        ]


fromString : String -> Maybe Backend
fromString via =
    case String.toLower via of
        "beaker" ->
            Just Beaker

        "matrix" ->
            Just Matrix

        "jitsi" ->
            Just Jitsi

        _ ->
            Nothing
