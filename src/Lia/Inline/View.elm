module Lia.Inline.View exposing (reference, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Effect.View as Effect
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
            Effect.view (view visible) idx visible elements


reference : Reference -> Html msg
reference ref =
    case ref of
        Link alt_ url_ ->
            Html.a [ Attr.href url_ ] [ Html.text alt_ ]

        Image alt_ url_ ->
            Html.img [ Attr.src url_ ] [ Html.text alt_ ]

        Movie alt_ url_ ->
            Html.iframe [ Attr.src url_ ] [ Html.text alt_ ]
