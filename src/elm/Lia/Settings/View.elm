module Lia.Settings.View exposing
    ( btnIndex
    , btnSupport
    , design
    , header
    , menuChat
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
import Accessibility.Widget as A11y_Widget
import Array
import Conditional.List as CList
import Const
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr exposing (width)
import Html.Events exposing (onClick, onInput)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Settings.Types
    exposing
        ( Action(..)
        , Mode(..)
        , Settings
        , TTS
        , fromGroup
        , toGroup
        )
import Lia.Settings.Update exposing (Msg(..), Toggle(..))
import Lia.Sync.Types as Sync
import Lia.Utils
    exposing
        ( blockKeydown
        , btn
        , btnIcon
        , noTranslate
        )
import Library.Group as Group
import QRCode
import Service.Database exposing (settings)
import Session exposing (Screen)
import Translations as Trans exposing (Lang)


design : Settings -> List (Html.Attribute msg)
design model =
    -- let
    --     float =
    --         String.fromFloat (toFloat model.font_size / 100.0)
    -- in
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
    , viewTooltips grouping lang tabbable width settings.tooltips
    , divider
    , viewTTSSettings grouping lang tabbable settings.tts
    ]


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
            , A11y_Widget.hidden (not tabbable)
            , Attr.id "lia-btn-light-mode"
            , Attr.style "width" "100%"
            ]
        )
        [ Html.i
            [ A11y_Widget.hidden True
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


menuChat : Lang -> Bool -> Settings -> List (Html Msg)
menuChat lang tabbable settings =
    [ btnIcon
        { title = "show chat"
        , tabbable = tabbable
        , msg = Just (Toggle Chat)
        , icon = "icon-mail"
        }
        [ Attr.id "lia-btn-toc"
        , Attr.class "lia-btn lia-btn--transparent"
        ]
    ]


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
                        , A11y_Widget.hidden (not tabbable)
                        , blockKeydown Ignore
                        ]
                    )
                    []
            )
        |> Html.div
            [ Attr.class "lia-radio-group lia-settings-theme-colors"
            , A11y_Role.radioGroup
            , lang
                |> Trans.cSchema
                |> A11y_Widget.label
            ]


viewModes : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Settings -> List (Html Msg)
viewModes grouping lang tabbable settings =
    [ viewMode grouping lang tabbable Textbook settings.mode "lia-mode-textbook" "icon-book" "mb-1"
    , viewMode grouping lang tabbable Presentation settings.mode "lia-mode-presentation" "icon-presentation" "mb-1"
    , viewMode grouping lang tabbable Slides settings.mode "lia-mode-slides" "icon-slides" ""
    ]


viewMode : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> Mode -> Mode -> String -> String -> String -> Html Msg
viewMode grouping lang tabbable mode activeMode id iconName additionalCSSClass =
    Html.button
        (grouping
            [ Attr.id id
            , Attr.class <| "lia-btn lia-btn--transparent " ++ additionalCSSClass
            , onClick (SwitchMode mode)
            , A11y_Key.onKeyDown [ A11y_Key.enter (SwitchMode mode) ]
            , A11y_Key.tabbable tabbable
            , A11y_Widget.hidden (not tabbable)
            , A11y_Role.menuItem
            , A11y_Widget.checked <| Just (mode == activeMode)
            ]
        )
        [ Html.i [ A11y_Widget.hidden True, Attr.class <| "lia-btn__icon icon " ++ iconName ] []
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
            , A11y_Widget.hidden (not tabbable)
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


viewTTSSettings : (List (Attribute Msg) -> List (Attribute Msg)) -> Lang -> Bool -> TTS -> Html Msg
viewTTSSettings grouping lang tabbable tts =
    Html.label
        [ Attr.class "lia-label"
        , A11y_Widget.hidden (not tabbable)
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
            , A11y_Widget.checked (Just (size == i))
            ]
        )
        [ Html.span (noTranslate []) [ Html.text (Trans.baseAbc lang) ] ]


bold : String -> Html msg
bold =
    Html.text >> List.singleton >> Html.strong []


viewInformation : Lang -> Bool -> Maybe String -> Definition -> List (Html Msg)
viewInformation lang tabbable repositoryURL definition =
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
                [ Attr.href definition.email
                , Attr.class "lia-link"
                , A11y_Key.tabbable tabbable
                , A11y_Widget.hidden (not tabbable)
                ]
                [ Html.text definition.email ]
            ]
        |> CList.addIf (definition.author /= "")
            [ bold <| Trans.infoAuthor lang
            , Html.text definition.author
            ]
        |> CList.addIf (definition.comment /= [])
            [ if tabbable then
                definition.comment
                    |> inlines lang

              else
                Html.text ""
            ]
        |> List.map (Html.span [])


