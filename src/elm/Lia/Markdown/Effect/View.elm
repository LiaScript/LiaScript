module Lia.Markdown.Effect.View exposing
    ( block
    , inline
    , state
    )

import Conditional.List as CList
import Element exposing (Attr)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Json.Encode as JE
import Lia.Markdown.Effect.Model exposing (Model)
import Lia.Markdown.Effect.Types exposing (Class(..), Effect, class, isIn)
import Lia.Markdown.Effect.Update as E
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Stringify as I
import Lia.Markdown.Inline.Types exposing (Inline)
import Lia.Markdown.Stringify exposing (stringify)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Settings.Types exposing (Mode(..))
import Port.Event as Event exposing (Event)
import Port.TTS


circle_ : Int -> Html msg
circle_ =
    String.fromInt
        >> Html.text
        >> List.singleton
        >> Html.span [ Attr.class "lia-effect__circle lia-effect__circle--inline" ]


block : Config sub -> Model a -> Parameters -> Effect Markdown -> List (Html Msg) -> Html Msg
block config model attr e body =
    if config.visible == Nothing then
        Html.div [ Attr.class "lia-effect" ] <|
            case class e of
                Animation ->
                    [ circle e.begin
                    , Html.div (toAttribute attr) body
                    ]

                PlayBack ->
                    [ block_playback config e
                    , Html.div (toAttribute attr) body
                    ]

                PlayBackAnimation ->
                    [ block_playback config e
                    , Html.div []
                        [ circle e.begin
                        , Html.div (toAttribute attr) body
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
                    Html.div [ Attr.class "lia-effect" ]
                        [ circle e.begin
                        , Html.div
                            (attr
                                |> annotation "lia-effect__content"
                                |> CList.addIf (e.begin == model.visible) (Attr.id "focused")
                            )
                            body
                        ]

            PlayBack ->
                Html.div []
                    [ block_playback config e
                    , Html.div (toAttribute attr) body
                    ]

            PlayBackAnimation ->
                Html.div [ Attr.hidden (not visible) ] <|
                    [ block_playback config e
                    , Html.div [ Attr.class "lia-effect" ]
                        [ circle e.begin
                        , Html.div
                            (attr
                                |> annotation "lia-effect__content"
                                |> CList.addIf (e.begin == model.visible) (Attr.id "focused")
                            )
                            body
                        ]
                    ]


inline : Config sub -> Parameters -> Effect Inline -> List (Html msg) -> Html msg
inline config attr e body =
    if config.visible == Nothing then
        hiddenSpan False attr <|
            case class e of
                Animation ->
                    circle_ e.begin :: Html.text " " :: body

                PlayBack ->
                    inline_playback config e :: body

                PlayBackAnimation ->
                    circle_ e.begin :: inline_playback config e :: body

    else
        case class e of
            Animation ->
                circle_ e.begin
                    :: Html.text " "
                    :: body
                    |> hiddenSpan (not <| isIn config.visible e) attr

            PlayBack ->
                inline_playback config e
                    :: body
                    |> hiddenSpan False attr

            PlayBackAnimation ->
                circle_ e.begin
                    :: inline_playback config e
                    :: body
                    |> hiddenSpan (not <| isIn config.visible e) attr


hiddenSpan : Bool -> Parameters -> List (Html msg) -> Html msg
hiddenSpan hide =
    annotation
        (if hide then
            "lia-effect--inline hide"

         else
            "lia-effect--inline"
        )
        >> Html.span


block_playback : Config sub -> Effect Markdown -> Html Msg
block_playback config e =
    if config.speaking == Just e.id then
        Html.button
            [ Attr.class "lia-btn"
            , e.id
                |> E.Mute
                |> UpdateEffect True
                |> onClick
            ]
            [ Html.text "stop" ]

    else
        Html.button
            [ Attr.class "lia-btn"
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
            [ Attr.class "lia-btn"
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
            [ Attr.class "lia-btn"
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
        [ Attr.class "lia-effect__circle" ]
        [ Html.text (String.fromInt id) ]


state : Model a -> String
state model =
    if model.effects == 0 then
        ""

    else
        " (" ++ String.fromInt model.visible ++ "/" ++ String.fromInt model.effects ++ ")"
