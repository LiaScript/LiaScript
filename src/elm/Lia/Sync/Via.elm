module Lia.Sync.Via exposing
    ( Backend(..)
    , Msg
    , eq
    , fromString
    , icon
    , info
    , input
    , toString
    , update
    , view
    )

import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Utils as Util


type Backend
    = Beaker
    | GUN String
    | Jitsi
    | Matrix
    | PubNub String String


toString : Bool -> Backend -> String
toString full via =
    case via of
        Beaker ->
            "Beaker"

        GUN urls ->
            "GUN"
                ++ (if full then
                        "|" ++ urls

                    else
                        ""
                   )

        Jitsi ->
            "JitSi"

        Matrix ->
            "Matrix"

        PubNub pub sub ->
            "PubNub"
                ++ (if full then
                        "|" ++ pub ++ "|" ++ sub

                    else
                        ""
                   )


icon : Backend -> Html msg
icon via =
    Util.icon
        (case via of
            Beaker ->
                "icon-beaker icon-xs"

            GUN _ ->
                "icon-gundb icon-xs"

            Jitsi ->
                "icon-jitsi icon-xs"

            Matrix ->
                "icon-matrix icon-xs"

            PubNub _ _ ->
                "icon-pubnub icon-xs"
        )
        [ Attr.style "padding-right" "5px"
        , Attr.style "font-size" "inherit"
        ]


fromString : String -> Maybe Backend
fromString via =
    case via |> String.split "|" |> mapHead String.toLower of
        [ "beaker" ] ->
            Just Beaker

        [ "gun" ] ->
            Just (GUN "")

        [ "gun", urls ] ->
            Just (GUN urls)

        [ "jitsi" ] ->
            Just Jitsi

        [ "matrix" ] ->
            Just Matrix

        [ "pubnub" ] ->
            Just (PubNub "" "")

        [ "pubnub", pub, sub ] ->
            Just (PubNub pub sub)

        _ ->
            Nothing


mapHead : (a -> a) -> List a -> List a
mapHead fn list =
    case list of
        x :: xs ->
            fn x :: xs

        _ ->
            list


info : Bool -> Backend -> Html msg
info supported about =
    Html.p
        [ Attr.style "padding" "5px 15px 5px 15px"
        , Attr.style "border" "1px solid white"
        , Attr.style "margin-top" "2rem"
        ]
    <|
        case ( about, supported ) of
            ( Beaker, True ) ->
                [ Html.text "We are glad you are using the "
                , link "Beaker Browser" "https://beakerbrowser.com"
                , Html.text ". This allows you also to create and share content directly from within this Browser."
                , Html.text "This classroom is implemented via the internal "
                , link "beaker.peersockets" "https://docs.beakerbrowser.com/apis/beaker.peersockets"
                , Html.text ", which can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/Beaker"
                ]

            ( Beaker, False ) ->
                [ Html.text "Your browser does not support classrooms via the "
                , link "hyper://" "https://hypercore-protocol.org"
                , Html.text " protocol."
                , Html.text " You should try to download the "
                , link "Beaker Browser" "https://beakerbrowser.com"
                , Html.text ". It uses a peer-to-peer network with which you can make and host websites from inside the browser."
                , Html.text " In the same way you can also directly create and edit LiaScript courses within this browser and share them."
                ]

            ( GUN _, _ ) ->
                [ link "GunDB" "https://gun.eco"
                , Html.text " is a small, easy, and fast protocol for syncing data across various users."
                , Html.text " It currently uses our free relay server hosted at "
                , link Const.gunDB_ServerURL Const.gunDB_ServerURL
                , Html.text ". Or, if you don't trust us ;-) you can also use one of the free hosted relay servers listed "
                , link "here" "https://github.com/amark/gun/wiki/volunteer.dht"
                , Html.text ". Multiple peers have to be separated by commas."
                , Html.text " The implementation of this classroom can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/Gun"
                , Html.text ". We do not store or log any data, it is just an easy method for transmitting information to all connected users."
                ]

            ( Jitsi, _ ) ->
                [ Html.text "Not ready yet, but will be updated soon" ]

            ( Matrix, _ ) ->
                [ Html.text "Not ready yet, but will be updated soon" ]

            ( PubNub _ _, _ ) ->
                [ link "PubNub" "https://www.pubnub.com"
                , Html.text " is a realtime communication platform. "
                , Html.text "To create a classroom that uses this service, you will need an account and you have to create an App and a Keyset. "
                , Html.text ""
                ]


link : String -> String -> Html msg
link title url =
    Html.a [ Attr.href url, Attr.target "blank" ] [ Html.text title ]


view : Bool -> Backend -> Html Msg
view editable backend =
    case backend of
        GUN urls ->
            input
                { active = editable
                , type_ = "input"
                , msg = InputGun
                , value = urls
                , placeholder = ""
                , label = Html.text "relay server"
                }

        PubNub pub sub ->
            Html.div []
                [ input
                    { active = editable
                    , type_ = "input"
                    , msg = InputPubNub "pub"
                    , label = Html.text "publishKey"
                    , value = pub
                    , placeholder = "pub-c-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                    }
                , input
                    { active = editable
                    , type_ = "input"
                    , msg = InputPubNub "sub"
                    , label = Html.text "subscribeKey"
                    , value = sub
                    , placeholder = "sub-c-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                    }
                ]

        _ ->
            Html.text ""


input :
    { active : Bool
    , msg : String -> msg
    , label : Html msg
    , type_ : String
    , value : String
    , placeholder : String
    }
    -> Html msg
input c =
    Html.label []
        [ Html.span
            [ Attr.class "lia-label"
            , Attr.style "margin-top" "2rem"
            ]
            [ c.label ]
        , Html.input
            [ if c.active then
                Event.onInput c.msg

              else
                Attr.disabled True
            , Attr.value c.value
            , Attr.style "color" "black"
            , Attr.type_ c.type_
            , Attr.style "width" "100%"
            , Attr.placeholder c.placeholder
            ]
            []
        ]


type Msg
    = InputGun String
    | InputPubNub String String


update : Msg -> Backend -> Backend
update msg backend =
    case ( msg, backend ) of
        ( InputGun urls, GUN _ ) ->
            GUN urls

        ( InputPubNub "pub" new, PubNub _ sub ) ->
            PubNub new sub

        ( InputPubNub "sub" new, PubNub pub _ ) ->
            PubNub pub new

        _ ->
            backend


eq : Backend -> Backend -> Bool
eq a b =
    case ( a, b ) of
        ( GUN _, GUN _ ) ->
            True

        ( PubNub _ _, PubNub _ _ ) ->
            True

        _ ->
            a == b
