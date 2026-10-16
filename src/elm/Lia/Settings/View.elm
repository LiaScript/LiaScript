module Lia.Settings.View exposing
    ( btnIndex
    , design
    , header
    , menu
    , menu1
    , menu2
    , menuChat
    , menuEdit
    , menuInformation
    , menuMode
    , menuSettings
    , menuShare
    , menuTranslations
    , qrCodeView
    )

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Array
import Conditional.List as CList
import Const
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy as Lazy
import I18n.Translations as Trans exposing (Lang)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Settings.Types
    exposing
        ( Action(..)
        , Audio(..)
        , Mode(..)
        , Settings
        , TTS
        , fromGroup
        , submenuID
        , toGroup
        , toggleID
        )
import Lia.Settings.Update exposing (Msg(..), Toggle(..))
import Lia.Sync.Types as Sync
import Lia.Utils
    exposing
        ( btn
        , btnIcon
        , deactivate
        , icon
        , noTranslate
        )
import Library.Group as Group
import QRCode
import Session exposing (Screen)


{-| The classes of the canvas: TOC and support menu visibility and the mode.
-}
design : Settings -> List (Html.Attribute msg)
design model =
    [ Attr.class "lia-canvas"
    , Attr.class <|
        if model.table_of_contents then
            "lia-toc--visible"

        else
            "lia-toc--hidden"
    , Attr.class <|
        if model.support_menu then
            "lia-support--visible"

        else
            "lia-support--hidden"
    , Attr.class <|
        case model.mode of
            Textbook ->
                "lia-mode--textbook"

            Presentation ->
                "lia-mode--presentation"

            Slides ->
                "lia-mode--slides"
    ]


viewSettings : Lang -> Bool -> Int -> Settings -> List (Html Msg)
viewSettings lang tabbable width settings =
    let
        grouping =
            group ShowSettings
    in
    [ viewLightMode grouping lang tabbable settings.light
    , divider
    , settings.customTheme
        /= Nothing
        |> viewTheme grouping lang tabbable settings.theme
    , divider
    , viewEditorTheme grouping lang tabbable settings.editor
    , divider
    , viewSizing grouping lang tabbable settings.font_size
    , divider
    , viewFullscreen grouping lang tabbable settings.fullscreen
    , divider
    , viewTooltips grouping lang tabbable width settings.tooltips
    , divider
    , viewDecals grouping lang tabbable settings.decals
    , divider
    , viewVideoComment grouping lang tabbable settings.hideVideoComments
    , divider
    , viewTTSSettings grouping lang tabbable settings.audio settings.tts
    ]


{-| Mark the elements of a menu, so that the menu gets closed if the focus
leaves it.
-}
group : Action -> List (Attribute Msg) -> List (Attribute Msg)
group groupID =
    (::) (Group.id (fromGroup groupID)) >> (::) (Group.blur (toGroup >> FocusLoss))


divider : Html msg
divider =
    Html.hr [ Attr.class "nav__divider" ] []


viewLightMode : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Bool -> Html Msg
viewLightMode grouping lang tabbable isLight =
    Html.button
        (grouping
            [ Attr.class "lia-btn lia-btn--transparent"
            , onClick (Toggle Light)
            , A11y_Key.tabbable tabbable
            , A11y_Aria.hidden (not tabbable)
            , Attr.id "lia-btn-light-mode"
            , Attr.style "width" "100%"
            ]
        )
        [ Html.i
            [ A11y_Aria.hidden True
            , Attr.class "lia-btn__icon icon"
            , Attr.class <|
                if isLight then
                    "icon-darkmode"

                else
                    "icon-lightmode"
            ]
            []
        , Html.span [ Attr.class "lia-btn__text" ]
            [ Html.text <|
                if isLight then
                    Trans.cDark lang

                else
                    Trans.cBright lang
            ]
        ]


viewFullscreen : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Bool -> Html Msg
viewFullscreen grouping lang tabbable isFullscreen =
    Html.button
        (grouping
            [ Attr.class "lia-btn lia-btn--transparent"
            , onClick (Toggle Fullscreen)
            , A11y_Key.tabbable tabbable
            , A11y_Aria.hidden (not tabbable)
            , Attr.id "lia-btn-fullscreen"
            , Attr.style "width" "100%"
            ]
        )
        [ Html.span [ Attr.class "lia-btn__text" ]
            [ Html.text <|
                if isFullscreen then
                    Trans.fullscreenExit lang

                else
                    Trans.fullscreenEnter lang
            , Html.text " (F11)"
            ]
        ]


{-| -}
menuChat : Lang -> Bool -> Settings -> List (Html Msg)
menuChat lang tabbable settings =
    [ btnChat { id = "lia-btn-chat", lang = lang, tabbable = tabbable, chat = settings.chat, hide = False } ]


