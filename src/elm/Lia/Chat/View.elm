module Lia.Chat.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Chat.Model exposing (Model)
import Lia.Chat.Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    Html.div
        [ Attr.style "background-color" "red"
        , Attr.style "width" "800px"
        , Attr.style "height" "100vh"
        , Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        ]
        [ model.messages
            |> List.map viewMessage
            |> Html.div
                [ Attr.style "height" "calc(100% - 16rem)"
                , Attr.style "display" "flex"
                , Attr.style "flex-direction" "column"
                , Attr.style "justify-content" "flex-end"
                ]
        , Html.div
            [ Attr.style "padding" "1rem"
            , Attr.style "height" "16rem"
            ]
            [ Html.textarea
                [ Event.onInput Input
                , Attr.value model.input
                ]
                []
            , Html.button
                [ Event.onClick Send
                ]
                [ Html.text ">" ]
            ]
        ]


viewMessage : String -> Html msg
viewMessage msg =
    Html.div
        [ Attr.style "padding" "1rem"
        , Attr.style "margin" "1rem"
        , Attr.style "background" "white"
        ]
        [ Html.text msg ]
