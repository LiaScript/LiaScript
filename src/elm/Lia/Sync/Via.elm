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
    | GUN
    | Jitsi
    | Matrix
    | PubNub


toString : Backend -> String
toString via =
    case via of
        Beaker ->
            "Beaker"

        GUN ->
            "GUN"

        Jitsi ->
            "JitSi"

        Matrix ->
            "Matrix"

        PubNub ->
            "PubNub"


icon : Backend -> Html msg
icon via =
    Util.icon
        (case via of
            Beaker ->
                "icon-beaker icon-xs"

            GUN ->
                "icon-gundb icon-xs"

            Jitsi ->
                "icon-jitsi icon-xs"

            Matrix ->
                "icon-matrix icon-xs"

            PubNub ->
                "icon-pubnub icon-xs"
        )
        [ Attr.style "padding-right" "5px"
        , Attr.style "font-size" "inherit"
        ]


fromString : String -> Maybe Backend
fromString via =
    case String.toLower via of
        "beaker" ->
            Just Beaker

        "gun" ->
            Just GUN

        "jitsi" ->
            Just Jitsi

        "matrix" ->
            Just Matrix

        "pubnub" ->
            Just PubNub

        _ ->
            Nothing
