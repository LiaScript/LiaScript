module Lia.Markdown.Inline.View exposing
    ( reduce
    , toScript
    , view
    , viewMedia
    , view_inf
    , viewer
    )

import Accessibility.Widget as A11y_Widget
import Conditional.List as CList
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr exposing (width)
import Html.Keyed
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types exposing (Msg, Scripts)
import Lia.Markdown.Effect.Script.View as JS
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Multimedia exposing (website)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..), combine)
import Lia.Section exposing (SubSection)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (noTranslate)
import QRCode
import Translations exposing (Lang)


toScript : Int -> Parameters -> Inline
toScript =
    Script


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
            Html.code
                (attr
                    |> annotation "lia-code lia-code--inline"
                    |> noTranslate
                )
                [ Html.text e ]

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
                |> Html.span (Attr.style "left" "initial" :: toAttribute attr)

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


toText : Config sub -> Inline -> Html (Msg sub)
toText config element =
    case element of
        Chars e _ ->
            e
                |> String.split ". "
                |> List.map (\s -> s ++ "." |> Html.text |> List.singleton |> Html.p [])
                |> Html.div []

        Verbatim e attr ->
            Html.span
                (attr
                    |> toAttribute
                    |> noTranslate
                )
                [ Html.text e ]

        Formula mode_ e _ ->
            Html.node "lia-formula"
                [ Attr.attribute "displayMode" mode_
                , e
                    |> JE.string
                    |> Attr.property "formula"
                ]
                []

        Symbol e _ ->
            Html.text e

        Container [ e ] _ ->
            toText config e

        Container list _ ->
            list
                |> List.map (toText config)
                |> Html.span []

        IHTML node attr ->
            HTML.view Html.span (toText config) attr node

        EInline e _ ->
            e.content
                |> List.map (toText config)
                |> Effect.inline config [] e

        Script id attr ->
            JS.view config id attr

        _ ->
            Html.text ""


reduce : Config sub -> List Inline -> List (Html (Msg sub))
reduce config =
    List.map reduce_
        >> combine
        >> List.map (toText config)


reduce_ : Inline -> Inline
reduce_ element =
    case element of
        Chars e _ ->
            Chars e []

        Bold e _ ->
            reduce_ e

        Italic e _ ->
            reduce_ e

        Strike e _ ->
            reduce_ e

        Underline e _ ->
            reduce_ e

        Superscript e _ ->
            reduce_ e

        Ref e _ ->
            case e of
                Link alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Mail alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Image alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Audio alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Movie alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Embed alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Preview_Lia _ ->
                    Chars "preview-lia" []

                Preview_Link _ ->
                    Chars "preview-link" []

                QR_Link _ _ ->
                    Chars "qrcode" []

        FootnoteMark e _ ->
            Chars ("[" ++ e ++ "]") []

        Container [ e ] _ ->
            reduce_ e

        Container list _ ->
            Container (List.map reduce_ list) []

        _ ->
            element


viewMedia : Config sub -> Inline -> Html (Msg sub)
viewMedia config inline =
    case inline of
        Ref (Image alt_ url_ title_) attr ->
            Html.figure [ Attr.class "lia-figure" ]
                [ Html.div
                    [ Attr.class "lia-figure__media"
                    , Attr.attribute "data-media-image" "image"
                    , config.media
                        |> Dict.get url_
                        |> Maybe.map (Tuple.first >> Attr.width)
                        |> Maybe.withDefault (Attr.class "")
                    , Attr.style "background-image" ("url('" ++ url_ ++ "')")
                    , Attr.class "lia-figure__zoom"
                    , Attr.attribute "onmousemove" "window.LIA.img.zoom(event)"
                    ]
                    [ Html.img
                        (Attr.src url_
                            :: toAttribute attr
                            |> CList.addIf
                                (config.media
                                    |> Dict.get url_
                                    |> Maybe.map Tuple.first
                                    |> (==) Nothing
                                )
                                (load url_)
                            |> CList.addWhen (title config title_)
                            |> CList.addWhen (alt config alt_)
                        )
                        []
                    ]
                , title_
                    |> Maybe.map (viewer config >> Html.figcaption [ Attr.class "lia-figure__caption" ])
                    |> Maybe.withDefault (Html.text "")
                ]

        _ ->
            view config inline


