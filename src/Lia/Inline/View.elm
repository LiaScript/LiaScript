module Lia.Inline.View exposing (circle, reference, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Inline.Type exposing (Inline(..), Reference(..))
import Lia.Utils


view : Int -> Inline -> Html msg
view visible element =
    case element of
        Code e ->
            Html.code [] [ Html.text e ]

        Chars e ->
            Html.text e

        Bold e ->
            Html.b [] [ view visible e ]

        Italic e ->
            Html.em [] [ view visible e ]

        Underline e ->
            Html.u [] [ view visible e ]

        Superscript e ->
            Html.sup [] [ view visible e ]

        Ref e ->
            reference e

        Formula mode e ->
            Lia.Utils.formula mode e

        Symbol e ->
            Lia.Utils.stringToHtml e

        HTML e ->
            Lia.Utils.stringToHtml e

        EInline idx elements ->
            Html.span
                [ Attr.id (toString idx)
                , Attr.hidden (idx > visible)
                ]
                (circle idx
                    :: List.map (\e -> view visible e) elements
                )


reference : Reference -> Html msg
reference ref =
    case ref of
        Link alt_ url_ ->
            Html.a [ Attr.href url_ ] [ Html.text alt_ ]

        Image alt_ url_ ->
            Html.img [ Attr.src url_ ] [ Html.text alt_ ]

        Movie alt_ url_ ->
            Html.iframe [ Attr.src url_ ] [ Html.text alt_ ]


circle : Int -> Html msg
circle int =
    Html.span
        [ Attr.style
            [ ( "border-radius", "50%" )
            , ( "width", "15px" )
            , ( "height", "14px" )
            , ( "padding", "3px" )
            , ( "display", "inline-block" )
            , ( "background", "#000" )
            , ( "border", "2px solid #666" )
            , ( "color", "#fff" )
            , ( "text-align", "center" )
            , ( "font", "12px Arial Bold, sans-serif" )
            ]
        ]
        [ Html.text (toString int) ]
