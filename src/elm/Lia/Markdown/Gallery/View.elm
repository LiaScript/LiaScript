module Lia.Markdown.Gallery.View exposing (..)

import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Markdown.Gallery.Types exposing (Gallery, Vector)
import Lia.Markdown.Gallery.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inline)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Utils exposing (btnIcon, get, icon, modal)


view : Config sub -> Vector -> Parameters -> Gallery -> Html (Msg sub)
view config vector attr gallery =
    gallery.media
        |> List.indexedMap
            (\i media ->
                [ [ media ]
                    |> viewer config
                    |> List.map (Html.map Script)
                    |> List.head
                    |> Maybe.withDefault (Html.text "")
                , Html.div
                    [ Event.onClick <| Show gallery.id i
                    , Attr.class "lia-lightbox__clickarea"
                    , A11y_Key.tabbable True
                    , A11y_Role.button
                    , A11y_Widget.label "zoom media"
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
    if mediaID < 0 then
        div

    else
        Html.div []
            [ gallery.media
                |> get mediaID
                |> Maybe.map (viewOverlay config gallery.id mediaID (List.length gallery.media))
                |> Maybe.withDefault (Html.text "")
            , div
            ]


viewOverlay : Config sub -> Int -> Int -> Int -> Inline -> Html (Msg sub)
viewOverlay config id mediaID size media =
    [ media ]
        |> viewer config
        |> List.map (Html.map Script)
        |> modal (Close id) (viewControls id mediaID size)


viewControls : Int -> Int -> Int -> Maybe (List (Html (Msg sub)))
viewControls id mediaID size =
    Just
        [ btnIcon
            { icon = "icon-arrow-right"
            , msg =
                if mediaID + 1 < size then
                    Just (Show id (mediaID + 1))

                else
                    Nothing
            , tabbable = True
            , title = "next media"
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
            , title = "previous media"
            }
            [ Attr.class "lia-modal__ctrl-prev lia-btn--transparent" ]
        ]
