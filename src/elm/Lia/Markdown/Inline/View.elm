module Lia.Markdown.Inline.View exposing
    ( view_inf
    , viewer
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Settings.Model exposing (Mode(..))
import Oembed
import Translations exposing (Lang)


viewer : Config -> Inlines -> List (Html msg)
viewer config =
    List.map (view config)


goto : Int -> Attribute msg
goto line =
    Attr.attribute "ondblclick" ("window.liaGoto(" ++ String.fromInt line ++ ");")


view : Config -> Inline -> Html msg
view config element =
    case element of
        Chars e [] ->
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

        Formula mode_ e [] ->
            Html.node "katex-formula"
                [ Attr.attribute "displayMode" mode_ ]
                [ Html.text e ]

        Symbol e [] ->
            Html.text e

        FootnoteMark e attr ->
            attr
                |> toAttribute
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

        Symbol e attr ->
            view config (Container [ Symbol e [] ] attr)

        Chars e attr ->
            view config (Container [ Chars e [] ] attr)

        Formula mode_ e attr ->
            view config (Container [ Formula mode_ e [] ] attr)

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


stringFrom : Maybe Int -> Maybe Inlines -> String
stringFrom visibility =
    Maybe.map (stringify_ visibility)
        >> Maybe.withDefault ""


title : Maybe Int -> Maybe Inlines -> Html.Attribute msg
title visibility =
    stringFrom visibility >> Attr.title


alt : Maybe Int -> Inlines -> Html.Attribute msg
alt visibility =
    Just >> stringFrom visibility >> Attr.alt


img : Parameters -> Maybe Int -> Inlines -> String -> Maybe Inlines -> Html msg
img attr visibility alt_ url_ title_ =
    Html.img
        (Attr.src url_
            :: title visibility title_
            :: alt visibility alt_
            :: annotation "lia-image" attr
        )
        []


reference : Config -> Reference -> Parameters -> Html msg
reference config ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            case title_ of
                Nothing ->
                    img attr config.visible alt_ url_ title_

                Just caption ->
                    Html.figure [ Attr.style "display" "inline-table" ]
                        [ img attr config.visible alt_ url_ title_
                        , Html.figcaption
                            [ Attr.style "display" "table-caption"
                            , Attr.style "caption-side" "bottom"
                            ]
                            (viewer config caption)
                        ]

        Audio alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: alt config.visible alt_
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: title config.visible title_
                        :: Attr.style "width" "100%"
                        :: annotation "lia-audio" attr
                    )
                    []

            else
                Html.audio
                    (Attr.controls True
                        :: title config.visible title_
                        :: alt config.visible alt_
                        :: annotation "lia-audio" attr
                    )
                    [ Html.source [ Attr.src url_ ] [] ]

        Movie alt_ ( tube, url_ ) title_ ->
            if tube then
                Html.iframe
                    (Attr.src url_
                        :: Attr.attribute "allowfullscreen" ""
                        :: alt config.visible alt_
                        :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        :: title config.visible title_
                        :: annotation "lia-movie" attr
                    )
                    (viewer config alt_)

            else
                Html.video
                    (Attr.controls True
                        :: alt config.visible alt_
                        :: title config.visible title_
                        :: annotation "lia-movie" attr
                    )
                    [ Html.source [ Attr.src url_ ] [] ]

        Embed _ url _ ->
            oembed Nothing url

        Preview_Lia url ->
            Html.node "preview-lia" (Attr.attribute "src" url :: annotation "" attr) []

        Preview_Link url ->
            Html.node "preview-link" (Attr.attribute "src" url :: annotation "" attr) []


customProviders : List Oembed.Provider
customProviders =
    []


oembed : Maybe { maxHeight : Int, maxWidth : Int } -> String -> Html msg
oembed options url =
    Oembed.view customProviders options url
        |> Maybe.withDefault (Html.text ("Couldn't find oembed provider for url " ++ url))


view_url : Config -> Inlines -> String -> Maybe Inlines -> Parameters -> Html msg
view_url config alt_ url_ title_ attr =
    [ Attr.href url_, title config.visible title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer config alt_))
