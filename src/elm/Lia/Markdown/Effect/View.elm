module Lia.Markdown.Effect.View exposing
    ( block
    , comment
    , responsive
    , state
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Effect.Model exposing (Model)
import Lia.Markdown.Effect.Types exposing (Class(..), Effect, class)
import Lia.Markdown.Effect.Update as E
import Lia.Markdown.Inline.Annotation exposing (Annotation, annotation)
import Lia.Markdown.Stringify exposing (stringify)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode(..))
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


block : Model -> Mode -> Annotation -> Effect Markdown -> List (Html Msg) -> Html Msg
block model mode attr e body =
    if mode == Textbook then
        Html.div [] <|
            case class e of
                Animation ->
                    [ circle e.begin
                    , Html.div (annotation "" Nothing) body
                    ]

                PlayBack ->
                    [ block_playback model.speaking e
                    , Html.div (annotation "" Nothing) body
                    ]

                PlayBackAnimation ->
                    [ block_playback model.speaking e
                    , Html.div []
                        [ circle e.begin
                        , Html.div (annotation "" Nothing) body
                        ]
                    ]

    else
        let
            visible =
                (e.begin <= model.visible)
                    && (e.end > model.visible)
        in
        case class e of
            Animation ->
                Html.div [ Attr.hidden (not visible) ] <|
                    [ circle e.begin
                    , Html.div
                        ((Attr.id <|
                            if e.begin == model.visible then
                                "focused"

                            else
                                String.fromInt e.begin
                         )
                            :: annotation "lia-effect" attr
                        )
                        body
                    ]

            PlayBack ->
                Html.div []
                    [ block_playback model.speaking e
                    , Html.div
                        (annotation "" Nothing)
                        body
                    ]

            PlayBackAnimation ->
                Html.div [ Attr.hidden (not visible) ] <|
                    [ block_playback model.speaking e
                    , Html.div []
                        [ circle e.begin
                        , Html.div
                            ((Attr.id <|
                                if e.begin == model.visible then
                                    "focused"

                                else
                                    String.fromInt e.begin
                             )
                                :: annotation "lia-effect" attr
                            )
                            body
                        ]
                    ]


block_playback : Maybe Int -> Effect Markdown -> Html Msg
block_playback speaking e =
    if speaking == Just e.id then
        Html.button
            [ Attr.class "lia-btn lia-icon"
            , Attr.style "margin-left" "49%"
            , e.id
                |> E.Mute
                |> UpdateEffect True
                |> onClick
            ]
            [ Html.text "stop" ]

    else
        Html.button
            [ Attr.class "lia-btn lia-icon"
            , Attr.style "margin-left" "49%"
            , e.content
                |> List.map stringify
                |> List.intersperse "\n"
                |> String.concat
                |> E.Speak e.id e.voice
                |> UpdateEffect True
                |> onClick
            ]
            [ Html.text "play_arrow" ]


circle : Int -> Html msg
circle id =
    Html.span
        [ Attr.class "lia-effect-circle" ]
        [ Html.text (String.fromInt id) ]


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
        Html.text ""


responsive : Lang -> Bool -> msg -> Html msg
responsive lang sound msg =
    Html.span [ Attr.id "lia-span-responsive" ]
        [ Html.button
            [ Attr.class "lia-btn lia-icon"
            , Attr.id "lia-btn-sound"
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
