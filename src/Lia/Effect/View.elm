module Lia.Effect.View exposing (comment, view, view_block)

--, view_comment)

import Html exposing (Html)
import Html.Attributes as Attr
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
        (
            circle idx
            :: List.map viewer blocks
        )


comment : Model -> (inline -> Html msg) -> Int -> List inline -> Html msg
comment model viewer idx elements =
    if idx == model.visible then
        Html.div
            [ Attr.class "lia-effect-comment"
            ]
            (List.append
                (List.map viewer elements)
                [ responsive ]
            )
    else
        Html.div
            [ Attr.class "lia-effect-comment"
            , Attr.class "lia-hidden"
            ] []


responsive : Html msg
responsive =
    Html.div []
        [ Html.a [ Attr.href "https://responsivevoice.org" ]
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
