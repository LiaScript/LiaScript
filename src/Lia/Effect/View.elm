module Lia.Effect.View exposing (comment, view, view_block)

--, view_comment)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Effect.Model exposing (Model)


view : (inline -> Html msg) -> Int -> Int -> Maybe String -> List inline -> Html msg
view viewer idx visible effect_name elements =
    Html.span
        [ Attr.id (toString idx)
        , Attr.hidden (idx > visible)
        , Attr.class "lia-effect-inline"
        , case effect_name of
            Nothing ->
                Attr.class ""

            Just name ->
                Attr.class ("animated " ++ name)
        ]
        (circle idx :: Html.text " " :: List.map viewer elements)


view_block : Model -> (block -> Html msg) -> Int -> Maybe String -> List block -> Html msg
view_block model viewer idx effect_name blocks =
    Html.div
        [ Attr.id (toString idx)
        , Attr.hidden (idx > model.visible)
        , Attr.class "lia-effect-block"
        , case effect_name of
            Nothing ->
                Attr.class ""

            Just name ->
                Attr.class ("animated " ++ name)
        ]
        (circle idx
            :: List.map viewer blocks
        )


comment : Bool -> Bool -> msg -> Model -> (inline -> Html msg) -> Int -> List inline -> Html msg
comment show_inline silent msg model viewer idx elements =
    if show_inline then
        elements
            |> List.map viewer
            |> Html.div []
    else if idx == model.visible then
        Html.div
            [ Attr.class "lia-effect-comment"
            ]
            (List.append
                (List.map viewer elements)
                [ responsive silent msg ]
            )
    else
        Html.div
            [ Attr.class "lia-effect-comment lia-hidden"
            ]
            []


responsive : Bool -> msg -> Html msg
responsive silent msg =
    Html.div []
        [ Html.span [ Attr.class "lia-icon", onClick msg ]
            [ if silent then
                Html.text "volume_off"
              else
                Html.text "volume_up"
            ]
        , Html.text " "
        , Html.a [ Attr.href "https://responsivevoice.org" ]
            [ Html.text "ResponsiveVoice-NonCommercial" ]
        , Html.text " licensed under "
        , Html.a
            [ Attr.href "https://creativecommons.org/licenses/by-nc-nd/4.0/" ]
            [ Html.img
                [ Attr.title "ResponsiveVoice Text To Speech"
                , Attr.src "https://responsivevoice.org/wp-content/uploads/2014/08/95x15.png"
                , Attr.alt "95x15"
                , Attr.width 95
                , Attr.height 15
                ]
                []
            ]
        ]


circle : Int -> Html msg
circle int =
    Html.span
        [ Attr.class "lia-effect-circle"
        ]
        [ Html.text (toString int) ]
