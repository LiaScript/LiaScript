module Lia.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Array
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (on, onClick)
import Html.Keyed as Keyed
import I18n.Translations as Trans exposing (Lang)
import Json.Decode as JD
import Lia.Chat.View as Chat
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Index.View as Index
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.View exposing (state)
import Lia.Markdown.HTML.Attributes exposing (toAttribute)
import Lia.Markdown.Inline.View exposing (audio, onError, view_inf)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Section exposing (Section, SubSection)
import Lia.Settings.Types exposing (Mode(..), PlaybackState(..), Settings, TTS)
import Lia.Settings.Update as Settings_
import Lia.Settings.View as Settings
import Lia.Sync.Types as Sync_
import Lia.Sync.Update as SyncUpdate
import Lia.Sync.View as Sync
import Lia.Update exposing (Msg(..), get_active_section)
import Lia.Utils exposing (deactivate, modal, newTab, newTabHint)
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane
import Session exposing (Screen)


{-| Main view for the entire LiaScript model with the parameters:

1.  `screen`: width and height of the window
2.  `hasShareAPI`: will enable sharing vie the `navigation.share` api, otherwise
    create an QR-code with the entire course-URL
3.  `hasIndex`: display a home-button or not
4.  `model`: the preprocessed LiaScript Model

-}
view : Screen -> Bool -> Model -> Html Msg
view screen hasIndex model =
    let
        modalIsActive =
            isHidden model
    in
    Html.div
        (Settings.design model.settings)
        (Html.a
            (deactivate modalIsActive
                [ Attr.class "lia-skip-nav"
                , model.section_active
                    |> (+) 1
                    |> String.fromInt
                    |> (++) "#"
                    |> Attr.href
                ]
            )
            [ Html.text (Trans.baseSkipNav model.translation) ]
            :: newTabHint model.translation
            :: viewIndex modalIsActive hasIndex model
            :: viewSlide modalIsActive screen model
            ++ [ Settings.viewOfflineStatus model.translation model.settings.offline ]
        )


{-| **@private:** Display the side section that contains the document search,
table of contents and the home button.
-}
viewIndex : Bool -> Bool -> Model -> Html Msg
viewIndex modalIsActive hasIndex model =
    Html.div
        (deactivate modalIsActive
            [ Attr.class "lia-toc"
            , Attr.id "lia-toc"
            , Attr.class <|
                if model.settings.table_of_contents then
                    "lia-toc--open"

                else
                    "lia-toc--closed"
            , A11y_Landmark.navigation
            , A11y_Aria.label (Trans.baseToc model.translation)
            ]
        )
        [ Settings.btnIndex
            model.translation
            model.settings.table_of_contents
            |> Html.map UpdateSettings
        , model.index_model.search
            |> Index.search
                model.translation
                model.settings.table_of_contents
                model.sections
            |> Html.div
                [ Attr.class "lia-toc__search"
                , A11y_Landmark.search
                ]
            |> Html.map UpdateIndex
        , model.sections
            |> Index.content
                model.translation
                model.settings.table_of_contents
                model.section_active
                Script
                UpdateIndex
                model.index_model
            |> Html.div
                [ Attr.class "lia-toc__content"
                , A11y_Key.tabbable False
                ]
        , if hasIndex then
            Html.div [ Attr.class "lia-toc__bottom" ]
                [ Index.bottom
                    model.translation
                    model.settings.table_of_contents
                    Home
                ]

          else
            Html.text ""
        ]


