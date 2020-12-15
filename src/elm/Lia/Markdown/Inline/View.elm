module Lia.Markdown.Inline.View exposing
    ( view_inf
    , viewer
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Script.Update exposing (Msg)
import Lia.Markdown.Effect.Script.View as JS
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Section exposing (SubSection)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Utils as Utils
import Oembed
import QRCode
import Translations exposing (Lang)


viewer : Config sub -> Inlines -> List (Html (Msg sub))
viewer config =
    List.map (view config)


view : Config sub -> Inline -> Html (Msg sub)
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
            Html.code (annotation "lia-code" attr) [ Html.text e ]

        Ref e attr ->
            reference config e attr

        Formula mode_ e [] ->
            Html.node "lia-formula"
                [ Attr.attribute "displayMode" mode_
                , e
                    |> JE.string
                    |> Attr.property "formula"
                ]
                []

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

        Script id attr ->
            JS.view config id attr

        Symbol e attr ->
            view config (Container [ Symbol e [] ] attr)

        Chars e attr ->
            view config (Container [ Chars e [] ] attr)

        Formula mode_ e attr ->
            view config (Container [ Formula mode_ e [] ] attr)


view_inf : Scripts SubSection -> Lang -> Inline -> Html (Msg sub)
view_inf scripts lang =
    Config.init -1 Textbook 0 Nothing scripts lang Nothing |> view


stringFrom : Config sub -> Maybe Inlines -> String
stringFrom config =
    Maybe.map (stringify_ config.scripts config.visible)
        >> Maybe.withDefault ""


title : Config sub -> Maybe Inlines -> Html.Attribute msg
title config =
    stringFrom config >> Attr.title


alt : Config sub -> Inlines -> Html.Attribute msg
alt config =
    Just >> stringFrom config >> Attr.alt


img : Config sub -> Parameters -> Inlines -> String -> Maybe Inlines -> Html msg
img config attr alt_ url_ title_ =
    Html.img
        (Attr.src url_
            :: title config title_
            :: alt config alt_
            :: annotation "lia-image" attr
        )
        []


figure : Config sub -> Maybe Inlines -> Html (Msg sub) -> Html (Msg sub)
figure config title_ element =
    case title_ of
        Nothing ->
            element

        Just caption ->
            Html.figure
                [ Attr.style "margin" "0px"
                , Attr.style "display" "inline-table"
                ]
                [ element
                , Html.figcaption
                    [ Attr.style "display" "table-caption"
                    , Attr.style "caption-side" "bottom"
                    ]
                    (viewer config caption)
                ]


reference : Config sub -> Reference -> Parameters -> Html (Msg sub)
reference config ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            img config attr alt_ url_ title_
                |> figure config title_

        Audio alt_ ( tube, url_ ) title_ ->
            figure config title_ <|
                if tube then
                    Html.iframe
                        (Attr.src url_
                            :: Attr.attribute "allowfullscreen" ""
                            :: alt config alt_
                            :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                            :: title config title_
                            :: Attr.style "width" "100%"
                            :: annotation "lia-audio" attr
                        )
                        []

                else
                    Html.audio
                        (Attr.controls True
                            :: title config title_
                            :: alt config alt_
                            :: annotation "lia-audio" attr
                        )
                        [ Html.source [ Attr.src url_ ] [] ]

        Movie alt_ ( tube, url_ ) title_ ->
            figure config title_ <|
                if tube then
                    Html.iframe
                        (Attr.src url_
                            :: Attr.attribute "allowfullscreen" ""
                            :: alt config alt_
                            :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                            :: title config title_
                            :: annotation "lia-movie" attr
                        )
                        (viewer config alt_)

                else
                    Html.video
                        (Attr.controls True
                            :: alt config alt_
                            :: title config title_
                            :: annotation "lia-movie" attr
                        )
                        [ Html.source [ Attr.src url_ ] [] ]

        Embed _ url _ ->
            oembed Nothing url

        Preview_Lia url ->
            Html.node "preview-lia"
                (Attr.attribute "src" url
                    :: annotation "" attr
                    |> Utils.avoidColumn
                )
                []

        Preview_Link url ->
            Html.node "preview-link"
                (Attr.attribute "src" url
                    :: annotation "" attr
                    |> Utils.avoidColumn
                )
                []

        QR_Link url title_ ->
            [ url
                |> QRCode.fromString
                |> Result.map (QRCode.toSvg [])
                |> Result.withDefault (Html.text "Error while encoding to QRCode.")
            ]
                |> Html.a
                    (Attr.href url
                        :: title config title_
                        :: Attr.style "width" "300px"
                        :: Attr.style "display" "inline-block"
                        :: Attr.style "background-color" "white"
                        :: annotation "lia-link" attr
                    )
                |> figure config title_


customProviders : List Oembed.Provider
customProviders =
    []


oembed : Maybe { maxHeight : Int, maxWidth : Int } -> String -> Html msg
oembed options url =
    Oembed.view customProviders options url
        |> Maybe.withDefault (Html.text ("Couldn't find oembed provider for url " ++ url))


view_url : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
view_url config alt_ url_ title_ attr =
    [ Attr.href url_, title config title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer config alt_))
