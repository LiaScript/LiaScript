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
        , case effect_name of
            Nothing ->
                Attr.class ""

            Just name ->
                Attr.class ("animated " ++ name)
        ]
        (Html.div
            [ Attr.style
                [ ( "display", "flex" )
                , ( "justify-content", "center" )
                ]
            ]
            [ circle idx ]
            :: List.map viewer blocks
        )


comment : Model -> (inline -> Html msg) -> Int -> List inline -> Html msg
comment model viewer idx elements =
    if idx == model.visible then
        Html.div
            [ Attr.style
                [ ( "transition", ".1s ease" )
                , ( "opacity", "0.6" )
                , ( "position", "absolute" )
                , ( "top", "80%" )
                , ( "left", "50%" )
                , ( "width", "80%" )
                , ( "transform", "translate(-50%, -50%)" )
                , ( "-ms-transform", "translate(-50%, -50%)" )
                , ( "background-color", "#4CAF50" )
                , ( "color", "white" )
                , ( "font-size", "16px" )
                , ( "padding", "16px 32px" )
                ]
            ]
            (List.map viewer elements)
    else
        Html.div [] []


circle : Int -> Html msg
circle int =
    Html.span
        [ Attr.style
            [ ( "border-radius", "50%" )
            , ( "width", "15px" )
            , ( "height", "14px" )
            , ( "padding", "3px" )
            , ( "display", "inline-block" )
            , ( "background", "#000" )
            , ( "border", "2px solid #666" )
            , ( "color", "#fff" )
            , ( "text-align", "center" )
            , ( "font", "12px Arial Bold, sans-serif" )
            ]
        ]
        [ Html.text (toString int) ]
