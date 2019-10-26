module Lia.Markdown.Inline.View exposing (annotation, attributes, reference, view, view_inf, viewer)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Parser.Util as Util
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))
import Lia.Settings.Model exposing (Mode(..))


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


attributes : Annotation -> List (Attribute msg)
attributes attr =
    case attr of
        Just dict ->
            dict
                |> Dict.toList
                |> List.map (\( key, value ) -> Attr.attribute key value)

        Nothing ->
            []


viewer : Mode -> Int -> Inlines -> List (Html msg)
viewer mode visible elements =
    List.map (view mode visible) elements


view : Mode -> Int -> Inline -> Html msg
view mode visible element =
    case element of
        Chars e Nothing ->
            Html.text e

        Bold e attr ->
            Html.b (annotation "lia-bold" attr) [ view mode visible e ]

        Italic e attr ->
            Html.em (annotation "lia-italic" attr) [ view mode visible e ]

        Strike e attr ->
            Html.s (annotation "lia-strike" attr) [ view mode visible e ]

        Underline e attr ->
            Html.u (annotation "lia-underline" attr) [ view mode visible e ]

        Superscript e attr ->
            Html.sup (annotation "lia-superscript" attr) [ view mode visible e ]

        Verbatim e attr ->
            Html.code (annotation "lia-code" attr) [ Html.text e ]

        Ref e attr ->
            reference mode visible e attr

        Formula mode_ e Nothing ->
            Html.node "katex-formula"
                [ Attr.attribute "displayMode" mode_ ]
                [ Html.text e ]

        Symbol e Nothing ->
            Html.text e

        FootnoteMark e attr ->
            attr
                |> attributes
                |> Footnote.inline e

        Container list attr ->
            list
                |> List.map (\e -> view mode visible e)
                |> Html.span (annotation "lia-container" attr)

        HTML list ->
            list
                |> Util.toVirtualDom
                |> Html.span []

        EInline id_in id_out e attr ->
            if mode == Textbook then
                Html.span
                    (Attr.id (String.fromInt id_in)
                        :: annotation "" Nothing
                    )
                    (Effect.view (viewer mode visible) id_in e)

            else if (id_in <= visible) && (id_out > visible) then
                Html.span
                    (Attr.id (String.fromInt id_in)
                        :: annotation
                            (if attr == Nothing then
                                "lia-effect"

                             else
                                ""
                            )
                            attr
                    )
                    (Effect.view (viewer mode visible) id_in e)

            else
                Html.text ""

        Symbol e attr ->
            view mode visible (Container [ Symbol e Nothing ] attr)

        Chars e attr ->
            view mode visible (Container [ Chars e Nothing ] attr)

        Formula mode_ e attr ->
            view mode visible (Container [ Formula mode_ e Nothing ] attr)


view_inf : Mode -> Inline -> Html msg
view_inf mode =
    view mode 99999


reference : Mode -> Int -> Reference -> Annotation -> Html msg
reference mode visible ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url mode visible alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url mode visible alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            Html.img
                (Attr.src url_
                    :: Attr.title title_
                    :: annotation "lia-image" attr
                )
                (viewer mode visible alt_)

        Audio alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: Attr.title title_
                        :: Attr.style "width" "100%"
                        :: annotation "lia-audio" attr
                    )
                    (viewer mode visible alt_)

            else
                Html.audio
                    (Attr.controls True
                        :: Attr.title title_
                        :: annotation "lia-audio" attr
                    )
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer mode visible alt_) ]

        Movie alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: Attr.title title_
                        :: annotation "lia-movie" attr
                    )
                    (viewer mode visible alt_)

            else
                Html.video
                    (Attr.controls True :: Attr.title title_ :: annotation "lia-movie" attr)
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer mode visible alt_) ]


view_url : Mode -> Int -> Inlines -> String -> String -> Annotation -> Html msg
view_url mode visible alt_ url_ title_ attr =
    [ Attr.href url_, Attr.title title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer mode visible alt_))