view_inf :
    Scripts SubSection
    -> Lang
    -> Bool
    -> Bool
    -> Maybe ( String, String )
    -> Maybe (Dict String ( Int, Int ))
    -> Inline
    -> Html (Msg sub)
view_inf scripts lang light tooltips translations media =
    { mode = Textbook
    , visible = Nothing
    , slide = -1
    , speaking = Nothing
    , lang = lang
    , theme = Nothing
    , light = light
    , tooltips = tooltips
    , media = media |> Maybe.withDefault Dict.empty
    , scripts = scripts
    , translations = translations
    , sync = Nothing
    }
        |> Config.init
        |> view


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
            :: Attr.attribute "loading" "lazy"
            :: (if List.isEmpty attr then
                    [ Attr.attribute "onClick" ("window.LIA.img.click(\"" ++ url_ ++ "\")") ]

                else
                    toAttribute attr
               )
            |> CList.addIf (width == Nothing) (load url_)
            |> CList.addWhen (title config title_)
            |> CList.addWhen (alt config alt_)
        )
        []


load : String -> Attribute msg
load url =
    Attr.attribute "onload" ("window.LIA.img.load('" ++ url ++ "',this.width,this.height)")


figure : Config sub -> Maybe Inlines -> Maybe Int -> String -> Html (Msg sub) -> Html (Msg sub)
figure config title_ width dataType element =
    Html.figure
        ([ Attr.class "lia-figure" ]
            |> CList.addWhen (Maybe.map Attr.width width)
        )
        [ Html.div
            [ Attr.class "lia-figure__media"
            , Attr.attribute "data-media-type" dataType
            ]
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
                |> figure config title_ width "image"

        Audio alt_ ( tube, url_ ) title_ ->
            Html.a [ Attr.href url_ ]
                [ figure config title_ Nothing "audio" <|
                    if tube then
                        Html.iframe
                            (Attr.src url_
                                :: Attr.attribute "loading" "lazy"
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
                                :: Attr.attribute "preload" "none"
                                :: annotation "lia-audio" attr
                                |> CList.addWhen (title config title_)
                                |> CList.addWhen (alt config alt_)
                            )
                            [ Html.source [ Attr.src url_ ] [] ]
                ]

        Movie alt_ ( tube, url_ ) title_ ->
            Html.a [ Attr.href url_ ]
                [ if tube then
                    figure config title_ Nothing "iframe" <|
                        Html.div [ Attr.class "lia-iframe-wrapper" ]
                            [ Html.iframe
                                ((url_
                                    |> addTranslation config
                                    |> Attr.src
                                 )
                                    :: Attr.attribute "allowfullscreen" ""
                                    :: Attr.attribute "loading" "lazy"
                                    :: Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                                    :: toAttribute attr
                                    |> CList.addWhen (title config title_)
                                    |> CList.addWhen (alt config alt_)
                                )
                                (viewer config alt_)
                            ]

                  else
                    figure config title_ Nothing "movie" <|
                        -- This fixes if multiple videos appear on different sites, but on the same
                        -- position, then only the attributes are changed, which does not affect the
                        -- video at all. By using Html.Keyed the system is forced to update the
                        -- entire video tag.
                        Html.Keyed.node "div"
                            [ Attr.class "lia-video-wrapper" ]
                            [ ( url_
                              , Html.video
                                    (Attr.controls True
                                        :: Attr.attribute "preload" "none"
                                        :: toAttribute attr
                                        |> CList.addWhen (title config title_)
                                        |> CList.addWhen (alt config alt_)
                                    )
                                    [ Html.source [ Attr.src url_ ] [] ]
                              )
                            ]
                ]

        Embed _ url title_ ->
            Html.a [ Attr.href url ]
                [ Html.figure [ Attr.class "lia-figure", Attr.style "height" "auto", Attr.style "width" "100%" ] <|
                    [ Html.div [ Attr.class "lia-figure__media" ] <|
                        case title_ of
                            Just sub ->
                                [ oembed config.oEmbed url
                                , sub
                                    |> viewer config
                                    |> Html.figcaption [ Attr.class "lia-figure__caption" ]
                                ]

                            Nothing ->
                                [ oembed config.oEmbed url
                                ]
                    ]
                ]

        Preview_Lia url ->
            Html.node "preview-lia"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        Preview_Link url ->
            Html.Keyed.node "preview-link"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        QR_Link url title_ ->
            [ [ url
                    |> QRCode.fromString
                    |> Result.map (QRCode.toSvg [ A11y_Widget.label <| Translations.qrCode config.lang ++ ": " ++ url ])
                    |> Result.withDefault (Html.text (Translations.qrErr config.lang))
              ]
                |> Html.a
                    (Attr.href url
                        :: Attr.style "width" "300px"
                        :: Attr.style "display" "inline-block"
                        :: Attr.style "background-color" "white"
                        :: annotation "lia-link" attr
                        |> CList.addWhen (title config title_)
                    )
                |> figure config title_ (Just 300) "image"
            ]
                |> Html.a [ Attr.href url ]


addTranslation : Config sub -> String -> String
addTranslation config url_ =
    if String.startsWith website.youtube url_ then
        url_
            ++ (if String.contains "?" url_ then
                    "&hl="

                else
                    "?hl="
               )
            ++ getLang config

    else
        url_


getLang : Config sub -> String
getLang config =
    config.translations
        |> Maybe.map Tuple.second
        |> Maybe.withDefault (Translations.baseLang config.lang)


printLink : Config sub -> Inlines -> Maybe Inlines -> String -> Html (Msg sub)
printLink config alt_ title_ url_ =
    Html.a
        ([ Attr.class "lia-link lia-print-only"
         , Attr.href url_
         ]
            |> CList.addWhen (title config title_)
        )
        (viewer config alt_)


oembed : Maybe { maxwidth : Int, maxheight : Int, scale : Float, thumbnail : Bool } -> String -> Html msg
oembed option url =
    Html.node "lia-embed"
        [ url
            |> JE.string
            |> Attr.property "url"
        , option
            |> Maybe.map
                (\o ->
                    if o.maxwidth > 0 then
                        String.fromInt o.maxwidth ++ "px"

                    else
                        "100%"
                )
            |> Maybe.withDefault "100%"
            |> Attr.style "width"
        , option
            |> Maybe.map
                (\o ->
                    if o.maxheight > 0 then
                        String.fromInt o.maxheight ++ "px"

                    else
                        "auto"
                )
            |> Maybe.withDefault "auto"
            |> Attr.style "height"
        , Attr.style "display" "inline-block"
        , Attr.style "max-height" "100%"
        , option
            |> Maybe.map .maxwidth
            |> Maybe.withDefault 0
            |> JE.int
            |> Attr.property "maxwidth"
        , option
            |> Maybe.map .maxheight
            |> Maybe.withDefault 0
            |> JE.int
            |> Attr.property "maxheight"
        , option
            |> Maybe.map .thumbnail
            |> Maybe.withDefault False
            |> JE.bool
            |> Attr.property "thumbnail"
        , option
            |> Maybe.map (.scale >> String.fromFloat >> Attr.attribute "scale")
            |> Maybe.withDefault (Attr.class "")
        ]
        []


view_url : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
view_url config alt_ url_ title_ attr =
    if not config.tooltips || String.startsWith "#" url_ then
        link config alt_ url_ title_ attr

    else
        Html.Keyed.node "span"
            []
            [ ( url_
              , Html.node "preview-link"
                    [ Attr.attribute "src" url_
                    , config.light
                        |> JE.bool
                        |> Attr.property "light"
                    ]
                    [ link config alt_ url_ title_ attr ]
              )
            ]


link : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
link config alt_ url_ title_ attr =
    Attr.href url_
        :: Attr.target
            (if String.startsWith "#" url_ then
                ""

             else
                "_blank"
            )
        :: annotation "lia-link" attr
        |> CList.addWhen (title config title_)
        |> Html.a
        |> (\a -> a (viewer config alt_))
