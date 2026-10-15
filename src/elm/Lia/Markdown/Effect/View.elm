module Lia.Markdown.Effect.View exposing
    ( block
    , inline
    , state
    )

{-| Effects are rendered with their animation step as a circle and/or with
playback buttons. In textbook mode (`config.visible == Nothing`) everything
is shown, in presentation and slides mode only the effects of the current
animation step.
-}

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
import Service.Event as Event exposing (Event)
import Service.TTS


{-| A block effect with its `body`.
-}
block : Config sub -> Model a -> Parameters -> Effect Block -> List (Html Msg) -> Html Msg
block config model attr e body =
    let
        playbackFloat textbook =
            (::) (block_playback config e)
                >> Html.div
                    [ Attr.classList
                        [ ( "lia-effect", textbook )
                        , ( "lia-effect--playback-float", True )
                        , ( "lia-effect--speaking", config.speaking == Just e.id )
                        ]
                    ]

        animated =
            Html.div
                (attr
                    |> annotation "lia-effect__content"
                    |> CList.addIf (e.begin == model.visible) (Attr.id "focused")
                )
                body

        visible =
            isIn (Just model.visible) e
    in
    case ( config.visible, class e ) of
        ( _, PlayBack ) ->
            playbackFloat (config.visible == Nothing)
                [ Html.div (annotation "lia-effect__playback-content" attr) body ]

        ( Nothing, Animation ) ->
            Html.div [ Attr.class "lia-effect" ]
                [ circle "lia-effect__circle" e.begin
                , Html.div (toAttribute attr) body
                ]

        ( Nothing, PlayBackAnimation ) ->
            playbackFloat True
                [ Html.div [ Attr.class "lia-effect__playback-content" ]
                    [ circle "lia-effect__circle" e.begin
                    , Html.div (toAttribute attr) body
                    ]
                ]

        ( Just _, Animation ) ->
            if visible then
                Html.div [ Attr.class "lia-effect", A11y_Live.polite, A11y_Role.alert ]
                    [ circle "lia-effect__circle" e.begin
                    , animated
                    ]

            else
                Html.text ""

        ( Just _, PlayBackAnimation ) ->
            Html.div [ Attr.hidden (not visible) ]
                [ playbackFloat False
                    [ Html.div [ Attr.class "lia-effect lia-effect__playback-content", A11y_Live.polite, A11y_Role.alert ]
                        [ circle "lia-effect__circle" e.begin
                        , animated
                        ]
                    ]
                ]


{-| An inline effect with its `body`, invisible effects are hidden by CSS.
-}
inline : Config sub -> Parameters -> Effect Inline -> List (Html msg) -> Html msg
inline config attr e body =
    let
        hide =
            not (isIn config.visible e)

        speaking =
            config.speaking == Just e.id

        label =
            Html.label [] (inline_playback config e :: body)

        -- new animation steps are only announced in presentation and slides
        announce =
            config.visible /= Nothing
    in
    case class e of
        Animation ->
            -- only marked as speaking in textbook mode
            circle "lia-effect__circle lia-effect__circle--inline" e.begin
                :: Html.text " "
                :: body
                |> hiddenSpan announce hide (speaking && config.visible == Nothing) attr

        PlayBack ->
            hiddenSpan announce False speaking attr [ label ]

        PlayBackAnimation ->
            hiddenSpan announce hide speaking attr [ circle "lia-effect__circle lia-effect__circle--inline" e.begin, label ]


hiddenSpan : Bool -> Bool -> Bool -> Parameters -> List (Html msg) -> Html msg
hiddenSpan announce hide speaking attr =
    let
        alert =
            if announce then
                (::) A11y_Live.polite >> (::) A11y_Role.alert

            else
                identity
    in
    Html.span
        (if hide then
            annotation "lia-effect--inline hide" attr

         else if speaking then
            alert (annotation "lia-effect--inline lia-effect--speaking" attr)

         else
            alert (annotation "lia-effect--inline" attr)
        )