viewTheme : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> String -> Bool -> Html Msg
viewTheme grouping lang tabbable theme hasCustom =
    (if hasCustom then
        [ ( "yellow", Trans.cYellow lang, "is-yellow" )
        , ( "custom", Trans.cDefault lang, "is-custom" )
        ]

     else
        [ ( "yellow", Trans.cYellow lang, "is-yellow" ) ]
    )
        |> List.append
            [ ( "default", Trans.cDefault lang, "is-default" )
            , ( "turquoise", Trans.cTurquoise lang, "is-turquoise" )
            , ( "blue", Trans.cBlue lang, "is-blue" )
            , ( "red", Trans.cRed lang, "is-red" )
            ]
        |> List.map
            (\( color, name, styleClass ) ->
                Html.input
                    (grouping
                        [ Attr.type_ "radio"
                        , Attr.class <| "lia-radio " ++ styleClass
                        , Attr.id <| "lia-theme-color-" ++ color
                        , Attr.name "lia-theme-color"
                        , Attr.checked (theme == color)
                        , onClick (ChangeTheme color)
                        , Attr.title name
                        , A11y_Key.tabbable tabbable
                        , A11y_Aria.hidden (not tabbable)
                        ]
                    )
                    []
            )
        |> Html.div
            [ Attr.class "lia-radio-group lia-settings-theme-colors"
            , Attr.attribute "style" "--focus-ring-offset: 0.4lh"
            , A11y_Role.radioGroup
            , lang
                |> Trans.cSchema
                |> A11y_Aria.label
            ]


{-| The modes with the ids and icons of their buttons.
-}
modes : List { mode : Mode, id : String, icon : String }
modes =
    [ { mode = Textbook, id = "lia-mode-textbook", icon = "icon-book" }
    , { mode = Presentation, id = "lia-mode-presentation", icon = "icon-presentation" }
    , { mode = Slides, id = "lia-mode-slides", icon = "icon-slides" }
    ]


viewMode : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Mode -> { mode : Mode, id : String, icon : String } -> Html Msg
viewMode grouping lang tabbable activeMode { mode, id, icon } =
    Html.button
        (grouping
            [ Attr.id id
            , Attr.class "lia-btn lia-btn--transparent "
            , onClick (SwitchMode mode)
            , A11y_Key.tabbable tabbable
            , A11y_Aria.hidden (not tabbable)
            , A11y_Aria.pressed <| Just (mode == activeMode)
            ]
        )
        [ Html.i [ A11y_Aria.hidden True, Attr.class <| "lia-btn__icon icon " ++ icon ] []
        , Html.span [ Attr.class "lia-btn__text" ] [ modeToString mode lang |> Html.text ]
        ]


modeToString : Mode -> Lang -> String
modeToString show =
    case show of
        Presentation ->
            Trans.modePresentation

        Slides ->
            Trans.modeSlides

        Textbook ->
            Trans.modeTextbook


viewSizing : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Int -> Html Msg
viewSizing grouping lang tabbable size =
    Html.div (grouping [ Attr.class "lia-fontscale" ])
        [ Trans.baseFont lang (Trans.baseSize1 lang)
            |> fontButton grouping lang tabbable size 1
        , Trans.baseFont lang (Trans.baseSize2 lang)
            |> fontButton grouping lang tabbable size 2
        , Trans.baseFont lang (Trans.baseSize3 lang)
            |> fontButton grouping lang tabbable size 3
        ]


viewTooltips : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Int -> Bool -> Html Msg
viewTooltips grouping lang tabbable width enabled =
    if width >= Const.tooltipBreakpoint then
        Html.label
            [ Attr.class "lia-label"
            , A11y_Aria.hidden (not tabbable)
            ]
            [ Html.input
                (grouping
                    [ Attr.class "lia-checkbox"
                    , Attr.type_ "checkbox"
                    , Attr.checked enabled
                    , onClick (Toggle Tooltips)
                    , A11y_Key.tabbable tabbable
                    ]
                )
                []
            , Html.text (Trans.confTooltip lang)
            ]

    else
        Html.text ""


{-| Do not rely on color alone (class `lia-decals` of the html): patterns in
charts, and borders of quiz inputs, solid if correct, dashed if wrong.
-}
viewDecals : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Bool -> Html Msg
viewDecals grouping lang tabbable enabled =
    Html.label
        [ Attr.class "lia-label"
        , A11y_Aria.hidden (not tabbable)
        ]
        [ Html.input
            (grouping
                [ Attr.class "lia-checkbox"
                , Attr.type_ "checkbox"
                , Attr.checked enabled
                , onClick (Toggle Decals)
                , A11y_Key.tabbable tabbable
                ]
            )
            []
        , Html.text (Trans.confDecals lang)
        ]


