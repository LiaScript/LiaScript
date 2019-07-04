module Lia.Markdown.Inline.View exposing (annotation, attributes, reference, view, view_inf, viewer)

import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Parser.Util as Util
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))


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


viewer : Int -> Inlines -> List (Html msg)
viewer visible elements =
    List.map (view visible) elements


goto : Int -> Attribute msg
goto line =
    Attr.attribute "ondblclick" ("liaGoto(" ++ String.fromInt line ++ ");")


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
            Html.code
                (annotation "lia-code" attr)
                [ Html.text e ]

        Ref e attr ->
            reference visible e attr

        Formula mode e Nothing ->
            Html.node "katex-formula"
                [ Attr.attribute "displayMode" mode ]
                [ Html.text e ]

        Symbol e Nothing ->
            Html.text e

        FootnoteMark e attr ->
            attr
                |> attributes
                |> Footnote.inline e

        Container list attr ->
            list
                |> List.map (\e -> view visible e)
                |> Html.span (annotation "lia-container" attr)

        HTML list ->
            list
                |> Util.toVirtualDom
                |> Html.span []

        EInline id_in id_out e attr ->
            if (id_in <= visible) && (id_out > visible) then
                Html.span
                    (Attr.id (String.fromInt id_in) :: annotation "lia-effect-inline" attr)
                    (Effect.view (viewer visible) id_in e)

            else
                Html.text ""

        Symbol e attr ->
            view visible (Container [ Symbol e Nothing ] attr)

        Chars e attr ->
            view visible (Container [ Chars e Nothing ] attr)

        Formula mode e attr ->
            view visible (Container [ Formula mode e Nothing ] attr)

        Goto e line ->
            Html.span [ goto line ] [ view visible e ]


view_inf : Inline -> Html msg
view_inf =
    view 99999


reference : Int -> Reference -> Annotation -> Html msg
reference visible ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url visible alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url visible alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            Html.img
                (Attr.src url_
                    :: Attr.title title_
                    :: annotation "lia-image" attr
                )
                (viewer visible alt_)

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
                    (viewer visible alt_)

            else
                Html.audio
                    (Attr.controls True
                        :: Attr.title title_
                        :: annotation "lia-audio" attr
                    )
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer visible alt_) ]

        Movie alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: Attr.title title_
                        :: annotation "lia-movie" attr
                    )
                    (viewer visible alt_)

            else
                Html.video
                    (Attr.controls True :: Attr.title title_ :: annotation "lia-movie" attr)
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer visible alt_) ]


view_url : Int -> Inlines -> String -> String -> Annotation -> Html msg
view_url visible alt_ url_ title_ attr =
    [ Attr.href url_, Attr.title title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer visible alt_))