{-| **@private:** show the current section, with navigation on top as well as a
footer, if it is required by the current display mode.
-}
viewSlide : Bool -> Screen -> Model -> List (Html Msg)
viewSlide modalIsActive screen model =
    case get_active_section model of
        Just section ->
            [ Html.div (deactivate modalIsActive [ Attr.class "lia-slide" ])
                [ slideTopBar screen
                    model
                    (Definition.merge model.definition section.definition)
                    (viewProgress model section.effect_model)
                , viewPanes screen model
                , slideBottom
                    { lang = model.translation
                    , tiny = screen.width < 400
                    , settings = model.settings
                    , slide = model.section_active
                    , effects = section.effect_model
                    , translated = model.langCodeOriginal /= model.langCode
                    }
                ]
            , slideA11y
                { lang = model.translation
                , light = model.settings.light
                , tooltips = model.settings.tooltips && (screen.width >= Const.tooltipBreakpoint)
                , translations = { old = model.langCodeOriginal, new = model.langCode, name = model.langName }
                , mode = model.settings.mode
                , formulas = model.definition.formulas
                , media = model.media
                , effect = Markdown.hideUnsolvedComments section
                , id = model.section_active
                , modalIsActive = modalIsActive
                }
            , viewVideoComment
                { active = model.settings.sound
                , hide = model.settings.hideVideoComments || model.settings.mode == Textbook
                , avatar = model.settings.tts.avatar
                }
                model.overlayVideo
                section.effect_model
            , showModal model
            ]

        Nothing ->
            [ Html.div [ Attr.class "lia-slide" ]
                [ slideTopBar screen model model.definition "0px"
                , Html.text "Ups, something went wrong"
                ]
            ]


{-| **@private:** The progress bar width (CSS), in Textbook mode per section,
otherwise the share of the current section is split by its animation steps.
-}
viewProgress : Model -> Effect.Model SubSection -> String
viewProgress model effect_model =
    let
        toPercent val =
            (toFloat val * 100.0) / toFloat (Array.length model.sections)
    in
    (case model.settings.mode of
        Textbook ->
            toPercent (model.section_active + 1)

        _ ->
            (toPercent 1 / toFloat (effect_model.effects + 1))
                * toFloat (effect_model.visible + 1)
                + toPercent model.section_active
    )
        |> String.fromFloat
        |> (\percent -> percent ++ "%")


viewPanes : Screen -> Model -> Html Msg
viewPanes screen model =
    Html.div
        [ Attr.class "lia-slide__container"
        ]
        [ SplitPane.view (Trans.baseResize model.translation)
            (case
                ( model.settings.chat.show
                , Sync_.isConnected model.sync.state
                , screen.width > Const.globalBreakpoints.sm
                )
             of
                ( True, True, True ) ->
                    SplitPane.Both

                ( True, True, False ) ->
                    SplitPane.OnlySecond

                _ ->
                    SplitPane.OnlyFirst
            )
            Pane
            (model.sections
                |> Array.toIndexedList
                |> List.map (showSection model screen)
                |> Html.div [ Attr.class "lia-slide__container" ]
            )
            (Chat.view model.translation
                model.settings.light
                (initConfig screen model)
                (if Sync_.isRoot model.sync then
                    model.sync.peersHistory

                 else
                    model.sync.peers
                )
                model.chat
                |> Html.map UpdateChat
            )
            model.pane
        ]


initConfig : Screen -> Model -> Section -> Config sub
initConfig screen model =
    Config.init
        model.translation
        { old = model.langCodeOriginal, new = model.langCode, name = model.langName }
        model.settings
        model.sync
        screen
        model.section_active
        (Just model.definition.formulas)
        model.media


showSection : Model -> Screen -> ( Int, Section ) -> Html Msg
showSection model screen ( id, section ) =
    let
        hidden =
            model.section_active /= id

        persistent =
            Maybe.withDefault model.persistent section.persistent
    in
    if hidden && not persistent && section.error == Nothing then
        Markdown.viewHidden

    else
        initConfig screen model section
            |> Markdown.view hidden persistent
            |> Html.map UpdateMarkdown