viewVideoComment : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Bool -> Html Msg
viewVideoComment grouping lang tabbable enabled =
    Html.label
        [ Attr.class "lia-label"
        , A11y_Aria.hidden (not tabbable)
        ]
        [ Html.input
            (grouping
                [ Attr.class "lia-checkbox"
                , Attr.type_ "checkbox"
                , Attr.checked enabled
                , onClick (Toggle VideoComments)
                , A11y_Key.tabbable tabbable
                ]
            )
            []
        , Html.text (Trans.commentHide lang)
        ]


viewTTSSettings :
    (List (Attribute Msg) -> List (Attribute Msg))
    -> Lang
    -> Bool
    ->
        { pitch : String
        , rate : String
        }
    -> TTS
    -> Html Msg
viewTTSSettings grouping lang tabbable audio tts =
    Html.div []
        [ Html.label
            [ Attr.class "lia-label"
            , A11y_Aria.hidden (not tabbable)
            ]
            [ Html.input
                (grouping
                    [ Attr.class "lia-checkbox"
                    , Attr.type_ "checkbox"
                    , Attr.checked <|
                        case ( tts.isBrowserSupported, tts.isResponsiveVoiceSupported ) of
                            ( True, False ) ->
                                True

                            ( False, True ) ->
                                False

                            _ ->
                                tts.preferBrowser
                    , onClick (Toggle PreferBrowserTTS)
                    , A11y_Key.tabbable tabbable
                    , Attr.disabled (not (tts.isBrowserSupported && tts.isResponsiveVoiceSupported))
                    ]
                )
                []
            , Html.text (Trans.ttsPreferBrowser lang)
            ]
        , Html.div
            [ Attr.style "display" "flex"
            , Attr.style "flex-direction" "column"
            ]
            [ slider "Rate" (Trans.commentRateLabel lang) (Trans.commentRate lang) Rate grouping tabbable { value = audio.rate, maximum = "1.5", minimum = "0.5", step = "0.25" }
            , slider "Pitch" (Trans.commentPitchLabel lang) (Trans.commentPitch lang) Pitch grouping tabbable { value = audio.pitch, maximum = "2.0", minimum = "0.0", step = "0.25" }
            ]
        ]


slider :
    String
    -> String
    -> String
    -> (String -> Audio)
    -> (List (Attribute Msg) -> List (Attribute Msg))
    -> Bool
    -> { maximum : String, minimum : String, step : String, value : String }
    -> Html Msg
slider name label title message grouping tabbable { maximum, minimum, step, value } =
    let
        outputId =
            "slider-value-"
                ++ String.map
                    (\c ->
                        if Char.isAlphaNum c then
                            c

                        else
                            '-'
                    )
                    name
    in
    Html.label
        [ Attr.style "display" "flex"
        , Attr.style "align-items" "center"
        , Attr.style "margin-block-end" "10px"
        ]
        [ Html.span
            [ Attr.class "lia-label"
            , Attr.style "min-width" "50px"
            , Attr.style "white-space" "nowrap"
            , Attr.style "flex-shrink" "0"
            , Attr.style "margin-inline-end" "10px"
            ]
            [ Html.text label ]
        , Html.input
            (grouping
                ([ Attr.type_ "range"
                 , Attr.min minimum
                 , Attr.max maximum
                 , Attr.step step
                 , Attr.value value
                 , A11y_Aria.hidden (not tabbable)
                 , Attr.attribute "aria-label" title
                 , Attr.attribute "aria-describedby" outputId
                 , Attr.attribute "aria-valuetext" (value ++ "×")
                 , onInput (message >> Change)
                 , Attr.style "flex-grow" "1"
                 ]
                    ++ (if tabbable then
                            []

                        else
                            [ Attr.tabindex -1 ]
                       )
                )
            )
            []
        , Html.output
            [ Attr.id outputId
            , Attr.style "margin-inline-start" "10px"
            , Attr.style "width" "60px"
            , Attr.style "text-align" "right"
            ]
            [ Html.text (value ++ " ×") ]
        ]


fontButton : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Int -> Int -> String -> Html Msg
fontButton grouping lang tabbable size i title =
    btn
        { title = title
        , tabbable = tabbable
        , msg = Just (ChangeFontSize i)
        }
        (grouping
            [ Attr.class <| "lia-btn--transparent lia-fontscale__lvl-" ++ String.fromInt i
            , Attr.class <|
                if size == i then
                    "active"

                else
                    ""
            , A11y_Aria.pressed (Just (size == i))
            , A11y_Aria.label title
            ]
        )
        [ Html.span (noTranslate []) [ Html.text (Trans.baseAbc lang) ] ]


