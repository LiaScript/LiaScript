module Lia.Inline.View exposing (reference, view, view_inf, viewer)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Effect.View as Effect
import Lia.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..), Url(..))
import Lia.Utils


inline_class : String -> Attribute msg
inline_class c =
    Attr.class ("lia-inline" ++ c)


annotation : Annotation -> String -> List (Attribute msg)
annotation attr cls =
    case attr of
        Just dict ->
            --Dict.update "class" (\v -> Maybe.map ()(++)(cls ++ " ")) v) dict
            dict
                |> Dict.insert "class"
                    (case Dict.get "class" dict of
                        Just c ->
                            "lia-inline " ++ cls ++ " " ++ c

                        Nothing ->
                            "lia-inline " ++ cls
                    )
                |> Dict.toList
                |> List.map (\( key, value ) -> Attr.attribute key value)

        Nothing ->
            [ Attr.class ("lia-inline " ++ cls) ]


viewer : Int -> Inlines -> List (Html msg)
viewer visible elements =
    List.map (view visible) elements


view : Int -> Inline -> Html msg
view visible element =
    case element of
        Chars e Nothing ->
            Html.text e

        Chars e attr ->
            Html.span (annotation attr "lia-container") [ Html.text e ]

        Bold e attr ->
            Html.b (annotation attr "lia-bold")
                [ view visible e ]

        Italic e attr ->
            Html.em (annotation attr "lia-italic")
                [ view visible e ]

        Strike e attr ->
            Html.s (annotation attr "lia-strike")
                [ view visible e ]

        Underline e attr ->
            Html.u (annotation attr "lia-underline")
                [ view visible e ]

        Superscript e attr ->
            Html.sup (annotation attr "lia-superscript")
                [ view visible e ]

        Verbatim e attr ->
            Html.code (annotation attr "lia-code") [ Html.text e ]

        Container list ->
            list
                |> List.map (\e -> view visible e)
                |> Html.span [ inline_class "lia-container" ]

        Ref e attr ->
            reference e attr

        Formula mode e Nothing ->
            Lia.Utils.formula mode e

        Formula mode e attr ->
            Html.span (annotation attr "lia-container") [ Lia.Utils.formula mode e ]

        Symbol e Nothing ->
            Lia.Utils.stringToHtml e

        Symbol e attr ->
            Html.span (annotation attr "lia-container") [ Lia.Utils.stringToHtml e ]

        HTML e Nothing ->
            Lia.Utils.stringToHtml e

        HTML e attr ->
            Html.span (annotation attr "lia-container") [ Lia.Utils.stringToHtml e ]

        EInline idx name time elements ->
            Effect.view (view visible) idx visible name time elements


view_inf : Inline -> Html msg
view_inf =
    view 99999


reference : Reference -> Annotation -> Html msg
reference ref attr =
    case ref of
        Link alt_ url_ ->
            view_link alt_ url_ attr

        Image alt_ url_ ->
            Html.img (Attr.src (get_url url_) :: annotation attr "lia-image") [ Html.text alt_ ]

        Movie alt_ url_ ->
            Html.iframe (Attr.src (get_url url_) :: annotation attr "lia-movie") [ Html.text alt_ ]


get_url : Url -> String
get_url url =
    case url of
        Full str ->
            str

        Mail str ->
            str

        Partial str ->
            str


view_link : String -> Url -> Annotation -> Html msg
view_link alt_ url_ attr =
    (case url_ of
        Full str ->
            [ Attr.href str, Attr.target "_blank" ]

        Mail str ->
            [ Attr.href ("mailto:" ++ str) ]

        Partial str ->
            [ Attr.href str, Attr.target "_blank" ]
    )
        |> List.append (annotation attr "lia-link")
        |> Html.a
        |> (\a -> a [ Html.text alt_ ])