{-| **@private:** used to display the text2speech output settings and spoken
comments in text, depending on the currently applied rendering mode.
-}
slideBottom : { lang : Lang, tiny : Bool, settings : Settings, slide : Int, effects : Effect.Model SubSection, translated : Bool } -> Html Msg
slideBottom { lang, tiny, settings, slide, effects, translated } =
    Html.footer
        [ Attr.class "lia-slide__footer" ]
        [ slideNavigation lang settings.mode slide effects
        , case settings.mode of
            Textbook ->
                Html.text ""

            _ ->
                let
                    sound =
                        settings.sound && Effect.hasComments effects

                    -- translations are spoken by TTS, the recordings are muted
                    recordings =
                        if translated then
                            []

                        else
                            Effect.getAudioRecordings effects ++ Effect.getVideoRecordings effects

                    embeds =
                        if translated then
                            []

                        else
                            Effect.getEmbedVideoRecordings effects

                    -- only YouTube and Vimeo report their progress and can be paused
                    controllable =
                        List.all (\embed -> embed.provider == "youtube" || embed.provider == "vimeo") embeds
                in
                Html.div
                    [ Attr.class "lia-responsive-voice"
                    , if tiny then
                        Attr.style "padding" "0px"

                      else
                        Attr.class ""
                    ]
                    [ Html.div [ Attr.class "lia-responsive-voice__control" ]
                        [ Html.div
                            [ Attr.class "lia-responsive-voice__playgroup" ]
                            [ btnReplay lang sound settings
                            , if controllable then
                                btnPause lang sound settings

                              else
                                Html.text ""
                            ]
                        , Html.div [ Attr.class "lia-responsive-voice__center" ]
                            [ audioProgressSlider lang sound (not (List.isEmpty recordings) || (controllable && not (List.isEmpty embeds))) settings
                            , responsiveVoice
                                { lang = lang
                                , tiny = tiny
                                , show = sound
                                , tts = settings.tts
                                , audio = recordings
                                , embedded = not (List.isEmpty embeds)
                                }
                            ]
                        , btnStop lang settings
                        ]
                    ]
        ]


btnReplay : Lang -> Bool -> Settings -> Html Msg
btnReplay lang soundEnabled settings =
    let
        isActive =
            settings.playback /= Idle
    in
    Lia.Utils.btnIcon
        { title =
            if isActive then
                Trans.baseStop lang

            else
                Trans.basePlay lang
        , tabbable = settings.sound
        , msg =
            if soundEnabled && settings.sound then
                Just (TTSReplay (not isActive))

            else
                Nothing
        , icon =
            if isActive then
                "icon-stop"

            else
                "icon-play"
        }
        [ Attr.class "lia-btn--transparent lia-responsive-voice__play " ]


btnPause : Lang -> Bool -> Settings -> Html Msg
btnPause lang soundEnabled settings =
    let
        isPaused =
            case settings.playback of
                Paused ->
                    True

                PausedWithProgress _ ->
                    True

                SeekingFromPaused _ ->
                    True

                _ ->
                    False

        enabled =
            soundEnabled && settings.sound && settings.playback /= Idle
    in
    Lia.Utils.btnIcon
        { title =
            if isPaused then
                Trans.ttsResume lang

            else
                Trans.ttsPause lang
        , tabbable = enabled
        , msg =
            if not enabled then
                Nothing

            else if isPaused then
                Just TTSResume

            else
                Just TTSPause
        , icon =
            if isPaused then
                "icon-play"

            else
                "icon-pause"
        }
        [ Attr.class "lia-btn--transparent"
        , Attr.disabled (not enabled)
        ]


audioProgressSlider : Lang -> Bool -> Bool -> Settings -> Html Msg
audioProgressSlider lang soundEnabled hasRecordings settings =
    let
        ( progress, isSeeking ) =
            case settings.playback of
                SpeakingWithProgress p ->
                    ( Just p, False )

                PausedWithProgress p ->
                    ( Just p, False )

                SeekingFromPlaying p ->
                    ( Just p, True )

                SeekingFromPaused p ->
                    ( Just p, True )

                _ ->
                    ( Nothing, False )

        ( current, total ) =
            progress
                |> Maybe.map (\p -> ( p.current, p.total ))
                |> Maybe.withDefault ( 0, 1 )

        visible =
            soundEnabled && settings.sound && progress /= Nothing && total > 0
    in
    Html.div
        [ Attr.class "lia-tts-progress"
        , Attr.style "display"
            (if hasRecordings && settings.sound then
                "flex"

             else
                "none"
            )
        ]
        [ Html.input
            ([ Attr.type_ "range"
             , Attr.disabled (not visible)
             , Attr.min "0"
             , Attr.max (String.fromFloat total)
             , Attr.step "0.1"
             , Attr.class "lia-tts-progress__slider"
             , A11y_Aria.label (Trans.ttsPosition lang)
             , Attr.attribute "aria-valuetext" (minutes current ++ " " ++ Trans.ttsOf lang ++ " " ++ minutes total)
             , on "mousedown" (JD.succeed TTSStartSeeking)
             , on "touchstart" (JD.succeed TTSStartSeeking)
             , on "change"
                (JD.map
                    (\s ->
                        case String.toFloat s of
                            Just seconds ->
                                TTSSeek seconds

                            Nothing ->
                                TTSSeek current
                    )
                    (JD.at [ "target", "value" ] JD.string)
                )
             ]
                ++ (if isSeeking then
                        []

                    else
                        [ Attr.value (String.fromFloat current) ]
                   )
            )
            []
        ]


