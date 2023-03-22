module Lia.Chat.View exposing (view)

import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed as Keyed
import Lia.Chat.Model exposing (Model)
import Lia.Chat.Update exposing (Msg(..))
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Update as Markdown
import Lia.Markdown.View as Markdown
import Lia.Section exposing (Section)


view : (Section -> Config Markdown.Msg) -> Model -> Html Msg
view config model =
    Html.div
        [ Attr.style "background-color" "red"
        , Attr.style "width" "800px"
        , Attr.style "height" "100vh"
        , Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        ]
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
                ]
        , Html.div
            [ Attr.style "padding" "1rem"
            , Attr.style "height" "16rem"
            , Attr.id "parent"
            ]
            [ Editor.editor
                [ Editor.onChange Input
                , Editor.value model.input
                , Attr.style "min-height" "10rem"
                , Attr.style "width" "100%"
                , Editor.maxLines 4
                , Editor.mode "markdown"
                , Editor.showGutter False
                ]
                []
            , Html.button
                [ Event.onClick Send
                ]
                [ Html.text ">" ]
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
            [ Attr.style "padding" "1rem 1rem 0.1rem"
            , Attr.style "margin" "0.4rem 1rem"
            , Attr.style "border" "black solid 1px"
            ]
        |> Html.map (UpdateMarkdown id)
        |> Tuple.pair id
