module Lia.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Array
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import I18n.Translations as Trans exposing (Lang)
import Lia.Chat.View as Chat
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Index.View as Index
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.View exposing (state)
import Lia.Markdown.HTML.Attributes exposing (toAttribute)
import Lia.Markdown.Inline.View exposing (audio, view_inf)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Section exposing (Section, SubSection)
import Lia.Settings.Types exposing (Mode(..), Settings, TTS)
import Lia.Settings.Update as Settings_
import Lia.Settings.View as Settings
import Lia.Sync.Types as Sync_
import Lia.Sync.View as Sync
import Lia.Update exposing (Msg(..), get_active_section)
import Lia.Utils exposing (deactivate, modal)
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
            [ Html.text "skip navigation" ]
            :: viewIndex modalIsActive hasIndex model
            :: viewSlide modalIsActive screen model
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
            ]
        )
        [ Settings.btnIndex
            model.translation
            model.settings.table_of_contents
            |> Html.map UpdateSettings
        , model.index_model
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
            |> Html.div
                [ Attr.class "lia-toc__content"
                , A11y_Key.tabbable False
                ]

        --|> Html.map Script
        , if hasIndex then
            Html.div [ Attr.class "lia-toc__bottom" ]
                [ Index.bottom
                    model.translation
                    model.settings.table_of_contents
                    Home
                ]

          else
            Html.text ""

        -- , model
        --     |> get_active_section
        --     |> Maybe.andThen .definition
        --     |> Maybe.withDefault model.definition
        --     |> Settings.view model.settings
        --         model.url
        --         model.origin
        --         model.translation
        --         (if hasShareAPI then
        --             Just <| share model.title (stringify model.definition.comment) model.url
        --          else
        --             Nothing
        --         )
        --     |> Html.map UpdateSettings
        ]


{-| **@private:** show the current section, with navigation on top as well as a
footer, if it is required by the current display mode.
-}
viewSlide : Bool -> Screen -> Model -> List (Html Msg)
viewSlide modalIsActive screen model =
    case get_active_section model of
        Just section ->
            [ Html.div (deactivate modalIsActive [ Attr.class "lia-slide" ])
                [ viewProgress model section.effect_model
                , slideTopBar
                    model.langCode
                    model.translation
                    screen
                    model.url
                    model.repositoryUrl
                    model.settings
                    (Definition.merge model.definition section.definition)
                    model.sync
                , viewPanes screen model
                , slideBottom
                    { lang = model.translation
                    , tiny = screen.width < 400
                    , settings = model.settings
                    , slide = model.section_active
                    , effects = section.effect_model
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
                , effect = section.effect_model
                , id = model.section_active
                , modalIsActive = modalIsActive
                }
            , viewVideoComment
                { active = model.settings.sound
                , hide = model.settings.hideVideoComments || model.settings.mode == Textbook
                }
                model.overlayVideo
                section.effect_model
            , showModal model
            ]

        Nothing ->
            [ Html.div [ Attr.class "lia-slide" ]
                [ slideTopBar
                    model.langCode
                    model.translation
                    screen
                    model.url
                    model.repositoryUrl
                    model.settings
                    model.definition
                    model.sync
                , Html.text "Ups, something went wrong"
                ]
            ]


viewProgress : Model -> Effect.Model SubSection -> Html Msg
viewProgress model effect_model =
    let
        toPercent val array =
            (toFloat val * 100.0) / toFloat (Array.length array)

        percent =
            (\x -> String.fromFloat x ++ "%") <|
                case model.settings.mode of
                    Textbook ->
                        toPercent
                            (model.section_active + 1)
                            model.sections

                    _ ->
                        let
                            onePercent =
                                (toPercent 1 model.sections / toFloat (effect_model.effects + 1)) * toFloat (effect_model.visible + 1)
                        in
                        onePercent
                            + toPercent
                                model.section_active
                                model.sections
    in
    Html.div
        [ Attr.style "width" percent
        , Attr.class "lia-progress"
        , A11y_Aria.hidden True
        ]
        []


viewPanes : Screen -> Model -> Html Msg
viewPanes screen model =
    Html.div
        [ Attr.class "lia-slide__container"
        ]
        [ SplitPane.view
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
            viewConfig
            (model.sections
                |> Array.toIndexedList
                |> List.map (showSection model screen)
                |> Html.div
                    [ Attr.style "width" "100%"
                    , Attr.style "overflow-y" "auto"
                    , Attr.style "display" "flex"
                    , Attr.style "justify-content" "center"
                    , Attr.class "lia-slide__container"
                    , Attr.style "margin-top" "0px"
                    ]
            )
            (Chat.view model.translation (initConfig screen model) model.chat
                |> Html.map UpdateChat
            )
            model.pane
        ]


viewConfig : SplitPane.ViewConfig Msg
viewConfig =
    SplitPane.createViewConfig
        { toMsg = Pane
        , customSplitter = Nothing
        }


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
    initConfig screen model section
        |> Markdown.view (model.section_active /= id) (Maybe.withDefault model.persistent section.persistent)
        |> Html.map UpdateMarkdown


{-| **@private:** used to display the text2speech output settings and spoken
comments in text, depending on the currently applied rendering mode.
-}
slideBottom : { lang : Lang, tiny : Bool, settings : Settings, slide : Int, effects : Effect.Model SubSection } -> Html Msg
slideBottom { lang, tiny, settings, slide, effects } =
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
                in
                Html.div
                    [ Attr.class "lia-responsive-voice"
                    , if tiny then
                        Attr.style "padding" "0px"

                      else
                        Attr.class ""
                    ]
                    [ Html.div [ Attr.class "lia-responsive-voice__control" ]
                        [ btnReplay lang sound settings
                        , responsiveVoice
                            { lang = lang
                            , tiny = tiny
                            , show = sound
                            , tts = settings.tts
                            , audio = Effect.getAudioRecordings effects
                            }
                        , btnStop lang settings
                        ]
                    ]
        ]


