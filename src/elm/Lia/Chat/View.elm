module Lia.Chat.View exposing (view)

import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed
import Lia.Chat.Model exposing (Model)
import Lia.Chat.Update exposing (Msg(..))
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Update as Markdown
import Lia.Markdown.View as Markdown
import Lia.Section exposing (Section)
import Lia.Utils exposing (btnIcon, noTranslate)
import Translations as Trans exposing (Lang)


view : Lang -> (Section -> Config Markdown.Msg) -> Model -> Html Msg
view lang config model =
    Html.div
        (noTranslate
            [ Attr.style "width" "100%"
            , Attr.style "height" "calc(100% - 3rem)"
            , Attr.style "display" "flex"
            , Attr.style "flex-direction" "column"
            , Attr.style "position" "absolute"
            , Attr.style "top" "3rem"
            ]
        )
        [ model.messages
            |> Dict.toList
            |> List.map (viewMessage config)
            |> Keyed.node "div"
                [ Attr.style "display" "flex"
                , Attr.style "flex-direction" "column"
                , Attr.style "justify-content" "flex-end"
                , Attr.style "bottom" "0"
                ]
            |> List.singleton
            |> Html.div
                [ Attr.style "height" "calc(100% - 10rem)"
                , Attr.style "overflow" "auto"
                , Attr.id "lia-chat-messages"
                ]
        , Html.div
            [ Attr.style "padding" "1rem"
            , Attr.style "height" "11.5rem"
            ]
            [ btnIcon
                { title = Trans.chatSend lang
                , tabbable = True
                , msg =
                    case String.trim model.input of
                        "" ->
                            Nothing

                        _ ->
                            Just Send
                , icon = "icon-send"
                }
                [ Attr.style "position" "absolute"
                , Attr.style "bottom" "1rem"
                , Attr.style "right" "2rem"
                , Attr.style "z-index" "100"
                , Attr.class "lia-btn--transparent"
                ]
            , Editor.editor
                [ Editor.onChange Input
                , Editor.value model.input
                , Attr.style "min-height" "10rem"
                , Attr.style "width" "100%"
                , Editor.maxLines 4
                , Editor.mode "markdown"
                , Editor.showGutter False
                , Attr.class "lia-code__input"
                ]
                []
            ]
        ]


viewMessage : (Section -> Config Markdown.Msg) -> ( String, Section ) -> ( String, Html Msg )
viewMessage config ( id, section ) =
    let
        id_ =
            id
                |> String.toInt
                |> Maybe.withDefault -1
    in
    section
        |> config
        |> Config.setID id_
        |> Markdown.viewContent
        |> Html.div
            [ Attr.style "margin" "0.45rem 1rem"
            , Attr.style "box-shadow" "0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)"
            , Attr.style
                "padding"
              <|
                if section.effect_model.effects == 0 then
                    "1rem 1rem 0.1rem"

                else
                    "1rem 1rem 0.1rem 3rem"
            ]
        |> Html.map (UpdateMarkdown id)
        |> Tuple.pair id
