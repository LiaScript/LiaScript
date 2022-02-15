module Lia.Sync.Via exposing
    ( Backend(..)
    , fromString
    , icon
    , info
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


info : Backend -> Html msg
info about =
    Html.p [ Attr.style "padding" "5px 15px 5px 15px", Attr.style "border" "1px solid white" ] <|
        case about of
            Beaker ->
                [ Html.text "beaker" ]

            GUN ->
                [ Html.a [ Attr.href "https://gun.eco" ] [ Html.text "GunDB" ]
                , Html.text " is a small, easy, and fast protocol for syncing data across various users."
                , Html.text " It currently uses our free relay server hosted at "
                , Html.a [ Attr.href "https://lia-gun.herokuapp.com" ] [ Html.text "https://lia-gun.herokuapp.com" ]
                , Html.text ". In the future, we will extend this to allow also other peers to be included."
                , Html.text " The implementation of this classroom can be found "
                , Html.a [ Attr.href "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/Gun" ] [ Html.text "here" ]
                , Html.text " we do not store or log any data."
                , Html.text " It is just a method for transmitting information to all connected users."
                ]

            Jitsi ->
                [ Html.text "Jitsi" ]

            Matrix ->
                [ Html.text "Matrix" ]

            PubNub ->
                [ Html.text "PubNub" ]