bold : String -> Html msg
bold =
    Html.text >> List.singleton >> Html.strong []


viewInformation :
    (List (Attribute Msg) -> List (Attribute Msg))
    -> Lang
    -> Bool
    -> Maybe String
    -> Definition
    -> List (Html Msg)
viewInformation grouping lang tabbable repositoryURL definition =
    [ case ( Dict.get "repository" definition.macro, repositoryURL ) of
        ( Just url, _ ) ->
            viewRepository url

        ( _, Just url ) ->
            viewRepository url

        _ ->
            []
    ]
        |> CList.addIf (definition.attributes /= [])
            [ bold "Attributes:"
            , Html.br [] []
            , if tabbable then
                viewAttributes lang definition.attributes

              else
                Html.text ""
            ]
        |> CList.addIf (definition.date /= "")
            [ bold <| Trans.infoDate lang
            , Html.text definition.date
            ]
        |> CList.addIf (definition.version /= "")
            [ bold <| Trans.infoVersion lang
            , Html.text definition.version
            ]
        |> CList.addIf (definition.email /= "")
            [ bold <| Trans.infoEmail lang
            , Html.a
                [ Attr.href <| "mailto:" ++ definition.email
                , Attr.class "lia-link"
                , A11y_Key.tabbable tabbable
                , A11y_Aria.hidden (not tabbable)
                , Attr.attribute "data-group-id" "information"
                ]
                [ Html.text definition.email ]
            ]
        |> CList.addIf (definition.author /= "")
            [ bold <|
                if String.contains ";" definition.author then
                    Trans.infoAuthors lang

                else
                    Trans.infoAuthor lang
            , Html.text definition.author
            ]
        |> CList.addIf (definition.comment /= [])
            [ if tabbable then
                definition.comment
                    |> inlines lang

              else
                Html.text ""
            ]
        |> List.map (Html.div (grouping [ Attr.tabindex -1, Attr.style "user-select" "text" ]))


viewRepository : String -> List (Html msg)
viewRepository url =
    [ bold "Repository: "
    , Html.a
        [ Attr.href url
        , Attr.target "_blank"
        , Attr.attribute "data-group-id" "information"
        , Attr.tabindex 0
        ]
        [ Html.text url ]
    ]


viewAttributes : Lang -> List Inlines -> Html Msg
viewAttributes lang =
    List.map (thanks lang) >> Html.div []


thanks : Lang -> Inlines -> Html Msg
thanks lang to =
    Html.span [] [ divider, inlines lang to ]
        |> Html.map (\_ -> Ignore)


inlines : Lang -> Inlines -> Html Msg
inlines lang =
    List.map (view_inf Array.empty lang False False Nothing Nothing Nothing)
        >> Html.div []
        >> Html.map (always Ignore)


viewTranslations : Lang -> Bool -> Dict String String -> List (Html Msg)
viewTranslations lang tabbable =
    Dict.toList
        >> List.map
            (\( title, url ) ->
                Html.a
                    ([ Attr.href <| "./?" ++ url
                     , Attr.class "lia-link"
                     , A11y_Key.tabbable tabbable
                     , A11y_Aria.hidden (not tabbable)
                     ]
                        |> group ShowTranslations
                    )
                    [ Html.text title, Html.br [] [] ]
            )
        >> (::)
            (Html.span (group ShowTranslations [ Attr.class "lia-link active" ])
                [ Trans.baseLang lang
                    |> Html.text
                ]
            )


{-| The panel of a toolbar button (disclosure pattern), Escape closes it and
returns the focus to its button.
-}
submenu : Action -> (List (Attribute Msg) -> List (Attribute Msg)) -> Bool -> List (Html Msg) -> Html Msg
submenu forAction grouping isActive =
    [ Attr.class "lia-support-menu__submenu flow"
    , Attr.id (submenuID forAction)
    , if isActive then
        Attr.class "active"

      else
        Attr.class ""
    , closeOnEscape forAction isActive
    ]
        |> grouping
        |> Html.div


{-| Escape closes an open submenu by toggling it, which moves the focus back to
its button, see `Lia.Settings.Update`.
-}
closeOnEscape : Action -> Bool -> Attribute Msg
closeOnEscape forAction isOpen =
    if isOpen then
        A11y_Key.onKeyDown [ A11y_Key.escape (doAction forAction) ]

    else
        Attr.class ""


