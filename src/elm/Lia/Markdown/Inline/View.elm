module Lia.Markdown.Inline.View exposing
    ( view_inf
    , viewer
    )

import Array
import Conditional.List as CList
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Lia.Markdown.Effect.JavaScript as JS
import Lia.Markdown.Effect.Model as E
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, get, toAttribute)
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Settings.Model exposing (Mode(..))
import Oembed
import Translations exposing (Lang)


viewer : Config -> Inlines -> List (Html JS.Msg)
viewer config =
    List.map (view config)


view : Config -> Inline -> Html JS.Msg
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

        Script id attr ->
            case Array.get id config.effects of
                Just node ->
                    case node.result of
                        Just (Ok str) ->
                            if node.input.active then
                                Html.input
                                    (attr
                                        |> annotation ""
                                        |> List.append (input_ node.input id attr)
                                    )
                                    [ Html.text str ]

                            else
                                Html.span
                                    (attr
                                        |> annotation "lia-script"
                                        |> List.append (script node.input id attr)
                                    )
                                    [ Html.text str ]

                        Just (Err str) ->
                            Html.span [ Attr.style "color" "red" ] [ Html.text str ]

                        Nothing ->
                            Html.text ""

                Nothing ->
                    Html.text ""

        Symbol e attr ->
            view config (Container [ Symbol e [] ] attr)

        Chars e attr ->
            view config (Container [ Chars e [] ] attr)

        Formula mode_ e attr ->
            view config (Container [ Formula mode_ e [] ] attr)


script : JS.Input -> Int -> Parameters -> List (Html.Attribute JS.Msg)
script input id attr =
    []
        |> List.append (data_input input id attr)
        |> CList.addWhen
            (attr
                |> get "output"
                |> Maybe.map Attr.title
            )


input_ : JS.Input -> Int -> Parameters -> List (Html.Attribute JS.Msg)
input_ input id attr =
    case get "input" attr of
        Just str ->
            [ Attr.type_ str
            , Event.onInput (JS.Value id)
            , Attr.value input.value
            , Event.onBlur (JS.Deactivate id)
            , Attr.id "lia-focus"
            ]

        Nothing ->
            []


data_input : JS.Input -> Int -> Parameters -> List (Html.Attribute JS.Msg)
data_input input id attr =
    case get "input" attr of
        Just "button" ->
            [ Event.onClick (JS.Click id)
            , Attr.style "cursor" "pointer"
            ]

        Just "date" ->
            [ Event.onClick (JS.Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "number" ->
            [ Event.onClick (JS.Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "range" ->
            [ Event.onClick (JS.Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "time" ->
            [ Event.onClick (JS.Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "week" ->
            [ Event.onClick (JS.Activate id)
            , Attr.style "cursor" "pointer"
            ]

        _ ->
            []


view_inf : Lang -> Inline -> Html JS.Msg
view_inf =
    Config.init -1 Textbook 0 Nothing Array.empty >> view


stringFrom : Config -> Maybe Inlines -> String
stringFrom config =
    Maybe.map (stringify_ config.effects config.visible)
        >> Maybe.withDefault ""


title : Config -> Maybe Inlines -> Html.Attribute msg
title config =
    stringFrom config >> Attr.title


alt : Config -> Inlines -> Html.Attribute msg
alt config =
    Just >> stringFrom config >> Attr.alt


img : Config -> Parameters -> Inlines -> String -> Maybe Inlines -> Html msg
img config attr alt_ url_ title_ =
    Html.img
        (Attr.src url_
            :: title config title_
            :: alt config alt_
            :: annotation "lia-image" attr
        )
        []


figure : Config -> Maybe Inlines -> Html JS.Msg -> Html JS.Msg
figure config title_ element =
    case title_ of
        Nothing ->
            element

        Just caption ->
            Html.figure [ Attr.style "display" "inline-table" ]
                [ element
                , Html.figcaption
                    [ Attr.style "display" "table-caption"
                    , Attr.style "caption-side" "bottom"
                    ]
                    (viewer config caption)
                ]


reference : Config -> Reference -> Parameters -> Html JS.Msg
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


view_url : Config -> Inlines -> String -> Maybe Inlines -> Parameters -> Html JS.Msg
view_url config alt_ url_ title_ attr =
    [ Attr.href url_, title config title_ ]
        |> List.append (annotation "lia-link" attr)
        |> Html.a
        |> (\a -> a (viewer config alt_))