btnReplay : Lang -> Bool -> Settings -> Html Msg
btnReplay lang soundEnabled settings =
    Lia.Utils.btnIcon
        { title =
            if settings.speaking then
                Trans.baseStop lang

            else
                Trans.basePlay lang
        , tabbable = settings.sound
        , msg =
            if soundEnabled && settings.sound then
                Just (TTSReplay (not settings.speaking))

            else
                Nothing
        , icon =
            if settings.speaking then
                "icon-stop-circle"

            else
                "icon-play-circle"
        }
        [ Attr.id "lia-btn-sound"
        , Attr.class "lia-btn--transparent lia-responsive-voice__play"
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
                                (Html.a
                                    [ Attr.class "hide-lg-down"
                                    , counter |> JumpToFragment |> onClick
                                    , Attr.href "#"
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
                                [ Attr.class
                                    ("lia-notes__content"
                                        ++ (if active then
                                                " active"

                                            else
                                                " hide-lg-down"
                                           )
                                    )
                                , Attr.id
                                    (if active then
                                        "lia-notes-active"

                                     else
                                        ""
                                    )
                                ]
                            |> Tuple.pair (String.fromInt id ++ "-/-" ++ String.fromInt counter)
                    )
                |> Keyed.node "aside" (deactivate modalIsActive [ Attr.class "lia-notes" ])

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
slideTopBar : String -> Lang -> Screen -> String -> Maybe String -> Settings -> Definition -> Sync_.Settings -> Html Msg
slideTopBar languageCode lang screen url repositoryURL settings def sync =
    Settings.header
        { online = Sync_.isConnected sync.state
        , lang = lang
        , screen = screen
        , settings = settings
        , logo = Definition.getIcon def
        , buttons =
            List.concat
                [ [ ( Settings.menuChat, "chat" )
                  , ( Settings.menuMode, "mode" )
                  , ( Settings.menuSettings screen.width, "settings" )
                  , ( Settings.menuTranslations languageCode def, "lang" )
                  ]
                , case settings.edit of
                    Nothing ->
                        []

                    Just editURL ->
                        [ ( Settings.menuEdit editURL, "edit" ) ]
                , [ ( Settings.menuShare url sync, "share" )
                  , ( Settings.menuInformation repositoryURL def, "info" )
                  ]
                ]
        , active = True
        }
        |> Html.map UpdateSettings


slideNavigation : Lang -> Mode -> Int -> Effect.Model SubSection -> Html Msg
slideNavigation lang mode slide effect =
    Html.div [ Attr.class "lia-pagination" ]
        [ Html.div [ Attr.class "lia-pagination__content" ]
            [ navButton (Trans.baseNext lang) "lia-btn-next" "icon-arrow-right" NextSection
            , Html.span
                [ Attr.class "lia-pagination__current" ]
                [ Html.text (String.fromInt (slide + 1))
                , Html.span [ Attr.class "font-400" ]
                    [ Html.text <|
                        case mode of
                            Textbook ->
                                ""

                            _ ->
                                state effect
                    ]
                ]
            , navButton (Trans.basePrev lang) "lia-btn-prev" "icon-arrow-left" PrevSection
            ]
        ]



-- , Html.span [ Attr.class "lia-spacer", Attr.id "lia-spacer-left" ] []
-- , navButton "navigate_before" (Trans.basePrev lang) "lia-btn-prev" PrevSection
-- , Html.span [ Attr.class "lia-labeled lia-left", Attr.id "lia-label-section" ]
--     [ Html.span
--         [ Attr.class "lia-label"
--         , if speaking then
--             Attr.style "text-decoration" "underline"
--           else
--             Attr.style "" ""
--         ]
--         [ Html.text (String.fromInt (section_active + 1))
--         , Html.text <|
--             case mode of
--                 Textbook ->
--                     ""
--                 _ ->
--                     state
--         ]
--     ]
-- , navButton "navigate_next" (Trans.baseNext lang) "lia-btn-next" NextSection
-- , Html.span [ Attr.class "lia-spacer", Attr.id "lia-spacer-right" ] []
-- , Html.map UpdateSettings <| Settings.switch_button_mode lang mode
-- ]


responsiveVoice : { lang : Lang, tiny : Bool, show : Bool, tts : TTS, audio : List String } -> Html msg
responsiveVoice { lang, tiny, show, tts, audio } =
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
        (appendAudioFragments audio <|
            case ( tts.isBrowserSupported, tts.isResponsiveVoiceSupported, tts.preferBrowser ) of
                ( True, False, _ ) ->
                    [ browserTTSText lang ]

                ( False, True, _ ) ->
                    responsiveVoiceTTSText

                ( True, True, True ) ->
                    [ browserTTSText lang ]

                ( True, True, False ) ->
                    responsiveVoiceTTSText

                ( False, False, _ ) ->
                    [ noTTSText lang ]
        )


appendAudioFragments : List String -> List (Html msg) -> List (Html msg)
appendAudioFragments audio info =
    if List.isEmpty audio then
        info

    else
        Html.span [ Attr.style "visibility" "hidden" ] info
            :: List.map audioRecordings audio


viewVideoComment : { active : Bool, hide : Bool } -> Overlay.Model -> Effect.Model SubSection -> Html Msg
viewVideoComment comments overlay effects =
    let
        urls =
            if comments.active then
                Effect.getVideoRecordings effects

            else
                []

        videos =
            String.join "," urls

        hide =
            String.isEmpty videos
    in
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
                    ]
                    []
            )
        |> Html.div
            [ Attr.id "lia-tts-videos"
            , Attr.style "width" "100%"
            , Attr.style "height" "100%"
            , Attr.attribute "data-urls" videos
            ]
        |> Overlay.view
            (if hide || not comments.active || comments.hide then
                [ Attr.style "display" "none" ]

             else
                [ Attr.class "fade-in" ]
            )
            overlay
        |> Html.map UpdateOverlay