{-| Lazy, because encoding the QR matrix is expensive and the share menu is part
of every frame, even when closed. `grouped` adds the share-menu focus group.
-}
qrCodeView : Lang -> Bool -> Bool -> Bool -> String -> Html Msg
qrCodeView =
    Lazy.lazy5 qrCode


qrCode : Lang -> Bool -> Bool -> Bool -> String -> Html Msg
qrCode lang tabbable marginBig grouped url =
    url
        |> QRCode.fromString
        |> Result.map
            (QRCode.toSvgWithoutQuietZone
                [ Attr.style "background-color" "#FFF"
                , Attr.style "padding" <|
                    if marginBig then
                        "2.4rem"

                    else
                        "0.4rem"

                -- the button is named by its action, the graphic adds nothing
                , A11y_Aria.hidden True
                ]
                >> List.singleton
                >> btn
                    { title = Trans.qrEnlarge lang
                    , tabbable = tabbable
                    , msg = Just (Toggle QRCode)
                    }
                    ([ Attr.style "width" "inherit"
                     , Attr.id "lia-button-qr-code"
                     , Attr.class "lia-btn--transparent"
                     , Attr.style "padding" "0  "
                     ]
                        |> (if grouped then
                                group ShowShare

                            else
                                identity
                           )
                    )
            )
        |> Result.withDefault (Html.text <| Trans.qrErr lang)


viewEditorTheme : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> String -> Html Msg
viewEditorTheme grouping lang tabbable theme =
    let
        op =
            option theme
    in
    Html.div [ Attr.class "lia-settings-editor" ]
        [ Html.label [ Attr.class "lia-label", A11y_Aria.hidden (not tabbable) ]
            [ Html.div [ Attr.style "margin-block-end" "0.4rem" ] [ Html.text <| Trans.baseEditor lang ++ ":" ]
            , Html.select
                (grouping
                    [ Attr.class "lia-select"
                    , onInput ChangeEditor
                    , A11y_Key.tabbable tabbable
                    ]
                )
                [ [ ( "chrome", "Chrome" )
                  , ( "cloud9_day", "Cloud9 Day" )
                  , ( "clouds", "Clouds" )
                  , ( "crimson_editor", "Crimson Editor" )
                  , ( "dawn", "Dawn" )
                  , ( "dreamweaver", "Dreamweaver" )
                  , ( "eclipse", "Eclipse" )
                  , ( "github", "Github" )
                  , ( "gruvbox_light_hard", "Gruvbox - Light Hard" )
                  , ( "iplastic", "IPlastic" )
                  , ( "katzenmilch", "KatzenMilch" )
                  , ( "kuroir", "Kuroir" )
                  , ( "solarized_light", "Solarized Light" )
                  , ( "sqlserver", "SQL Server" )
                  , ( "textmate", "TextMate" )
                  , ( "tomorrow", "Tomorrow" )
                  , ( "xcode", "XCode" )
                  ]
                    |> List.map op
                    |> Html.optgroup [ Attr.attribute "label" (Trans.cBright lang) ]
                , [ ( "ambiance", "Ambiance" )
                  , ( "chaos", "Chaos" )
                  , ( "cloud9_night", "Cloud9 Night" )
                  , ( "cloud9_night_low_color", "Cloud9 Night - Low Color" )
                  , ( "clouds_midnight", "Clouds Midnight" )
                  , ( "cobalt", "Cobalt" )
                  , ( "dracula", "Dracula" )
                  , ( "github_dark", "Github Dark" )
                  , ( "gob", "Green on Black" )
                  , ( "gruvbox", "Gruvbox" )
                  , ( "gruvbox_dark_hard", "Gruvbox - Dark Hard" )
                  , ( "idle_fingers", "Idle Fingers" )
                  , ( "kr_theme", "krTheme" )
                  , ( "merbivore", "Merbivore" )
                  , ( "merbivore_soft", "Merbivore Soft" )
                  , ( "mono_industrial", "Mono Industrial" )
                  , ( "monokai", "Monokai" )
                  , ( "one_dark", "One Dark" )
                  , ( "nord_dark", "Nord Dark" )
                  , ( "pastel_on_dark", "Pastel on dark" )
                  , ( "solarized_dark", "Solarized Dark" )
                  , ( "terminal", "Terminal" )
                  , ( "tomorrow_night", "Tomorrow Night" )
                  , ( "tomorrow_night_blue", "Tomorrow Night Blue" )
                  , ( "tomorrow_night_bright", "Tomorrow Night Bright" )
                  , ( "tomorrow_night_eighties", "Tomorrow Night 80s" )
                  , ( "twilight", "Twilight" )
                  , ( "vibrant_ink", "Vibrant Ink" )
                  ]
                    |> List.map op
                    |> Html.optgroup [ Attr.attribute "label" (Trans.cDark lang) ]
                ]
            ]
        ]


