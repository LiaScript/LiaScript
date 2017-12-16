module Lia.Effect.View exposing (comment, state, view, view_block)

--, view_comment)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Effect.Model exposing (Model)


--import Lia.Utils exposing (stringToHtml)
--spaces =
--stringToHtml "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
--    Html.text " "


view : (inline -> Html msg) -> Int -> Int -> Maybe String -> List inline -> Html msg
view viewer idx visible effect_name elements =
    Html.span
        [ Attr.id (toString idx)
        , Attr.hidden (idx > visible)
        , if idx > visible then
            Attr.style []
          else
            Attr.style [ ( "display", "inline-block" ) ]
        , case effect_name of
            Nothing ->
                Attr.class "lia-effect-inline"

            Just name ->
                Attr.class ("lia-effect-inline animated " ++ name)
        ]
        (Html.span
            [ Attr.class
                (if effect_name == Nothing then
                    "lia-effect-circle"
                 else
                    "lia-effect-circle animated"
                )
            ]
            [ Html.text (toString idx) ]
            :: Html.text " "
            :: List.map viewer elements
        )


view_block : Model -> (block -> Html msg) -> Int -> Maybe String -> List block -> Html msg
view_block model viewer idx effect_name blocks =
    Html.div
        [ Attr.id (toString idx)
        , Attr.hidden (idx > model.visible)
        , case effect_name of
            Nothing ->
                Attr.class "lia-effect-inline"

            Just name ->
                Attr.class ("lia-effect-inline animated " ++ name)
        ]
        (Html.span [ Attr.class "lia-effect-circle" ] [ Html.text (toString idx) ]
            :: List.map viewer blocks
        )


comment : String -> Bool -> Bool -> msg -> Model -> (inline -> Html msg) -> Int -> List inline -> Html msg
comment class show_inline silent msg model viewer idx elements =
    if show_inline then
        elements
            |> List.map viewer
            |> Html.div []
    else if idx == model.visible then
        Html.div
            [ Attr.class class
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
    Html.span []
        [ Html.button [ Attr.class "lia-btn lia-icon", onClick msg ]
            [ if silent then
                Html.text "volume_off"
              else
                Html.text "volume_up"
            ]
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


state : Model -> String
state model =
    if model.effects == 0 then
        ""
    else
        "(" ++ toString (model.visible + 1) ++ "/" ++ toString (model.effects + 1) ++ ")"