audioRecordings : String -> Html msg
audioRecordings src =
    audio [ Attr.class "lia-tts-recordings" ]
        { controls = False
        , preload = "auto"
        , url = src
        , errorHandling = False
        }


noTTSText : Lang -> Html msg
noTTSText =
    Trans.ttsUnsupported >> Html.text


browserTTSText : Lang -> Html msg
browserTTSText =
    Trans.ttsUsingBrowser >> Html.text


responsiveVoiceTTSText : List (Html msg)
responsiveVoiceTTSText =
    [ Html.a [ Attr.class "lia-link", Attr.href "https://responsivevoice.org", Attr.target "_blank" ] [ Html.text "ResponsiveVoice-NonCommercial" ]
    , Html.text " licensed under "
    , Html.a
        [ Attr.href "https://creativecommons.org/licenses/by-nc-nd/4.0/"
        , Attr.target "_blank"
        ]
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


isHidden : Model -> Bool
isHidden model =
    case ( model.settings.sync, model.modal, model.settings.showQRCode ) of
        ( Just True, _, _ ) ->
            True

        ( _, Just _, _ ) ->
            True

        ( _, _, True ) ->
            True

        _ ->
            False


showModal : Model -> Html Msg
showModal model =
    case ( model.settings.sync, model.modal, model.settings.showQRCode ) of
        ( Just True, _, _ ) ->
            model.sync
                |> Sync.view
                |> Html.map UpdateSync
                |> List.singleton
                |> modal (UpdateSettings (Settings_.Toggle Settings_.Sync)) Nothing

        ( _, Just url, _ ) ->
            modal (Media ( "", Nothing, Nothing ))
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
            modal
                (UpdateSettings (Settings_.Toggle Settings_.QRCode))
                Nothing
                [ Html.div
                    [ Attr.style "height" "80%"
                    , Attr.style "max-height" "800px"
                    , Attr.style "width" "80%"
                    , Attr.style "max-width" "800px"
                    , Attr.style "margin-top" "calc(100vh * 0.08)"
                    ]
                    [ model.url
                        |> Settings.qrCodeView model.translation True True Nothing
                        |> Html.map UpdateSettings
                    ]
                ]

        _ ->
            Html.text ""