option : String -> ( String, String ) -> Html Msg
option current ( val, text ) =
    Html.option
        [ Attr.value val
        , Attr.selected (val == current)
        ]
        [ Html.text text ]


{-| The button to open and close the table of contents.
-}
btnIndex : Lang -> Bool -> Html Msg
btnIndex lang open =
    btnIcon
        { title = Trans.baseToc lang
        , tabbable = True
        , msg = Just (Toggle TableOfContents)
        , icon =
            if open then
                "icon-close"

            else
                "icon-table"
        }
        [ Attr.id "lia-btn-toc"
        , Attr.class "lia-btn lia-btn--transparent"
        , A11y_Aria.controls [ "lia-toc" ]
        , A11y_Aria.expanded open
        ]


btnSupport : Lang -> Bool -> Html Msg
btnSupport lang open =
    btnIcon
        { title = Trans.confSettings lang
        , tabbable = True
        , msg = Just (Toggle SupportMenu)
        , icon =
            if open then
                "icon-close"

            else
                "icon-more"
        }
        [ Attr.class "lia-btn lia-btn--transparent"
        , A11y_Aria.controls [ "lia-support-menu" ]
        , Attr.id "lia-btn-support"
        , A11y_Aria.expanded open
        ]


btnChat : { id : String, lang : Lang, tabbable : Bool, hide : Bool, chat : { show : Bool, updates : Bool } } -> Html Msg
btnChat { id, lang, tabbable, hide, chat } =
    if hide then
        Html.span [ Attr.style "margin-inline-end" "4rem" ] []

    else
        let
            ( title, iconName ) =
                if chat.show then
                    ( Trans.chatClose lang, "icon-chat-open" )

                else if chat.updates then
                    ( Trans.chatNew lang, "icon-chat-new" )

                else
                    ( Trans.chatOpen lang, "icon-chat-close" )
        in
        btnIcon
            { title = title
            , tabbable = tabbable
            , msg = Just (Toggle Chat)
            , icon = iconName
            }
            [ Attr.id id
            , Attr.class "lia-btn lia-btn--transparent"
            , A11y_Aria.expanded chat.show
            , Attr.style "margin-inline-end" "1rem"
            , Attr.class <|
                if chat.updates && not chat.show then
                    "shake"

                else
                    ""
            ]


{-| -}
menuMode : Lang -> Bool -> Settings -> List (Html Msg)
menuMode lang tabbable settings =
    let
        grouping =
            group ShowModes
    in
    [ actionBtn
        { grouping = grouping
        , action = ShowModes
        , open = settings.action == Just ShowModes
        , icon =
            modes
                |> List.filter (.mode >> (==) settings.mode)
                |> List.head
                |> Maybe.map .icon
                |> Maybe.withDefault ""
        , title = Trans.modeMode lang ++ ": " ++ modeToString settings.mode lang
        , attributes = []
        }
    , modes
        |> List.map (viewMode grouping lang tabbable settings.mode)
        |> submenu ShowModes grouping (settings.action == Just ShowModes)
    ]


{-| -}
menuSettings : Int -> Lang -> Bool -> Settings -> List (Html Msg)
menuSettings width lang tabbable settings =
    let
        grouping =
            group ShowSettings
    in
    [ actionBtn
        { grouping = grouping
        , action = ShowSettings
        , open = settings.action == Just ShowSettings
        , icon = "icon-settings"
        , title = Trans.confSettings lang
        , attributes = []
        }
    , viewSettings lang tabbable width settings
        |> submenu ShowSettings grouping (settings.action == Just ShowSettings)
    ]


{-| -}
menuTranslations : String -> Definition -> Lang -> Bool -> Settings -> List (Html Msg)
menuTranslations languageCode defintion lang tabbable settings =
    [ Html.button
        (action ShowTranslations
            (settings.action == Just ShowTranslations)
            [ lang
                |> Trans.confTranslations
                |> Attr.title
            , lang
                |> Trans.confTranslations
                |> A11y_Aria.label
            ]
        )
        [ Html.span
            [ Attr.class "notranslate lia-support-menu__lang"
            , Attr.attribute "translate" "no"
            ]
            [ languageCode
                |> String.toUpper
                |> Html.text
            ]
        ]
    , defintion.translation
        |> viewTranslations lang tabbable
        |> (settings.translateWithGoogle
                |> translateWithGoogle lang tabbable
                |> List.append
           )
        |> submenu ShowTranslations
            (group ShowTranslations)
            (settings.action == Just ShowTranslations)
    ]


