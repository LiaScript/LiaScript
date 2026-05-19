module Lia.Markdown.Effect.View exposing
    ( block
    , inline
    , state
    )

import Accessibility.Key as A11y_Key
import Accessibility.Live as A11y_Live
import Accessibility.Role as A11y_Role
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Effect.Model exposing (Model)
import Lia.Markdown.Effect.Types exposing (Class(..), Effect, class, isIn)
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inline)
import Lia.Markdown.Types exposing (Block)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Voice as Voice
import Service.Event as Event
import Service.TTS


pausePlaybackAttr : Int -> Int -> Html.Attribute msg
pausePlaybackAttr id section =
    Service.TTS.pause
        |> Event.pushWithId "playback" id
        |> Event.pushWithId "effect" section
        |> Event.encode
        |> JE.encode 0
        |> (\event -> "window.LIA.playback(" ++ event ++ ")")
        |> Attr.attribute "onclick"


resumePlaybackAttr : Int -> Int -> Html.Attribute msg
resumePlaybackAttr id section =
    Service.TTS.resume
        |> Event.pushWithId "playback" id
        |> Event.pushWithId "effect" section
        |> Event.encode
        |> JE.encode 0
        |> (\event -> "window.LIA.playback(" ++ event ++ ")")
        |> Attr.attribute "onclick"


circle_ : Int -> Html msg
circle_ =
    number
        >> Html.text
        >> List.singleton
        >> Html.span [ Attr.class "lia-effect__circle lia-effect__circle--inline" ]


number : Int -> String
number i =
    "\u{200A}" ++ String.fromInt i ++ "\u{200A}"