btnStop : Lang -> Settings -> Html Msg
btnStop lang settings =
    Lia.Utils.btnIcon
        { title =
            if settings.sound then
                Trans.soundOn lang

            else
                Trans.soundOff lang
        , tabbable = True
        , msg = Just (UpdateSettings Settings_.toggle_sound)
        , icon =
            if settings.sound then
                "icon-sound-on"

            else
                "icon-sound-off"
        }
        [ Attr.id "lia-btn-sound", Attr.class "lia-btn--transparent" ]


slideA11y :
    { lang : Lang
    , light : Bool
    , tooltips : Bool
    , translations : { old : String, new : String, name : Maybe String }
    , mode : Mode
    , formulas : Dict String String
    , media : Dict String ( Int, Int )
    , effect : Effect.Model SubSection
    , id : Int
    , modalIsActive : Bool
    }
    -> Html Msg
slideA11y { lang, light, tooltips, translations, mode, formulas, media, effect, id, modalIsActive } =
    case mode of
        Slides ->
            effect
                |> Effect.current_paragraphs
                |> List.map
                    (\( active, counter, comment ) ->
                        comment
                            |> Maybe.map
                                (\( narrator, content ) ->
                                    List.map
                                        (\c ->
                                            c.content
                                                |> List.map
                                                    (view_inf effect.javascript
                                                        lang
                                                        light
                                                        tooltips
                                                        (Just translations)
                                                        (Just formulas)
                                                        (Just media)
                                                    )
                                                |> Html.p
                                                    ({ hidden = False
                                                     , ariaHidden = False
                                                     , translations = Just translations
                                                     , id = counter
                                                     , narrator = narrator
                                                     , audio = c.audio
                                                     }
                                                        |> Markdown.addTranslation
                                                        |> List.append c.attr
                                                        |> toAttribute
                                                    )
                                                |> Html.map (Tuple.pair id >> Script)
                                        )
                                        content
                                )
                            |> Maybe.withDefault []
                            |> (::)
                                -- jumps to the step, named "Step 1 of 4"
                                (Html.button
                                    [ Attr.class "lia-notes__step hide-lg-down"
                                    , counter |> JumpToFragment |> onClick
                                    , [ Trans.baseStep lang, String.fromInt counter, Trans.ttsOf lang, String.fromInt effect.effects ]
                                        |> String.join " "
                                        |> A11y_Aria.label
                                    ]
                                    [ Html.small
                                        [ Attr.class "lia-notes__counter" ]
                                        [ String.fromInt counter
                                            ++ "/"
                                            ++ String.fromInt effect.effects
                                            |> Html.text
                                        ]
                                    ]
                                )
                            |> Html.div
                                (if active then
                                    -- an attribute, Elm would only empty an id property
                                    [ Attr.class "lia-notes__content active", Attr.attribute "id" "lia-notes-active" ]

                                 else
                                    [ Attr.class "lia-notes__content hide-lg-down" ]
                                )
                            |> Tuple.pair (String.fromInt id ++ "-/-" ++ String.fromInt counter)
                    )
                |> Keyed.node "aside" (deactivate modalIsActive [ Attr.class "lia-notes", Attr.tabindex -1, A11y_Aria.label (Trans.commentSidebar lang) ])

        _ ->
            Html.text ""


