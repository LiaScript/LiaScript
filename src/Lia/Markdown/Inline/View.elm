module Lia.Markdown.Inline.View exposing (annotation, reference, view, view_inf, viewer)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Effect.View as Effect
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))
import Lia.Utils


annotation : String -> Annotation -> List (Attribute msg)
annotation cls attr =
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

        Bold e attr ->
            Html.b (annotation "lia-bold" attr) [ view visible e ]

        Italic e attr ->
            Html.em (annotation "lia-italic" attr) [ view visible e ]

        Strike e attr ->
            Html.s (annotation "lia-strike" attr) [ view visible e ]

        Underline e attr ->
            Html.u (annotation "lia-underline" attr) [ view visible e ]

        Superscript e attr ->
            Html.sup (annotation "lia-superscript" attr) [ view visible e ]

        Verbatim e attr ->
            Html.code (annotation "lia-code" attr) [ Html.text e ]

        Ref e attr ->
            reference e attr

        Formula mode e Nothing ->
            Lia.Utils.formula mode e

        Symbol e Nothing ->
            Lia.Utils.stringToHtml e

        FootnoteMark e attr ->
            Html.sup (annotation "lia-superscript" attr) [ Html.text e ]

        Container list attr ->
            list
                |> List.map (\e -> view visible e)
                |> Html.span (annotation "lia-container" attr)

        HTML e ->
            Lia.Utils.stringToHtml e

        EInline id_in id_out e attr ->
            if (id_in <= visible) && (id_out > visible) then
                Html.span
                    (Attr.id (toString id_in) :: annotation "lia-effect-inline" attr)
                    (Effect.view (viewer visible) id_in e)
            else
                Html.text ""

        Symbol e attr ->
            view visible (Container [ Symbol e Nothing ] attr)

        Chars e attr ->
            view visible (Container [ Chars e Nothing ] attr)

        Formula mode e attr ->
            view visible (Container [ Formula mode e Nothing ] attr)


view_inf : Inline -> Html msg
view_inf =
    view 99999


reference : Reference -> Annotation -> Html msg
reference ref attr =
    case ref of
        Link alt_ url_ ->
            view_url alt_ url_ attr

        Image alt_ url_ ->
            Html.img (Attr.src url_ :: annotation "lia-image" attr) [ Html.text alt_ ]

        Movie alt_ url_ ->
            if url_ |> String.toLower |> String.contains "https://www.youtube" then
                Html.iframe (Attr.src url_ :: annotation "lia-movie" attr) [ Html.text alt_ ]
            else
                Html.video (Attr.controls True :: annotation "lia-movie" attr) [ Html.source [ Attr.src url_ ] [], Html.text alt_ ]

        Mail alt_ url_ ->
            view_url alt_ ("mailto:" ++ url_) attr


view_url : String -> String -> Annotation -> Html msg
view_url alt_ url_ attr =
    [ Attr.href url_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a [ Html.text alt_ ])