block : Config sub -> Model a -> Parameters -> Effect Block -> List (Html Msg) -> Html Msg
block config model attr e body =
    if config.visible == Nothing then
        case class e of
            Animation ->
                Html.div [ Attr.class "lia-effect" ] <|
                    [ circle e.begin
                    , Html.div (toAttribute attr) body
                    ]

            PlayBack ->
                Html.div
                    [ Attr.classList
                        [ ( "lia-effect", True )
                        , ( "lia-effect--playback-float", True )
                        , ( "lia-effect--speaking", config.speaking == Just e.id )
                        ]
                    ]
                <|
                    [ block_playback config e
                    , Html.div (annotation "lia-effect__playback-content" attr) body
                    ]

            PlayBackAnimation ->
                Html.div
                    [ Attr.classList
                        [ ( "lia-effect", True )
                        , ( "lia-effect--playback-float", True )
                        , ( "lia-effect--speaking", config.speaking == Just e.id )
                        ]
                    ]
                <|
                    [ block_playback config e
                    , Html.div [ Attr.class "lia-effect__playback-content" ]
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
                    Html.div [ Attr.class "lia-effect", A11y_Live.polite, A11y_Role.alert ] <|
                        [ circle e.begin
                        , Html.div
                            (attr
                                |> annotation "lia-effect__content"
                                |> CList.addIf (e.begin == model.visible) (Attr.id "focused")
                            )
                            body
                        ]

            PlayBack ->
                Html.div
                    [ Attr.classList
                        [ ( "lia-effect--playback-float", True )
                        , ( "lia-effect--speaking", config.speaking == Just e.id )
                        ]
                    ]
                <|
                    [ block_playback config e
                    , Html.div (annotation "lia-effect__playback-content" attr) body
                    ]

            PlayBackAnimation ->
                Html.div [ Attr.hidden (not visible) ] <|
                    [ Html.div
                        [ Attr.classList
                            [ ( "lia-effect--playback-float", True )
                            , ( "lia-effect--speaking", config.speaking == Just e.id )
                            ]
                        ]
                      <|
                        [ block_playback config e
                        , Html.div [ Attr.class "lia-effect lia-effect__playback-content", A11y_Live.polite, A11y_Role.alert ]
                            [ circle e.begin
                            , Html.div
                                (attr
                                    |> annotation "lia-effect__content"
                                    |> CList.addIf (e.begin == model.visible) (Attr.id "focused")
                                )
                                body
                            ]
                        ]
                    ]


inline : Config sub -> Parameters -> Effect Inline -> List (Html msg) -> Html msg
inline config attr e body =
    if config.visible == Nothing then
        hiddenSpan False (config.speaking == Just e.id) attr <|
            case class e of
                Animation ->
                    circle_ e.begin :: Html.text " " :: body

                PlayBack ->
                    [ inline_playback config e
                        :: body
                        |> Html.label []
                    ]

                PlayBackAnimation ->
                    [ circle_ e.begin
                    , inline_playback config e
                        :: body
                        |> Html.label []
                    ]

    else
        case class e of
            Animation ->
                circle_ e.begin
                    :: Html.text " "
                    :: body
                    |> hiddenSpan (not <| isIn config.visible e) False attr

            PlayBack ->
                [ inline_playback config e
                    :: body
                    |> Html.label []
                ]
                    |> hiddenSpan False (config.speaking == Just e.id) attr

            PlayBackAnimation ->
                [ circle_ e.begin
                , inline_playback config e
                    :: body
                    |> Html.label []
                ]
                    |> hiddenSpan (not <| isIn config.visible e) (config.speaking == Just e.id) attr


hiddenSpan : Bool -> Bool -> Parameters -> List (Html msg) -> Html msg
hiddenSpan hide speaking attr =
    Html.span
        (if hide then
            annotation "lia-effect--inline hide" attr

         else
            let
                className =
                    if speaking then
                        "lia-effect--inline lia-effect--speaking"

                    else
                        "lia-effect--inline"
            in
            A11y_Live.polite :: A11y_Role.alert :: annotation className attr
        )


block_playback : Config sub -> Effect Block -> Html Msg
block_playback config e =
    let
        isPaused =
            config.paused == Just e.id

        isActive =
            isPaused || config.speaking == Just e.id

        stopAttr =
            Service.TTS.cancel
                |> Event.pushWithId "playback" e.id
                |> Event.pushWithId "effect" config.slide
                |> Event.encode
                |> JE.encode 0
                |> (\ev -> "window.LIA.playback(" ++ ev ++ ")")
                |> Attr.attribute "onclick"

        playAttr =
            case config.translations |> Maybe.andThen (Voice.getVoiceFor e.voice) of
                Nothing ->
                    playBackAttr e.id
                        e.voice
                        (e.voice |> Voice.getLang |> Maybe.withDefault "en")
                        config.slide
                        "this.parentNode.parentNode.childNodes[1]"

                Just { lang, name } ->
                    playBackAttr e.id name lang config.slide "this.parentNode.parentNode.childNodes[1]"
    in
    Html.div [ Attr.class "lia-effect__playback-controls" ]
        [ Html.button
            [ Attr.class "lia-btn lia-btn--transparent"
            , A11y_Key.tabbable True
            , if isActive then stopAttr else playAttr
            , Attr.title
                (if isActive then
                    "Stop"

                 else
                    "Play"
                )
            ]
            [ Html.span
                [ Attr.class
                    ("lia-btn__icon icon "
                        ++ (if isActive then
                                "icon-stop"

                            else
                                "icon-play"
                           )
                    )
                ]
                []
            ]
        , Html.button
            [ Attr.class "lia-btn lia-btn--transparent"
            , A11y_Key.tabbable isActive
            , Attr.disabled (not isActive)
            , if isPaused then
                resumePlaybackAttr e.id config.slide

              else
                pausePlaybackAttr e.id config.slide
            , Attr.title
                (if isPaused then
                    "Resume"

                 else
                    "Pause"
                )
            ]
            [ Html.span
                [ Attr.class
                    ("lia-btn__icon icon "
                        ++ (if isPaused then
                                "icon-play"

                            else
                                "icon-pause"
                           )
                    )
                ]
                []
            ]
        ]


playBackAttr : Int -> String -> String -> Int -> String -> Html.Attribute msg
playBackAttr id voice lang section command =
    Service.TTS.playback { voice = voice, lang = lang, text = "XXX" }
        |> Event.pushWithId "playback" id
        |> Event.pushWithId "effect" section
        |> Event.encode
        |> JE.encode 0
        |> String.replace "\"XXX\"" command
        |> (\event -> "window.LIA.playback(" ++ event ++ ")")
        |> Attr.attribute "onclick"


inline_playback : Config sub -> Effect Inline -> Html msg
inline_playback config e =
    let
        isActive =
            config.speaking == Just e.id

        stopAttr =
            Service.TTS.cancel
                |> Event.pushWithId "playback" e.id
                |> Event.pushWithId "effect" config.slide
                |> Event.encode
                |> JE.encode 0
                |> (\ev -> "window.LIA.playback(" ++ ev ++ ")")
                |> Attr.attribute "onclick"

        playAttr =
            case config.translations |> Maybe.andThen (Voice.getVoiceFor e.voice) of
                Nothing ->
                    playBackAttr e.id
                        e.voice
                        (e.voice |> Voice.getLang |> Maybe.withDefault "en")
                        config.slide
                        "this.labels[0]"

                Just { lang, name } ->
                    playBackAttr e.id name lang config.slide "this.labels[0]"
    in
    Html.button
        [ Attr.class "lia-btn lia-btn--transparent"
        , A11y_Key.tabbable True
        , if isActive then stopAttr else playAttr
        , Attr.title (if isActive then "Stop" else "Play")
        , Attr.style "padding" "0"
        , Attr.style "margin" "0 5px 0 5px"
        ]
        [ Html.span
            [ Attr.class ("lia-btn__icon icon " ++ (if isActive then "icon-stop-circle" else "icon-play-circle")) ]
            []
        ]


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
