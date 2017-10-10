module Lia.Inline.View exposing (reference, view, view_inf)

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Effect.View as Effect
import Lia.Inline.Types exposing (Inline(..), Reference(..), Url(..))
import Lia.Utils


inline_class : String -> Attribute msg
inline_class c =
    Attr.class ("lia-inline" ++ c)


view : Int -> Inline -> Html msg
view visible element =
    case element of
        Code e ->
            Html.code [ inline_class "lia-code" ]
                [ Html.text e ]

        Chars e ->
            Html.text e

        Bold e ->
            Html.b [ inline_class "lia-bold" ]
                [ view visible e ]

        Italic e ->
            Html.em [ inline_class "lia-italic" ]
                [ view visible e ]

        Strike e ->
            Html.s [ inline_class "lia-strike" ]
                [ view visible e ]

        Underline e ->
            Html.u [ inline_class "lia-underline" ]
                [ view visible e ]

        Superscript e ->
            Html.sup [ inline_class "lia-superscript" ]
                [ view visible e ]

        Container list ->
            list
                |> List.map (\e -> view visible e)
                |> Html.span [ inline_class "lia-container" ]

        Ref e ->
            reference e

        Formula mode e ->
            Lia.Utils.formula mode e

        Symbol e ->
            Lia.Utils.stringToHtml e

        HTML e ->
            Lia.Utils.stringToHtml e

        EInline idx effect_name elements ->
            Effect.view (view visible) idx visible effect_name elements


view_inf : Inline -> Html msg
view_inf =
    view 99999


reference : Reference -> Html msg
reference ref =
    let
        media url_ style_ =
            case style_ of
                Nothing ->
                    [ Attr.src <| get_url url_ ]

                Just s ->
                    [ Attr.src <| get_url url_
                    , Attr.attribute "style" s
                    ]
    in
    case ref of
        Link alt_ url_ ->
            view_link alt_ url_

        Image alt_ url_ style_ ->
            Html.img (media url_ style_) [ Html.text alt_ ]

        Movie alt_ url_ style_ ->
            Html.iframe (media url_ style_) [ Html.text alt_ ]


get_url : Url -> String
get_url url =
    case url of
        Full str ->
            str

        Mail str ->
            str

        Partial str ->
            str


view_link : String -> Url -> Html msg
view_link alt_ url_ =
    case url_ of
        Full str ->
            Html.a [ Attr.href str, inline_class "lia-link", Attr.target "_blank" ] [ Html.text alt_ ]

        Mail str ->
            Html.a [ Attr.href ("mailto:" ++ str), inline_class "lia-link" ] [ Html.text alt_ ]

        Partial str ->
            Html.a [ Attr.href str, inline_class "lia-link", Attr.target "_blank" ] [ Html.text alt_ ]
