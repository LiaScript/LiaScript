module Lia.Markdown.Inline.View exposing
    ( reference
    , view
    , view_inf
    , viewer
    )

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Annotation exposing (Annotation, annotation, attributes)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Settings.Model exposing (Mode(..))
import Oembed


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

        IHTML node attr ->
            HTML.view (view mode visible) attr node

        EInline id_in id_out e attr ->
            if mode == Textbook then
                Html.span
                    (Attr.id (String.fromInt id_in)
                        :: annotation "" Nothing
                    )
                    (Effect.view (viewer mode visible) id_in e)

            else
                Html.span
                    [ if (id_in <= visible) && (id_out > visible) then
                        Attr.hidden False

                      else
                        Attr.hidden True
                    ]
                    [ Html.span
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
                    ]

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

        Embed alt_ url title_ ->
            oembed Nothing url


customProviders =
    []


oembed : Maybe { maxHeight : Int, maxWidth : Int } -> String -> Html msg
oembed options url =
    Oembed.view customProviders options url
        |> Maybe.withDefault (Html.text ("Couldn't find oembed provider for url " ++ url))


view_url : Mode -> Int -> Inlines -> String -> String -> Annotation -> Html msg
view_url mode visible alt_ url_ title_ attr =
    [ Attr.href url_, Attr.title title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer mode visible alt_))
