module Lia.Markdown.Effect.View exposing
    ( block
    , inline
    , state
    )

import Accessibility.Key as A11y_Key
import Conditional.List as CList
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
import Lia.Voice as Voice
import Port.Event as Event exposing (Event)
import Port.TTS


circle_ : Int -> Html msg
circle_ =
    number
        >> Html.text
        >> List.singleton
        >> Html.span [ Attr.class "lia-effect__circle lia-effect__circle--inline" ]


number : Int -> String
number i =
    "\u{200A}" ++ String.fromInt i ++ "\u{200A}"


cleanUpNumber : String -> String
cleanUpNumber str =
    str ++ ".innerText.replace(/\\u200a\\d+\\u200a/g,'').trim()"


block : Config sub -> Model a -> Parameters -> Effect Markdown -> List (Html Msg) -> Html Msg
block config model attr e body =
    if config.visible == Nothing then
        case class e of
            Animation ->
                Html.div [ Attr.class "lia-effect" ] <|
                    [ circle e.begin
                    , Html.div (toAttribute attr) body
                    ]

            PlayBack ->
                Html.div [ Attr.class "lia-effect" ] <|
                    [ block_playback config e
                    , Html.div (toAttribute attr) body
                    ]

            PlayBackAnimation ->
                Html.div [ Attr.class "lia-effect" ] <|
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
                    [ inline_playback config e
                        :: body
                        |> Html.label []
                    ]

                PlayBackAnimation ->
                    circle_ e.begin
                        :: [ inline_playback config e
                                :: body
                                |> Html.label []
                           ]

    else
        case class e of
            Animation ->
                circle_ e.begin
                    :: Html.text " "
                    :: body
                    |> hiddenSpan (not <| isIn config.visible e) attr

            PlayBack ->
                [ inline_playback config e
                    :: body
                    |> Html.label []
                ]
                    |> hiddenSpan False attr

            PlayBackAnimation ->
                circle_ e.begin
                    :: [ inline_playback config e
                            :: body
                            |> Html.label []
                       ]
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
            [ Attr.class "lia-btn lia-btn--transparent text-highlight icon icon-stop-circle"
            , A11y_Key.tabbable True
            , e.id
                |> E.Mute
                |> UpdateEffect True
                |> onClick
            ]
            []

    else
        Html.button
            [ Attr.class "lia-btn lia-btn--transparent text-highlight icon icon-play-circle"
            , A11y_Key.tabbable True
            , playBackAttr e.id e.voice config.slide "this.parentNode.childNodes[1]"
            ]
            []


playBackAttr : Int -> String -> Int -> String -> Html.Attribute msg
playBackAttr id voice section command =
    "XXX"
        |> Port.TTS.playback id voice
        |> Event.encode
        |> Event "effect" section
        |> Event.encode
        |> JE.encode 0
        |> String.replace "\"XXX\"" (cleanUpNumber command)
        |> (\event -> "playback(" ++ event ++ ")")
        |> Attr.attribute "onclick"


inlinePlayBack config e body =
    case Voice.getVoiceFor e.voice config.translations of
        Nothing ->
            []

        Just ( translate, voice ) ->
            [ Attr.class <|
                if translate then
                    "translate"

                else
                    "notranslate"
            , Attr.attribute "translate" <|
                if translate then
                    "yes"

                else
                    "no"
            ]


inline_playback : Config sub -> Effect Inline -> Html msg
inline_playback config e =
    if config.speaking == Just e.id then
        Html.button
            [ Attr.class "lia-btn lia-btn--transparent icon icon-stop-circle mx-1"
            , Port.TTS.mute e.id
                |> Event.encode
                |> Event "effect" config.slide
                |> Event.encode
                |> JE.encode 0
                |> (\event -> "playback(" ++ event ++ ")")
                |> Attr.attribute "onclick"
            , A11y_Key.tabbable True
            ]
            []

    else
        Html.button
            [ Attr.class "lia-btn lia-btn--transparent icon icon-play-circle mx-1"
            , playBackAttr e.id e.voice config.slide "this.labels[0]"
            , A11y_Key.tabbable True
            ]
            []


circle : Int -> Html msg
circle id =
    Html.span
        [ Attr.class "lia-effect__circle" ]
        [ Html.text (number id) ]


state : Model a -> String
state model =
    if model.effects == 0 then
        ""

    else
        " (" ++ String.fromInt model.visible ++ "/" ++ String.fromInt model.effects ++ ")"
