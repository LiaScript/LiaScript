module Lia.Markdown.Inline.View exposing
    ( view_inf
    , viewer
    )

import Accessibility.Widget as A11y_Widget
import Conditional.List as CList
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr exposing (width)
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
import Lia.Settings.Types exposing (Mode(..))
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
            Html.strong (annotation "lia-bold" attr) [ view config e ]

        Italic e attr ->
            Html.em (annotation "lia-italic" attr) [ view config e ]

        Strike e attr ->
            Html.s (annotation "lia-strike" attr) [ view config e ]

        Underline e attr ->
            Html.u (annotation "lia-underline" attr) [ view config e ]

        Superscript e attr ->
            Html.sup (annotation "lia-superscript" attr) [ view config e ]

        Verbatim e attr ->
            Html.code (annotation "lia-code lia-code--inline" attr) [ Html.text e ]

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


view_inf : Scripts SubSection -> Lang -> Maybe (Dict String ( Int, Int )) -> Inline -> Html (Msg sub)
view_inf scripts lang media =
    Config.init -1 Textbook 0 Nothing scripts lang Nothing (media |> Maybe.withDefault Dict.empty) |> view


stringFrom : Config sub -> Maybe Inlines -> Maybe String
stringFrom config el =
    case el |> Maybe.map (stringify_ config.scripts config.visible >> String.trim) of
        Just "" ->
            Nothing

        str ->
            str


title : Config sub -> Maybe Inlines -> Maybe (Html.Attribute msg)
title config =
    stringFrom config >> Maybe.map Attr.title


alt : Config sub -> Inlines -> Maybe (Html.Attribute msg)
alt config =
    Just >> stringFrom config >> Maybe.map Attr.alt


img : Config sub -> Parameters -> Inlines -> String -> Maybe Inlines -> Maybe Int -> Html msg
img config attr alt_ url_ title_ width =
    Html.img
        (Attr.src url_
            :: toAttribute attr
            |> CList.addIf (width == Nothing) (load url_)
            |> CList.addWhen (title config title_)
            |> CList.addWhen (alt config alt_)
        )
        []


load : String -> Attribute msg
load url =
    Attr.attribute "onload" ("img_('" ++ url ++ "',this.width,this.height)")


figure : Config sub -> Maybe Inlines -> Maybe Int -> Html (Msg sub) -> Html (Msg sub)
figure config title_ width element =
    Html.figure
        ([ Attr.class "lia-figure" ]
            |> CList.addWhen (Maybe.map Attr.width width)
        )
        [ Html.span [ Attr.class "lia-figure__media" ]
            [ element
            ]
        , title_
            |> Maybe.map (viewer config >> Html.figcaption [ Attr.class "lia-figure__caption" ])
            |> Maybe.withDefault (Html.text "")
        ]


reference : Config sub -> Reference -> Parameters -> Html (Msg sub)
reference config ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url config alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            let
                width =
                    config.media
                        |> Dict.get url_
                        |> Maybe.map Tuple.first
            in
            img config attr alt_ url_ title_ width
                |> figure config title_ width

        Audio alt_ ( tube, url_ ) title_ ->
            figure config title_ Nothing <|
                if tube then
                    Html.iframe
                        (Attr.src url_
                            :: Attr.attribute "allowfullscreen" ""
                            :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                            :: Attr.style "width" "100%"
                            :: annotation "lia-audio" attr
                            |> CList.addWhen (title config title_)
                            |> CList.addWhen (alt config alt_)
                        )
                        []

                else
                    Html.audio
                        (Attr.controls True
                            :: annotation "lia-audio" attr
                            |> CList.addWhen (title config title_)
                            |> CList.addWhen (alt config alt_)
                        )
                        [ Html.source [ Attr.src url_ ] [] ]

        Movie alt_ ( tube, url_ ) title_ ->
            figure config title_ Nothing <|
                if tube then
                    Html.div [ Attr.class "lia-video-wrapper" ]
                        [ Html.iframe
                            (Attr.src url_
                                :: Attr.attribute "allowfullscreen" ""
                                :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                                :: toAttribute attr
                                |> CList.addWhen (title config title_)
                                |> CList.addWhen (alt config alt_)
                            )
                            (viewer config alt_)
                        ]

                else
                    Html.div [ Attr.class "lia-video-wrapper" ]
                        [ Html.video
                            (Attr.controls True
                                :: toAttribute attr
                                |> CList.addWhen (title config title_)
                                |> CList.addWhen (alt config alt_)
                            )
                            [ Html.source [ Attr.src url_ ] [] ]
                        ]

        Embed _ url _ ->
            oembed Nothing url

        Preview_Lia url ->
            Html.node "preview-lia"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        Preview_Link url ->
            Html.node "preview-link"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        QR_Link url title_ ->
            [ url
                |> QRCode.fromString
                |> Result.map (QRCode.toSvg [ A11y_Widget.label <| "QR-Code for website: " ++ url ])
                |> Result.withDefault (Html.text "Error while encoding to QRCode.")
            ]
                |> Html.a
                    (Attr.href url
                        :: Attr.style "width" "300px"
                        :: Attr.style "display" "inline-block"
                        :: Attr.style "background-color" "white"
                        :: annotation "lia-link" attr
                        |> CList.addWhen (title config title_)
                    )
                |> figure config title_ (Just 300)


customProviders : List Oembed.Provider
customProviders =
    []


oembed : Maybe { maxHeight : Int, maxWidth : Int } -> String -> Html msg
oembed options url =
    Oembed.view customProviders options url
        |> Maybe.withDefault (Html.text ("Couldn't find oembed provider for url " ++ url))


view_url : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
view_url config alt_ url_ title_ attr =
    Attr.href url_
        :: annotation "lia-link" attr
        |> CList.addWhen (title config title_)
        |> Html.a
        |> (\a -> a (viewer config alt_))