translateWithGoogle : Lang -> Bool -> Maybe Bool -> List (Html Msg)
translateWithGoogle lang tabbable bool =
    case bool of
        Just True ->
            [ Html.div
                (group ShowTranslations
                    [ Attr.id "google_translate_element"
                    , Attr.tabindex -1
                    ]
                )
                []
            , divider
            ]

        Just False ->
            [ Html.label
                [ Attr.class "lia-label"
                , A11y_Aria.hidden (not tabbable)
                ]
                [ Html.input
                    (group ShowTranslations
                        [ Attr.type_ "checkbox"
                        , Attr.class "lia-checkbox"
                        , Attr.checked False
                        , onClick (Toggle TranslateWithGoogle)
                        , A11y_Key.tabbable tabbable
                        , Attr.id "lia-checkbox-google_translate"
                        ]
                    )
                    []
                , lang
                    |> Trans.translateWithGoogle
                    |> Html.text
                ]
            , divider
            ]

        Nothing ->
            []


{-| -}
menuShare : String -> Sync.Settings -> Lang -> Bool -> Settings -> List (Html Msg)
menuShare url sync lang tabbable settings =
    let
        grouping =
            group ShowShare
    in
    [ case ( settings.sync, settings.hasShareApi ) of
        ( Nothing, Nothing ) ->
            [ Attr.class "lia-btn--transparent hide-md-down" ]
                |> grouping
                |> btnIcon
                    { title = Trans.confShare lang
                    , icon = "icon-social"
                    , tabbable = False
                    , msg = Nothing
                    }

        _ ->
            actionBtn
                { grouping = grouping
                , action = ShowShare
                , open = settings.action == Just ShowShare
                , icon = "icon-social"
                , title = Trans.confShare lang
                , attributes = []
                }
    , Html.i
        [ Attr.class "icon icon-social hide-md-up"
        , lang
            |> Trans.confShare
            |> Attr.title
        ]
        []
    , [ -- only when visible: open share menu, or the open support menu on small screens
        if settings.hasShareApi /= Nothing && (settings.action == Just ShowShare || settings.support_menu) then
            qrCodeView lang tabbable False True url

        else
            Html.text ""
      , if settings.hasShareApi == Just True then
            btn
                { title = ""
                , tabbable = tabbable
                , msg = Just (ShareCourse url)
                }
                [ Attr.style "width" "100%"
                , Attr.style "justify-content" "center"
                ]
                [ Html.label [] [ Html.text <| Trans.confShareVia lang ] ]

        else
            Html.text ""
      , divider
      , if Sync.isSupported sync && settings.sync /= Nothing then
            btn
                { title = "Classroom"
                , tabbable = tabbable
                , msg = Just (Toggle Sync)
                }
                (grouping [])
                [ Sync.title sync ]

        else
            Html.text ""
      ]
        |> submenu ShowShare grouping (settings.action == Just ShowShare)
    ]


{-| -}
menuEdit : String -> Lang -> Bool -> Settings -> List (Html Msg)
menuEdit url lang tabbable _ =
    [ Html.a
        [ Attr.class "lia-btn lia-btn--transparent lia-btn--tag "
        , Attr.href url
        , A11y_Key.tabbable tabbable
        , A11y_Aria.hidden (not tabbable)
        , Attr.target "_blank"
        , lang
            |> Trans.confEdit
            |> Attr.title
        ]
        [ icon "icon-edit" []
        , Html.span
            [ Attr.style "margin-inline-start" "1rem"
            , Attr.class " hide-md-up"
            ]
            [ lang
                |> Trans.confEdit
                |> Html.text
            ]
        ]
    ]


{-| -}
menuInformation : Maybe String -> Definition -> Lang -> Bool -> Settings -> List (Html Msg)
menuInformation repositoryURL definition lang tabbable settings =
    let
        grouping =
            group ShowInformation
    in
    [ Html.i
        (grouping
            [ Attr.class "icon icon-info hide-md-up"
            , lang
                |> Trans.confInformation
                |> Attr.title
            ]
        )
        []
    , actionBtn
        { grouping = grouping
        , action = ShowInformation
        , open = settings.action == Just ShowInformation
        , icon = "icon-info"
        , title = Trans.confInformation lang
        , attributes = []
        }
    , viewInformation grouping lang tabbable repositoryURL definition
        |> submenu ShowInformation grouping (settings.action == Just ShowInformation)
    ]


actionBtn :
    { grouping : List (Attribute Msg) -> List (Attribute Msg)
    , action : Action
    , open : Bool
    , icon : String
    , title : String
    , attributes : List (Attribute Msg)
    }
    -> Html Msg