{-| Play/stop and pause/resume buttons of a block effect. The text to read out
is the content next to the buttons.
-}
block_playback : Config sub -> Effect Block -> Html Msg
block_playback config e =
    let
        isPaused =
            config.paused == Just e.id

        isActive =
            isPaused || config.speaking == Just e.id

        onclick =
            onPlayback config e "this.parentNode.parentNode.childNodes[1]"
    in
    Html.div [ Attr.class "lia-effect__playback-controls" ]
        [ button
            [ A11y_Key.tabbable True
            , onclick (playOrStop config e isActive)
            ]
            (if isActive then
                "Stop"

             else
                "Play"
            )
            (if isActive then
                "icon-stop"

             else
                "icon-play"
            )
            []
        , button
            [ A11y_Key.tabbable isActive
            , Attr.disabled (not isActive)
            , onclick
                (if isPaused then
                    Service.TTS.resume

                 else
                    Service.TTS.pause
                )
            ]
            (if isPaused then
                "Resume"

             else
                "Pause"
            )
            (if isPaused then
                "icon-play"

             else
                "icon-pause"
            )
            []
        ]


{-| Play/stop button of an inline effect, which reads out its label.
-}
inline_playback : Config sub -> Effect Inline -> Html msg
inline_playback config e =
    let
        isActive =
            config.speaking == Just e.id
    in
    button
        [ A11y_Key.tabbable True
        , onPlayback config e "this.labels[0]" (playOrStop config e isActive)
        ]
        (if isActive then
            "Stop"

         else
            "Play"
        )
        (if isActive then
            "icon-stop-circle"

         else
            "icon-play-circle"
        )
        [ Attr.style "padding" "0", Attr.style "margin" "0 5px 0 5px" ]


{-| A transparent icon button, `style` comes after the title.
-}
button : List (Html.Attribute msg) -> String -> String -> List (Html.Attribute msg) -> Html msg
button attr title icon style =
    Html.button
        (Attr.class "lia-btn lia-btn--transparent" :: attr ++ Attr.title title :: style)
        [ Html.span [ Attr.class ("lia-btn__icon icon " ++ icon) ] [] ]


{-| Stop an active playback or start reading with the voice of the effect,
which might be replaced by a voice of the translated language.
-}
playOrStop : Config sub -> Effect x -> Bool -> Event
playOrStop config e isActive =
    if isActive then
        Service.TTS.cancel

    else
        case config.translations |> Maybe.andThen (Voice.getVoiceFor e.voice) of
            Just { lang, name } ->
                Service.TTS.playback { voice = name, lang = lang, text = "XXX" }

            Nothing ->
                Service.TTS.playback
                    { voice = e.voice
                    , lang = e.voice |> Voice.getLang |> Maybe.withDefault "en"
                    , text = "XXX"
                    }


{-| An `onclick` that passes a playback `event` of the effect to
`window.LIA.playback`. The text to read out is only known in the browser,
the placeholder `"XXX"` is replaced by the JavaScript expression `text`.
-}
onPlayback : Config sub -> Effect x -> String -> Event -> Html.Attribute msg
onPlayback config e text event =
    event
        |> Event.pushWithId "playback" e.id
        |> Event.pushWithId "effect" config.slide
        |> Event.encode
        |> JE.encode 0
        |> String.replace "\"XXX\"" text
        |> (\json -> "window.LIA.playback(" ++ json ++ ")")
        |> Attr.attribute "onclick"


circle : String -> Int -> Html msg
circle className i =
    Html.span [ Attr.class className ] [ Html.text ("\u{200A}" ++ String.fromInt i ++ "\u{200A}") ]


{-| The animation progress `" (visible/effects)"`, empty without effects.
-}
state : Model a -> String
state model =
    if model.effects == 0 then
        ""

    else
        " (" ++ String.fromInt model.visible ++ "/" ++ String.fromInt model.effects ++ ")"
