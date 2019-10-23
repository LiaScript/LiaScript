module Lia.Markdown.Effect.View exposing (comment, responsive, state, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Effect.Model exposing (Model)
import Translations exposing (Lang, soundOff, soundOn)


view : (List inline -> List (Html msg)) -> Int -> List inline -> List (Html msg)
view viewer idx elements =
    elements
        |> viewer
        |> (::) (Html.text " ")
        |> (::)
            (idx
                |> String.fromInt
                |> Html.text
                |> List.singleton
                |> Html.span [ Attr.class "lia-effect-circle-inline" ]
            )


comment : Lang -> String -> Bool -> Bool -> msg -> Model -> (inline -> Html msg) -> Int -> List inline -> Html msg
comment lang class show_inline silent msg model viewer idx elements =
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
                [ responsive lang silent msg ]
            )

    else
        Html.div
            [ Attr.class "lia-effect-comment lia-hidden"
            ]
            []


responsive : Lang -> Bool -> msg -> Html msg
responsive lang sound msg =
    Html.span []
        [ Html.button
            [ Attr.class "lia-btn lia-icon"
            , onClick msg
            , Attr.title <|
                if sound then
                    soundOn lang

                else
                    soundOff lang
            ]
            [ if sound then
                Html.text "volume_up"

              else
                Html.text "volume_off"
            ]
        , Html.a [ Attr.href "https://responsivevoice.org" ] [ Html.text "ResponsiveVoice-NonCommercial" ]
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
        " (" ++ String.fromInt (model.visible + 1) ++ "/" ++ String.fromInt (model.effects + 1) ++ ")"