{-| **@private:** create a navigation button with:

1.  `str`: string to be displayed in the body
2.  `title`: attribute
3.  `id`: so that it can be identified by external css
4.  `msg`: to release if pressed

-}
navButton : String -> String -> String -> msg -> Html msg
navButton title id class msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class <| "lia-btn lia-btn--icon lia-btn--transparent"
        , Attr.id id
        , A11y_Key.tabbable True
        ]
        [ Html.i [ A11y_Aria.hidden True, Attr.class <| "lia-btn__icon icon " ++ class ]
            []
        ]


{-| **@private:** the navigation abr:

1.  `section_active`: section id to display
2.  `hasIndex`: display home/index button
3.  `mode`: to define the rendering type
4.  `lang`: used for translations
5.  `speaking`: underlines the section number, to indicate if the text2speech
    output is currently active
6.  `state`: fragments, if animations are active, not visible in textbook mode

-}
slideTopBar : Screen -> Model -> Definition -> String -> Html Msg
slideTopBar screen model def progress =
    Settings.header
        { online = Sync_.isConnected model.sync.state
        , lang = model.translation
        , screen = screen
        , settings = model.settings
        , logo = Definition.getIcon def
        , buttons =
            List.concat
                [ [ Settings.menu "chat" Settings.menuChat
                  , Settings.menu "mode" Settings.menuMode
                  , Settings.menu1 "settings" Settings.menuSettings screen.width
                  , Settings.menu2 "lang" Settings.menuTranslations model.langCode def
                  ]
                , case model.settings.edit of
                    Nothing ->
                        []

                    Just editURL ->
                        [ Settings.menu1 "edit" Settings.menuEdit editURL ]
                , [ Settings.menu2 "share" Settings.menuShare model.url model.sync
                  , Settings.menu2 "info" Settings.menuInformation model.repositoryUrl def
                  ]
                ]
        , progress = progress
        , active = True
        }
        |> Html.map UpdateSettings


slideNavigation : Lang -> Mode -> Int -> Effect.Model SubSection -> Html Msg
slideNavigation lang mode slide effect =
    Html.nav [ Attr.class "lia-pagination", A11y_Aria.label (Trans.baseSlideNavigation lang) ]
        [ Html.div [ Attr.class "lia-pagination__content" ]
            [ navButton (Trans.baseNext lang) "lia-btn-next" "icon-arrow-right" NextSection
            , Html.span
                [ Attr.class "lia-pagination__current" ]
                [ hiddenText (Trans.baseSlide lang ++ " ")
                , Html.text (String.fromInt (slide + 1))
                , Html.span [ Attr.class "font-400" ] <|
                    case mode of
                        Textbook ->
                            []

                        _ ->
                            case state effect of
                                "" ->
                                    []

                                steps ->
                                    [ hiddenText (", " ++ Trans.baseStep lang ++ " ")
                                    , Html.text steps
                                    ]
                ]
            , navButton (Trans.basePrev lang) "lia-btn-prev" "icon-arrow-left" PrevSection
            ]
        ]


responsiveVoice : { lang : Lang, tiny : Bool, show : Bool, tts : TTS, audio : List String, embedded : Bool } -> Html msg
responsiveVoice { lang, tiny, show, tts, audio, embedded } =
    Html.small
        [ Attr.class "lia-responsive-voice__info notranslate"
        , Attr.attribute "translate" "no"
        , Attr.style "visibility" <|
            if show then
                "visible"

            else
                "hidden"
        , Attr.style "font-size" <|
            if tiny then
                "65%"

            else
                "80%"
        ]
        (appendAudioFragments audio embedded <|
            if tts.isBrowserSupported && (tts.preferBrowser || not tts.isResponsiveVoiceSupported) then
                [ Html.text (Trans.ttsUsingBrowser lang) ]

            else if tts.isResponsiveVoiceSupported then
                responsiveVoiceTTSText

            else
                [ Html.text (Trans.ttsUnsupported lang) ]
        )


{-| Recordings replace the TTS, so its info is hidden, also for embedded videos.
-}
appendAudioFragments : List String -> Bool -> List (Html msg) -> List (Html msg)
appendAudioFragments audio embedded info =
    if List.isEmpty audio then
        if embedded then
            [ Html.span [ Attr.style "visibility" "hidden" ] info ]

        else
            info

    else
        Html.span [ Attr.style "visibility" "hidden" ] info
            :: List.map audioRecordings audio