viewRepository : String -> List (Html msg)
viewRepository url =
    [ bold "Repository: "
    , Html.a [ Attr.href url, Attr.target "_blank" ] [ Html.text url ]
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
                    [ Attr.href url
                    , Attr.class "lia-link"
                    , A11y_Key.tabbable tabbable
                    , A11y_Widget.hidden (not tabbable)
                    ]
                    [ Html.text title, Html.br [] [] ]
            )
        >> (::)
            (Html.span [ Attr.class "lia-link active" ]
                [ Trans.baseLang lang
                    |> Html.text
                ]
            )


submenu : (List (Attribute Msg) -> List (Attribute Msg)) -> Bool -> List (Html Msg) -> Html Msg
submenu grouping isActive =
    [ Attr.class "lia-support-menu__submenu"
    , Attr.class <|
        if isActive then
            "active"

        else
            ""
    , A11y_Widget.checked (Just isActive)
    , A11y_Role.menu
    ]
        |> grouping
        |> Html.div


qrCodeView : Lang -> Bool -> Maybe (List (Attribute Msg) -> List (Attribute Msg)) -> String -> Html Msg
qrCodeView lang tabbable grouping url =
    url
        |> QRCode.fromString
        |> Result.map
            (QRCode.toSvgWithoutQuietZone
                [ Attr.style "background-color" "#FFF"
                , Attr.style "padding" "0.4rem"
                , Attr.alt (Trans.qrCode lang ++ ": " ++ url)
                ]
                >> List.singleton
                >> btn
                    { title = "enlarge qr-code"
                    , tabbable = tabbable
                    , msg = Just (Toggle QRCode)
                    }
                    ([ Attr.style "width" "inherit"
                     , Attr.id "lia-button-qr-code"
                     , Attr.class "lia-btn--transparent"
                     , Attr.style "padding" "0  "
                     ]
                        |> (case grouping of
                                Nothing ->
                                    identity

                                Just grouping_ ->
                                    grouping_
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
        [ Html.label [ Attr.class "lia-label", A11y_Widget.hidden (not tabbable) ]
            [ Html.div [ Attr.style "margin-bottom" "0.4rem" ] [ Html.text <| Trans.baseEditor lang ++ ":" ]
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
                    |> Html.optgroup [ Attr.attribute "label" (Trans.cBright lang), A11y_Widget.hidden True ]
                , [ ( "ambiance", "Ambiance" )
                  , ( "chaos", "Chaos" )
                  , ( "cloud9_night", "Cloud9 Night" )
                  , ( "clouds_midnight", "Clouds Midnight" )
                  , ( "cobalt", "Cobalt" )
                  , ( "dracula", "Dracula" )
                  , ( "gob", "Green on Black" )
                  , ( "gruvbox", "Gruvbox" )
                  , ( "idle_fingers", "idle Fingers" )
                  , ( "kr_theme", "krTheme" )
                  , ( "merbivore", "Merbivore" )
                  , ( "merbivore_soft", "Merbivore Soft" )
                  , ( "mono_industrial", "Mono Industrial" )
                  , ( "monokai", "Monokai" )
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
                    |> Html.optgroup [ Attr.attribute "label" (Trans.cDark lang), A11y_Widget.hidden True ]
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
        , A11y_Aria.controls "lia-toc"
        , A11y_Widget.hasMenuPopUp
        , A11y_Widget.expanded open
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
        , A11y_Aria.controls "lia-support-menu"
        , Attr.id "lia-btn-support"
        , A11y_Widget.hasMenuPopUp
        , A11y_Widget.expanded open
        ]


btnChat : { lang : Lang, open : Bool } -> Html Msg
btnChat { lang, open } =
    btnIcon
        { title = Trans.confSettings lang
        , tabbable = True
        , msg = Just (Toggle Chat)
        , icon = "icon-mail"
        }
        [ Attr.class "lia-btn lia-btn--transparent"
        , A11y_Aria.controls "lia-chat"
        , A11y_Widget.hasMenuPopUp
        , A11y_Widget.expanded open
        , Attr.style "margin-right" "1rem"
        ]


menuMode : Lang -> Bool -> Settings -> List (Html Msg)
menuMode lang tabbable settings =
    let
        grouping =
            group ShowModes
    in
    [ lang
        |> Trans.modeMode
        |> actionBtn
            grouping
            ShowModes
            (settings.action == Just ShowModes)
            (case settings.mode of
                Presentation ->
                    "icon-presentation"

                Slides ->
                    "icon-slides"

                Textbook ->
                    "icon-book"
            )
    , viewModes grouping lang tabbable settings
        |> submenu grouping (settings.action == Just ShowModes)
    ]


menuSettings : Int -> Lang -> Bool -> Settings -> List (Html Msg)
menuSettings width lang tabbable settings =
    let
        grouping =
            group ShowSettings
    in
    [ lang
        |> Trans.confSettings
        |> actionBtn
            grouping
            ShowSettings
            (settings.action == Just ShowSettings)
            "icon-settings"
    , viewSettings lang tabbable width settings
        |> submenu grouping (settings.action == Just ShowSettings)
    ]


menuTranslations : String -> Definition -> Lang -> Bool -> Settings -> List (Html Msg)
menuTranslations languageCode defintion lang tabbable settings =
    let
        grouping =
            group ShowTranslations
    in
    [ Html.button
        (action ShowTranslations
            (settings.action == Just ShowTranslations)
            [ lang
                |> Trans.confTranslations
                |> Attr.title
            , lang
                |> Trans.confTranslations
                |> A11y_Widget.label
            ]
        )
        [ Html.span
            [ Attr.class "notranslate"
            , Attr.attribute "translate" "no"
            ]
            [ languageCode
                |> String.toUpper
                |> Html.text
            ]
        ]
    , defintion.translation
        |> viewTranslations lang tabbable
        |> (\l ->
                settings.translateWithGoogle
                    |> translateWithGoogle lang tabbable
                    |> List.append l
           )
        |> submenu grouping (settings.action == Just ShowTranslations)
    ]


translateWithGoogle : Lang -> Bool -> Maybe Bool -> List (Html Msg)
translateWithGoogle lang tabbable bool =
    case bool of
        Just True ->
            [ divider
            , Html.div (group ShowTranslations [ Attr.id "google_translate_element" ]) []
            ]

        Just False ->
            [ divider
            , Html.label
                [ Attr.class "lia-label"
                , A11y_Widget.hidden (not tabbable)
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
            ]

        Nothing ->
            []


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
            lang
                |> Trans.confShare
                |> actionBtn
                    grouping
                    ShowShare
                    (settings.action == Just ShowShare)
                    "icon-social"
    , Html.i
        [ Attr.class "icon icon-social hide-md-up"
        , lang
            |> Trans.confInformation
            |> Attr.title
        ]
        []
    , [ if settings.hasShareApi /= Nothing then
            qrCodeView lang tabbable (Just grouping) url

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
        |> submenu grouping (settings.action == Just ShowShare)
    ]


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
    , lang
        |> Trans.confInformation
        |> actionBtn
            grouping
            ShowInformation
            (settings.action == Just ShowInformation)
            "icon-info"
    , viewInformation lang tabbable repositoryURL definition
        |> submenu grouping (settings.action == Just ShowInformation)
    ]


actionBtn : (List (Attribute Msg) -> List (Attribute Msg)) -> Action -> Bool -> String -> String -> Html Msg
actionBtn grouping msg open iconName title =
    [ A11y_Widget.hasMenuPopUp
    , A11y_Widget.expanded open
    , A11y_Key.onKeyDown [ A11y_Key.escape (doAction Close) ]
    , Attr.class "lia-btn--transparent hide-md-down"
    ]
        |> grouping
        |> btnIcon
            { title = title
            , icon = iconName
            , tabbable = True
            , msg = Just <| doAction msg
            }


action : Action -> Bool -> (List (Html.Attribute Msg) -> List (Html.Attribute Msg))
action msg open =
    [ onClick (doAction msg)
    , A11y_Key.onKeyDown
        [ A11y_Key.escape (doAction Close)
        , A11y_Key.down (doAction msg)
        ]
    , Attr.class "lia-btn lia-btn--transparent hide-md-down"
    , A11y_Widget.hasMenuPopUp
    , A11y_Widget.expanded open
    ]
        |> group msg
        |> List.append


doAction : Action -> Msg
doAction =
    Action >> Toggle


header :
    Bool
    -> Lang
    -> Screen
    -> Settings
    -> String
    -> List ( Lang -> Bool -> Settings -> List (Html Msg), String )
    -> Html Msg
header online lang screen settings logo buttons =
    let
        tabbable =
            screen.width >= Const.globalBreakpoints.md || settings.support_menu
    in
    [ Html.div [ Attr.class "lia-header__left" ] []
    , Html.div [ Attr.class "lia-header__middle" ]
        [ Html.img
            [ Attr.src logo
            , Attr.class "lia_header__logo"
            , Attr.alt "logo"
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
                    , Attr.style "left" "-5rem"
                    ]
                    [ btnChat { lang = lang, open = True }
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
                    |> List.map
                        (\( fn, class ) ->
                            Html.li
                                [ Attr.class <| "nav__item lia-support-menu__item lia-support-menu__item--" ++ class
                                , A11y_Role.menuItem
                                , A11y_Widget.hasMenuPopUp
                                ]
                                (fn lang tabbable settings)
                        )
                    |> Html.ul
                        [ Attr.class "nav lia-support-menu__nav"
                        , A11y_Role.menuBar
                        , A11y_Key.tabbable False
                        ]
                ]
            ]
        ]
    ]
        |> Html.header
            [ Attr.class "lia-header"
            , Attr.id "lia-toolbar-nav"
            ]
