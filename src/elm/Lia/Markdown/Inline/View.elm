module Lia.Markdown.Inline.View exposing
    ( reference
    , view
    , view_inf
    , viewer
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Annotation exposing (Annotation, annotation, attributes)
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Settings.Model exposing (Mode(..))
import Oembed
import Translations exposing (Lang)


viewer : Config -> Inlines -> List (Html msg)
viewer config =
    List.map (view config)


goto : Int -> Attribute msg
goto line =
    Attr.attribute "ondblclick" ("liaGoto(" ++ String.fromInt line ++ ");")


view : Config -> Inline -> Html msg
view config element =
    case element of
        Chars e Nothing ->
            Html.text e

        Bold e attr ->
            Html.b (annotation "lia-bold" attr) [ view config e ]

        Italic e attr ->
            Html.em (annotation "lia-italic" attr) [ view config e ]

        Strike e attr ->
            Html.s (annotation "lia-strike" attr) [ view config e ]

        Underline e attr ->
            Html.u (annotation "lia-underline" attr) [ view config e ]

        Superscript e attr ->
            Html.sup (annotation "lia-superscript" attr) [ view config e ]

        Verbatim e attr ->
            Html.code
                (annotation "lia-code" attr)
                [ Html.text e ]

        Ref e attr ->
            reference config e attr

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
                |> List.map (view config)
                |> Html.span (annotation "lia-container" attr)

        IHTML node attr ->
            HTML.view Html.span (view config) attr node

        EInline e attr ->
            e.content
                |> viewer config
                |> Effect.inline config attr e

        {- if config.mode == Textbook then
               Html.span
                   (Attr.id (String.fromInt e.begin)
                       :: annotation "" Nothing
                   )
                   (Effect.view (viewer config) e.begin e.content)

           else
               Html.span
                   [ if (e.begin <= config.visible) && (e.end > config.visible) then
                       Attr.hidden False

                     else
                       Attr.hidden True
                   ]
                   [ Html.span
                       (Attr.id (String.fromInt e.begin)
                           :: annotation
                               (if attr == Nothing then
                                   "lia-effect"

                                else
                                   ""
                               )
                               attr
                       )
                       (Effect.view (viewer config) e.begin e.content)
                   ]
        -}
        Symbol e attr ->
            view config (Container [ Symbol e Nothing ] attr)

        Chars e attr ->
            view config (Container [ Chars e Nothing ] attr)

        Formula mode_ e attr ->
            view config (Container [ Formula mode_ e Nothing ] attr)

        Goto e line ->
            case e of
                Goto e_ line_ ->
                    view config (Goto e_ line_)

                IHTML node attr ->
                    HTML.view Html.span (view config) attr node

                _ ->
                    Html.span [ goto line ] [ view config e ]


view_inf : Lang -> Inline -> Html msg
view_inf =
    Config.init -1 Textbook 0 Nothing >> view


reference : Config -> Reference -> Annotation -> Html msg
reference config ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            Html.img
                (Attr.src url_
                    :: Attr.title title_
                    :: annotation "lia-image" attr
                )
                (viewer config alt_)

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
                    (viewer config alt_)

            else
                Html.audio
                    (Attr.controls True
                        :: Attr.title title_
                        :: annotation "lia-audio" attr
                    )
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer config alt_) ]

        Movie alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: Attr.title title_
                        :: annotation "lia-movie" attr
                    )
                    (viewer config alt_)

            else
                Html.video
                    (Attr.controls True :: Attr.title title_ :: annotation "lia-movie" attr)
                    [ Html.source [ Attr.src url_ ] [], Html.span [] (viewer config alt_) ]

        Embed _ url _ ->
            oembed Nothing url


customProviders : List Oembed.Provider
customProviders =
    []


oembed : Maybe { maxHeight : Int, maxWidth : Int } -> String -> Html msg
oembed options url =
    Oembed.view customProviders options url
        |> Maybe.withDefault (Html.text ("Couldn't find oembed provider for url " ++ url))


view_url : Config -> Inlines -> String -> String -> Annotation -> Html msg
view_url config alt_ url_ title_ attr =
    [ Attr.href url_, Attr.title title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer config alt_))
