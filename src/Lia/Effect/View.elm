module Lia.Effect.View exposing (view, view_block)

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Effect.Model exposing (Model)


view : (inline -> Html msg) -> Int -> Int -> List inline -> Html msg
view viewer idx visible elements =
    Html.span
        [ Attr.id (toString idx)
        , Attr.hidden (idx > visible)
        ]
        (circle idx :: Html.text " " :: List.map viewer elements)


view_block : Model -> (block -> Html msg) -> Int -> List block -> Html msg
view_block model viewer idx blocks =
    Html.div
        [ Attr.id (toString idx)
        , Attr.hidden (idx > model.visible)
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
