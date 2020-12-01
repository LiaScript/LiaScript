module Lia.Markdown.Effect.View exposing
    ( block
    , inline
    , responsive
    , state
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Json.Encode as JE
import Lia.Markdown.Effect.Model exposing (Model)
import Lia.Markdown.Effect.Types exposing (Class(..), Effect, class, isIn)
import Lia.Markdown.Effect.Update as E
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Stringify as I
import Lia.Markdown.Inline.Types exposing (Inline)
import Lia.Markdown.Stringify exposing (stringify)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode(..))
import Port.Event as Event exposing (Event)
import Port.TTS
import Translations exposing (Lang, soundOff, soundOn)


circle_ : Int -> Html msg
circle_ idx =
    idx
        |> String.fromInt
        |> Html.text
        |> List.singleton
        |> Html.span [ Attr.class "lia-effect-circle-inline" ]


block : Config sub -> Model a -> Parameters -> Effect Markdown -> List (Html Msg) -> Html Msg
block config model attr e body =
    if contradiction e.begin e.end then
        Html.text ""

    else if config.visible == Nothing then
        Html.div [] <|
            case class e of
                Animation ->
                    [ circle e.begin
                    , Html.div (annotation "" []) body
                    ]

                PlayBack ->
                    [ block_playback config e
                    , Html.div (annotation "" []) body
                    ]

                PlayBackAnimation ->
                    [ block_playback config e
                    , Html.div []
                        [ circle e.begin
                        , Html.div (annotation "" []) body
                        ]
                    ]

    else
        let
            visible =
                isIn (Just model.visible) e
        in
        case class e of
            Animation ->
                if not visible then
                    Html.text ""

                else
                    Html.div []
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
                    [ block_playback config e
                    , Html.div
                        (annotation "" [])
                        body
                    ]

            PlayBackAnimation ->
                Html.div [ Attr.hidden (not visible) ] <|
                    [ block_playback config e
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


contradiction : Int -> Maybe Int -> Bool
contradiction begin end =
    --Maybe.withDefault 999999 >> (>) begin
    False


inline : Config sub -> Parameters -> Effect Inline -> List (Html msg) -> Html msg
inline config attr e body =
    if contradiction e.begin e.end then
        Html.text ""

    else if config.visible == Nothing then
        case class e of
            Animation ->
                circle_ e.begin
                    :: Html.text " "
                    :: body
                    |> Html.span
                        (Attr.id (String.fromInt e.begin)
                            :: annotation "" []
                        )

            PlayBack ->
                inline_playback config e
                    :: body
                    |> Html.span (annotation "" attr)

            PlayBackAnimation ->
                circle_ e.begin
                    :: inline_playback config e
                    :: body
                    |> Html.span
                        (Attr.id (String.fromInt e.begin)
                            :: annotation "" []
                        )

    else
        case class e of
            Animation ->
                Html.span
                    [ if isIn config.visible e then
                        Attr.hidden False

                      else
                        Attr.hidden True
                    ]
                    [ circle_ e.begin
                        :: Html.text " "
                        :: body
                        |> Html.span
                            (Attr.id (String.fromInt e.begin)
                                :: annotation
                                    (if attr == [] then
                                        "lia-effect"

                                     else
                                        ""
                                    )
                                    attr
                            )
                    ]

            PlayBack ->
                inline_playback config e
                    :: body
                    |> Html.span (annotation "" attr)

            PlayBackAnimation ->
                Html.span
                    [ if isIn config.visible e then
                        Attr.hidden False

                      else
                        Attr.hidden True
                    ]
                    [ circle_ e.begin
                        :: inline_playback config e
                        :: body
                        |> Html.span
                            (Attr.id (String.fromInt e.begin)
                                :: annotation
                                    (if attr == [] then
                                        "lia-effect"

                                     else
                                        ""
                                    )
                                    attr
                            )
                    ]


block_playback : Config sub -> Effect Markdown -> Html Msg
block_playback config e =
    if config.speaking == Just e.id then
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
                |> List.map (stringify config.scripts config.visible)
                |> List.intersperse "\n"
                |> String.concat
                |> E.Speak e.id e.voice
                |> UpdateEffect True
                |> onClick
            ]
            [ Html.text "play_arrow" ]


inline_playback : Config sub -> Effect Inline -> Html msg
inline_playback config e =
    if config.speaking == Just e.id then
        Html.button
            [ Attr.class "lia-btn lia-icon"
            , Attr.style "scale" "0.65"
            , Attr.style "margin" "0px"
            , Port.TTS.mute e.id
                |> Event.encode
                |> Event "effect" config.slide
                |> Event.encode
                |> JE.encode 0
                |> (\event -> "playback(" ++ event ++ ")")
                |> Attr.attribute "onclick"
            ]
            [ Html.text "stop" ]

    else
        Html.button
            [ Attr.class "lia-btn lia-icon"
            , Attr.style "scale" "0.65"
            , Attr.style "margin" "0px"
            , e.content
                |> I.stringify
                |> Port.TTS.playback e.id e.voice
                |> Event.encode
                |> Event "effect" config.slide
                |> Event.encode
                |> JE.encode 0
                |> (\event -> "playback(" ++ event ++ ")")
                |> Attr.attribute "onclick"
            ]
            [ Html.text "play_arrow" ]


circle : Int -> Html msg
circle id =
    Html.span
        [ Attr.class "lia-effect-circle" ]
        [ Html.text (String.fromInt id) ]


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


state : Model a -> String
state model =
    if model.effects == 0 then
        ""

    else
        " (" ++ String.fromInt (model.visible + 1) ++ "/" ++ String.fromInt (model.effects + 1) ++ ")"