actionBtn conf =
    [ Attr.id (toggleID conf.action)
    , A11y_Aria.expanded conf.open
    , A11y_Aria.controls [ submenuID conf.action ]
    , closeOnEscape conf.action conf.open
    , Attr.class "lia-btn--transparent hide-md-down"
    ]
        |> List.append conf.attributes
        |> conf.grouping
        |> btnIcon
            { title = conf.title
            , icon = conf.icon
            , tabbable = True
            , msg = Just <| doAction conf.action
            }


action : Action -> Bool -> (List (Html.Attribute Msg) -> List (Html.Attribute Msg))
action msg open =
    [ onClick (doAction msg)
    , Attr.id (toggleID msg)
    , A11y_Key.onKeyDown
        (if open then
            [ A11y_Key.escape (doAction msg) ]

         else
            [ A11y_Key.down (doAction msg) ]
        )
    , Attr.class "lia-btn lia-btn--transparent hide-md-down"
    , A11y_Aria.expanded open
    , A11y_Aria.controls [ submenuID msg ]
    ]
        |> group msg
        |> List.append


{-| Lazy menu entries for `header`. The menus are part of every frame and
contain many event handlers, which Elm would otherwise patch on every frame.
Lazy needs stable references, thus the menu function has to be a top-level
function, additional parameters are passed separately with `menu1` and `menu2`.
-}
menu : String -> (Lang -> Bool -> Settings -> List (Html Msg)) -> Lang -> Bool -> Settings -> Html Msg
menu =
    Lazy.lazy5 menuItem


{-| -}
menu1 : String -> (a -> Lang -> Bool -> Settings -> List (Html Msg)) -> a -> Lang -> Bool -> Settings -> Html Msg
menu1 =
    Lazy.lazy6 (\class fn a -> menuItem class (fn a))


{-| -}
menu2 : String -> (a -> b -> Lang -> Bool -> Settings -> List (Html Msg)) -> a -> b -> Lang -> Bool -> Settings -> Html Msg
menu2 =
    Lazy.lazy7 (\class fn a b -> menuItem class (fn a b))


menuItem : String -> (Lang -> Bool -> Settings -> List (Html Msg)) -> Lang -> Bool -> Settings -> Html Msg
menuItem class fn lang tabbable settings =
    Html.li
        [ Attr.class <| "nav__item lia-support-menu__item lia-support-menu__item--" ++ class ]
        (fn lang tabbable settings)


doAction : Action -> Msg
doAction =
    Action >> Toggle


{-| The header with the support menu, `buttons` are the menus (`menu`, `menu1`,
`menu2`), the first one (chat) is only shown if online.
-}
header :
    { online : Bool
    , active : Bool
    , lang : Lang
    , screen : Screen
    , settings : Settings
    , logo : String
    , progress : String
    , buttons : List (Lang -> Bool -> Settings -> Html Msg)
    }
    -> Html Msg
header { online, active, lang, screen, settings, logo, progress, buttons } =
    let
        tabbable =
            screen.width >= Const.globalBreakpoints.md || settings.support_menu
    in
    [ Html.div [ Attr.class "lia-header__left" ] []
    , Html.div [ Attr.class "lia-header__middle" ]
        [ Html.img
            [ Attr.src logo
            , Attr.class "lia_header__logo"
            , Attr.alt ""
            ]
            []
        ]
    , Html.div [ Attr.class "lia-header__right" ]
        [ Html.div
            [ Attr.class "lia-support-menu"
            , Attr.id "lia-support-menu"
            , Attr.class <|
                if settings.support_menu then
                    "lia-support-menu--open"

                else
                    "lia-support-menu--closed"
            ]
            [ if online then
                Html.div
                    [ Attr.class "lia-support-menu__toggler"
                    , Attr.style "left" "-4rem"
                    ]
                    [ btnChat { id = "lia-btn-chat-toggler", lang = lang, hide = settings.support_menu, tabbable = True, chat = settings.chat }
                    , btnSupport lang settings.support_menu
                    ]

              else
                Html.div [ Attr.class "lia-support-menu__toggler" ]
                    [ btnSupport lang settings.support_menu
                    ]
            , Html.div
                [ Attr.class "lia-support-menu__collapse"
                ]
                [ buttons
                    |> (if online then
                            identity

                        else
                            List.tail >> Maybe.withDefault []
                       )
                    |> List.map (\fn -> fn lang tabbable settings)
                    |> Html.ul
                        [ Attr.class "nav lia-support-menu__nav flow" ]
                ]
            ]
        ]
    , Html.div [ Attr.class "lia-progress", Attr.style "width" progress ] []
    ]
        |> Html.header
            (deactivate (not active)
                [ Attr.class "lia-header"
                , Attr.id "lia-toolbar-nav"
                ]
            )
