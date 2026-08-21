module Lia.Chat.View exposing (view)

import Accessibility.Aria as A11y
import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Keyed as Keyed
import I18n.Translations as Trans exposing (Lang)
import Lia.Chat.Model exposing (Model)
import Lia.Chat.Update exposing (Msg(..))
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Update as Markdown
import Lia.Markdown.View as Markdown
import Lia.Section exposing (Section)
import Lia.Utils exposing (btnIcon, formatDate, noTranslate, viewIdenticon)


view : Lang -> Bool -> (Section -> Config Markdown.Msg) -> Dict String String -> Model -> Html Msg
view lang lightMode config peers model =
    Html.div
        (noTranslate
            [ Attr.style "width" "100%"
            , Attr.style "height" "100%"
            , Attr.style "display" "flex"
            , Attr.style "flex-direction" "column"
            , Attr.style "position" "absolute"
            , Attr.style "padding" "1rem"
            ]
        )
        [ model.messages
            |> Dict.toList
            |> List.map (viewMessage config peers)
            |> Keyed.node "article"
                [ Attr.style "display" "flex"
                , Attr.style "flex-direction" "column"
                , Attr.style "justify-content" "flex-end"
                , Attr.style "bottom" "0"
                , A11y_Role.article
                ]
            |> List.singleton
            |> Html.section
                [ Attr.style "height" "100%"
                , Attr.style "overflow" "auto"
                , Attr.id "lia-chat-messages"
                , A11y_Live.livePolite
                , A11y_Live.atomic True
                ]
        , Html.div
            [ Attr.style "padding" "0.5rem"
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
                , Attr.style "right" "2rem"
                , Attr.style "z-index" "100"
                , Attr.style "color" "#888"
                , Attr.class "lia-btn--transparent"
                , A11y.keyShortcuts [ "Ctrl-Enter", "Command-Enter" ]
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
                , Editor.onCtrlEnter Send
                , A11y_Role.textBox
                , Editor.theme <|
                    "cloud9_"
                        ++ (if lightMode then
                                "day"

                            else
                                "night"
                           )
                ]
                []
            ]
        ]


viewMessage : (Section -> Config Markdown.Msg) -> Dict String String -> ( String, { section : Section, peer : String } ) -> ( String, Html Msg )
viewMessage config peers ( id, message ) =
    let
        id_ =
            id
                |> String.toInt
                |> Maybe.withDefault -1

        peerName =
            Dict.get message.peer peers
                |> Maybe.withDefault ""
    in
    List.append
        (message.section
            |> config
            |> Config.setID id_
            |> Markdown.viewContent
        )
        [ Html.div
            [ Attr.style "float" "right"
            , Attr.style "color" "#888"
            , Attr.style "font-size" "1.1rem"
            , Attr.style "margin-top" "-1.1rem"
            , Attr.style "text-decoration" "overline"
            ]
            [ Html.strong []
                (if String.isEmpty peerName then
                    [ Html.text (String.right 5 (formatDate id_)) ]

                 else
                    [ viewIdenticon message.peer
                    , Html.text (peerName ++ " · " ++ String.right 5 (formatDate id_))
                    ]
                )
            ]
        ]
        |> Html.div
            [ Attr.style "margin" "0.45rem 0.5rem"
            , Attr.style "box-shadow" "0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)"
            , Attr.style
                "padding"
              <|
                if message.section.effect_model.effects == 0 then
                    "1rem 1rem 0.1rem"

                else
                    "1rem 1rem 0.1rem 3rem"
            ]
        |> Html.map (UpdateMarkdown id)
        |> Tuple.pair (id ++ message.peer)