{-| The draggable overlay for narrator comments. It shows the video recordings
of the current animation step. If there are none, but a template has
registered a narrator avatar (`window.LIA.narrator.registerAvatar`), the
custom element of that avatar is shown instead, together with the narrator
and the `data-*` annotations of the current comments as attributes. Videos
always take precedence over the avatar.

Embedded videos (YouTube, Vimeo, ...) are only placeholders, the player
adapters in TTS.ts (`comment-media`) inject and control the iframes.
-}
viewVideoComment : { active : Bool, hide : Bool, avatar : Maybe String } -> Overlay.Model -> Effect.Model SubSection -> Html Msg
viewVideoComment comments overlay effects =
    let
        ( urls, embeds ) =
            if comments.active then
                ( Effect.getVideoRecordings effects, Effect.getEmbedVideoRecordings effects )

            else
                ( [], [] )

        videos =
            String.join "," urls

        avatar =
            if comments.active && List.isEmpty urls && List.isEmpty embeds then
                Maybe.map2 Tuple.pair comments.avatar (Effect.current_narrator effects)

            else
                Nothing

        hide =
            String.isEmpty videos && List.isEmpty embeds && avatar == Nothing

        -- TeacherTube and TU-Freiberg have no autoplay API, users have to
        -- click their play buttons
        nativeClicks =
            List.any (\embed -> embed.provider == "teachertube" || embed.provider == "tu-freiberg") embeds
    in
    case avatar of
        Just ( tag, ( narrator, attr ) ) ->
            Html.node tag
                (Attr.id "lia-tts-avatar"
                    :: Attr.attribute "data-voice" narrator
                    :: Attr.attribute "data-step" (String.fromInt effects.visible)
                    -- stacked above a leftover video preview frame
                    -- (cf. storeBackgroundVideo in TTS.ts), but below the
                    -- drag and resize handles of the overlay
                    :: Attr.style "display" "block"
                    :: Attr.style "position" "absolute"
                    :: Attr.style "top" "0"
                    :: Attr.style "left" "0"
                    :: Attr.style "width" "100%"
                    :: Attr.style "height" "100%"
                    :: toAttribute attr
                )
                []
                |> viewCommentOverlay comments hide False overlay

        Nothing ->
            (viewVideos hide urls ++ List.map viewEmbed embeds)
                |> Html.div
                    [ Attr.id "lia-tts-videos"
                    , Attr.style "width" "100%"
                    , Attr.style "height" "100%"
                    , Attr.attribute "data-urls" videos
                    ]
                |> viewCommentOverlay comments hide nativeClicks overlay


viewCommentOverlay : { comments | active : Bool, hide : Bool } -> Bool -> Bool -> Overlay.Model -> Html Msg -> Html Msg
viewCommentOverlay comments hide nativeClicks overlay =
    Overlay.view nativeClicks
        (if hide || not comments.active || comments.hide then
            [ Attr.style "display" "none" ]

         else
            [ Attr.class "fade-in" ]
        )
        overlay
        >> Html.map UpdateOverlay


viewVideos : Bool -> List String -> List (Html Msg)
viewVideos hide urls =
    urls
        |> List.map
            (\url ->
                Html.video
                    [ Attr.controls False
                    , Attr.style "width" "100%"
                    , Attr.style "height" "100%"
                    , Attr.style "objectFit" "cover"
                    , Attr.style "opacity"
                        (if hide then
                            "0"

                         else
                            "1"
                        )

                    -- Control opacity based on `hide`
                    , Attr.style "transition" "opacity 0.3s" -- Smooth transition for opacity
                    , Attr.attribute "data-url" url
                    , Attr.style "display" "none" -- Hide the video element
                    , Attr.preload "auto"
                    , Attr.src url
                    , Attr.style "position" "absolute"
                    , onError "video" url
                    ]
                    []
            )


