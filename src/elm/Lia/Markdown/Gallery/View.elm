module Lia.Markdown.Gallery.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import I18n.Translations as Translations exposing (Lang)
import Json.Decode as JD
import Lia.Markdown.Gallery.Types exposing (Gallery, Vector)
import Lia.Markdown.Gallery.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Stringify as Stringify
import Lia.Markdown.Inline.Types exposing (Inline)
import Lia.Markdown.Inline.View as Inline
import Lia.Utils exposing (btnIcon, deactivate, get, icon, modal)


{-| Every media is one button that opens the gallery, named by its alt text.
The preview below is inert, its own controls (zoom, video) are covered by
the button and would only be extra tab stops.
-}
view : Config sub -> Vector -> Parameters -> Gallery -> Html (Msg sub)
view config vector attr gallery =
    gallery.media
        |> List.indexedMap
            (\i media ->
                [ media
                    |> Inline.view { config | oEmbed = Just { maxwidth = 250, maxheight = 250, scale = 1.0, thumbnail = True } }
                    |> Html.map Script
                    |> List.singleton
                    |> Html.div (deactivate True [])
                , Html.div
                    [ Event.onClick <| Show gallery.id i
                    , Attr.class "lia-lightbox__clickarea"
                    , A11y_Key.tabbable True
                    , A11y_Role.button
                    , Attr.attribute "aria-haspopup" "dialog"
                    , A11y_Aria.label <|
                        case String.trim (Stringify.stringify [ media ]) of
                            "" ->
                                Translations.baseZoom config.lang

                            alt ->
                                Translations.baseZoom config.lang ++ ": " ++ alt
                    , A11y_Key.onKeyDown
                        [ A11y_Key.enter (Show gallery.id i)
                        , A11y_Key.space (Show gallery.id i)
                        ]
                    ]
                    [ icon "icon-zoom"
                        [ Attr.class "lia-lightbox__icon"
                        ]
                    ]
                ]
                    |> Html.div
                        [ Attr.class "lia-lightbox" ]
            )
        |> Html.div (annotation "lia-gallery" attr)
        |> viewMedia config vector gallery


viewMedia : Config sub -> Vector -> Gallery -> Html (Msg sub) -> Html (Msg sub)
viewMedia config vector gallery div =
    let
        mediaID =
            Array.get gallery.id vector |> Maybe.withDefault -1
    in
    Html.div [] <|
        if mediaID < 0 then
            [ Html.text "", div ]

        else
            [ gallery.media
                |> get mediaID
                |> Maybe.map (viewOverlay config gallery.id mediaID (List.length gallery.media))
                |> Maybe.withDefault (Html.text "")
            , div
            ]


viewOverlay : Config sub -> Int -> Int -> Int -> Inline -> Html (Msg sub)
viewOverlay config id mediaID size =
    Inline.viewMedia { config | oEmbed = Just { maxwidth = 0, maxheight = 0, scale = 0.76, thumbnail = False } }
        >> Html.map Script
        >> List.singleton
        >> modal config.lang True (Close id) (viewControls config.lang id mediaID size)
        >> List.singleton
        >> Html.div [ Event.on "keydown" (arrows id mediaID size) ]


{-| The arrow keys switch to the next or previous media, in the direction of
the text (`dir` of the document). Within media, inputs and iframes the keys
belong to the element, e.g. seeking a video.
-}
arrows : Int -> Int -> Int -> JD.Decoder (Msg sub)
arrows id mediaID size =
    JD.map3
        (\key tag dir ->
            let
                next =
                    if dir == "rtl" then
                        "ArrowLeft"

                    else
                        "ArrowRight"

                target =
                    if key == next then
                        mediaID + 1

                    else if key == "ArrowLeft" || key == "ArrowRight" then
                        mediaID - 1

                    else
                        -1
            in
            if target < 0 || target >= size || List.member tag [ "VIDEO", "AUDIO", "INPUT", "TEXTAREA", "SELECT", "IFRAME" ] then
                JD.fail "not a switch"

            else
                JD.succeed (Show id target)
        )
        (JD.field "key" JD.string)
        (JD.at [ "target", "tagName" ] JD.string)
        (JD.at [ "target", "ownerDocument", "documentElement", "dir" ] JD.string)
        |> JD.andThen identity


viewControls : Lang -> Int -> Int -> Int -> Maybe (List (Html (Msg sub)))
viewControls lang id mediaID size =
    Just
        [ btnIcon
            { icon = "icon-arrow-right"
            , msg =
                if mediaID + 1 < size then
                    Just (Show id (mediaID + 1))

                else
                    Nothing
            , tabbable = True
            , title = Translations.baseNext lang
            }
            [ Attr.class "lia-modal__ctrl-next lia-btn--transparent" ]
        , btnIcon
            { icon = "icon-arrow-left"
            , msg =
                if mediaID > 0 then
                    Just (Show id (mediaID - 1))

                else
                    Nothing
            , tabbable = True
            , title = Translations.basePrev lang
            }
            [ Attr.class "lia-modal__ctrl-prev lia-btn--transparent" ]
        ]