viewEmbed : Effect.EmbedVideo -> Html Msg
viewEmbed embed =
    Html.div
        [ Attr.class "lia-tts-embed"
        , Attr.style "width" "100%"
        , Attr.style "height" "100%"
        , Attr.style "display" "none"
        , Attr.style "position" "absolute"
        , Attr.attribute "data-embed-provider" embed.provider
        , Attr.attribute "data-embed-url" embed.url
        ]
        []


audioRecordings : String -> Html msg
audioRecordings src =
    audio [ Attr.class "lia-tts-recordings" ]
        { controls = False
        , preload = "auto"
        , url = src
        , errorHandling = False
        }


responsiveVoiceTTSText : List (Html msg)
responsiveVoiceTTSText =
    [ Html.a (Attr.class "lia-link" :: Attr.href "https://responsivevoice.org" :: newTab) [ Html.text "ResponsiveVoice-NonCommercial" ]
    , Html.text " licensed under "
    , Html.a
        (Attr.href "https://creativecommons.org/licenses/by-nc-nd/4.0/" :: newTab)
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


{-| **@private:** A modal (classroom, zoomed image, QR-code) is open, see
`showModal`, everything else gets deactivated.
-}
isHidden : Model -> Bool
isHidden model =
    model.settings.sync == Just True || model.modal /= Nothing || model.settings.showQRCode


{-| The Classroom modal's close ("×") button: on the backend/connect
sub-page it steps back to the overview instead of closing the whole
modal - only closes for real once already on the overview. But once
actually connected to a classroom, "back to overview" would reset the
room/password fields and rewrite the URL out from under the live
session - so a connected user always just closes the modal instead.
-}
syncCloseMsg : Sync_.Settings -> Msg
syncCloseMsg sync =
    case ( Sync_.isConnected sync.state, sync.sync.select ) of
        ( False, Just _ ) ->
            UpdateSync (SyncUpdate.Backend (SyncUpdate.Select Nothing))

        _ ->
            UpdateSettings (Settings_.Toggle Settings_.Sync)


showModal : Model -> Html Msg
showModal model =
    case ( model.settings.sync, model.modal, model.settings.showQRCode ) of
        ( Just True, _, _ ) ->
            model.sync
                |> Sync.view
                |> Html.map UpdateSync
                |> List.singleton
                |> modal model.translation False (syncCloseMsg model.sync) Nothing

        ( _, Just url, _ ) ->
            modal model.translation True
                (Media ( "", Nothing, Nothing ))
                Nothing
                [ Html.figure
                    [ Attr.class "lia-figure"
                    ]
                    [ Html.div
                        [ Attr.class "lia-figure__media"
                        , Attr.attribute "data-media-image" "image"
                        , model.media
                            |> Dict.get url
                            |> Maybe.map (Tuple.first >> Attr.width)
                            |> Maybe.withDefault (Attr.class "")
                        , Attr.style "background-image" ("url('" ++ url ++ "')")
                        , Attr.class "lia-figure__zoom"
                        , Attr.attribute "onmousemove" "window.LIA.img.zoom(event)"
                        ]
                        [ Html.img
                            [ Attr.src url
                            ]
                            []
                        ]
                    ]
                ]

        ( _, _, True ) ->
            modal model.translation True
                (UpdateSettings (Settings_.Toggle Settings_.QRCode))
                Nothing
                [ Html.div
                    [ Attr.style "height" "80%"
                    , Attr.style "max-height" "800px"
                    , Attr.style "width" "80%"
                    , Attr.style "max-width" "800px"
                    , Attr.style "margin-block-start" "calc(100vh * 0.08)"
                    ]
                    [ model.url
                        |> Settings.qrCodeView model.translation True True False
                        |> Html.map UpdateSettings
                    ]
                ]

        _ ->
            Html.text ""


{-| **@private:** Text, that is only read by screen readers.
-}
hiddenText : String -> Html msg
hiddenText =
    Html.text >> List.singleton >> Html.span [ Attr.class "hidden-visually" ]


{-| **@private:** Seconds as "m:ss".
-}
minutes : Float -> String
minutes seconds =
    let
        s =
            round seconds
    in
    String.fromInt (s // 60) ++ ":" ++ String.padLeft 2 '0' (String.fromInt (modBy 60 s))
