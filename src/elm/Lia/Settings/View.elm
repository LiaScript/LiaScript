module Lia.Settings.View exposing
    ( btnIndex
    , btnSupport
    , design
    , menuInformation
    , menuMode
    , menuSettings
    , menuShare
    , menuTranslations
    )

import Accessibility as A11y
import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array
import Conditional.List as CList
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Settings.Types exposing (Action(..), Mode(..), Settings)
import Lia.Settings.Update exposing (Msg(..), Toggle(..))
import QRCode
import Translations as Trans exposing (Lang)


design : Settings -> List (Html.Attribute msg)
design model =
    let
        float =
            String.fromFloat (toFloat model.font_size / 100.0)
    in
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


viewSettings : Lang -> Bool -> Settings -> List (Html Msg)
viewSettings lang tabbable settings =
    [ viewLightMode lang tabbable settings.light
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewTheme lang tabbable settings.theme
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewEditorTheme lang tabbable settings.editor
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewSizing lang tabbable settings.font_size
    ]


viewLightMode : Lang -> Bool -> Bool -> Html Msg
viewLightMode _ tabbable isLight =
    Html.button
        [ Attr.class "lia-btn lia-btn--transparent"
        , onClick (Toggle Light)
        , A11y_Key.tabbable tabbable
        ]
        [ Html.i
            [ Attr.class "lia-btn__icon icon"
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
                    "Dark-Mode"

                else
                    "Light-Mode"
            ]
        ]


viewTheme : Lang -> Bool -> String -> Html Msg
viewTheme lang tabbable theme =
    [ ( "turquoise", Trans.cTurquoise lang, "is-turquoise mr-1" )
    , ( "blue", Trans.cBlue lang, "is-blue mr-1" )
    , ( "red", Trans.cRed lang, "is-red mr-1" )
    , ( "yellow", Trans.cYellow lang, "is-yellow" )
    ]
        |> List.map
            (\( color, name, styleClass ) ->
                [ Html.input
                    [ Attr.type_ "radio"
                    , Attr.class <| "lia-radio " ++ styleClass
                    , Attr.id <| "lia-theme-color-" ++ color
                    , Attr.name "lia-theme-color"
                    , Attr.checked (theme == color)
                    , onClick (ChangeTheme color)
                    , Attr.title name
                    , A11y_Key.tabbable tabbable
                    ]
                    []
                ]
            )
        |> List.concat
        |> Html.div [ Attr.class "lia-radio-group lia-settings-theme-colors" ]


viewModes : Lang -> Bool -> Settings -> List (Html Msg)
viewModes lang tabbable settings =
    [ viewMode lang tabbable Textbook settings.mode "lia-mode-textbook" "icon-book" "mb-1"
    , viewMode lang tabbable Presentation settings.mode "lia-mode-presentation" "icon-presentation" "mb-1"
    , viewMode lang tabbable Slides settings.mode "lia-mode-slides" "icon-slides" ""
    ]


viewMode : Lang -> Bool -> Mode -> Mode -> String -> String -> String -> Html Msg
viewMode lang tabbable mode activeMode id iconName additionalCSSClass =
    Html.button
        [ Attr.id id
        , Attr.class <| "lia-btn lia-btn--transparent " ++ additionalCSSClass
        , onClick (SwitchMode mode)
        , A11y_Key.onKeyDown [ A11y_Key.enter (SwitchMode mode) ]
        , A11y_Key.tabbable tabbable
        ]
        [ Html.i [ Attr.class <| "lia-btn__icon icon " ++ iconName ] []
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


reset : Html Msg
reset =
    Html.button
        [ onClick Reset ]
        [ Html.text "reset course" ]


viewSizing : Lang -> Bool -> Int -> Html Msg
viewSizing lang tabbable int =
    Html.div []
        [ Html.text <| Trans.baseFont lang ++ ":"
        , btnFont "icon-minus" tabbable (Trans.baseDec lang) (ChangeFontSize False)
        , Html.text (String.fromInt int ++ "%")
        , btnFont "icon-plus" tabbable (Trans.baseInc lang) (ChangeFontSize True)
        ]


btnFont : String -> Bool -> String -> msg -> Html msg
btnFont str tabbable title msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class <| "lia-btn lia-btn--icon lia-btn--transparent " ++ str
        , A11y_Key.tabbable tabbable
        ]
        []


bold : String -> Html msg
bold =
    Html.text >> List.singleton >> Html.strong []


viewInformation : Lang -> Bool -> Definition -> List (Html Msg)
viewInformation lang tabbable definition =
    []
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
                ]
                [ Html.text definition.email ]
            ]
        |> CList.addIf (definition.comment /= [])
            [ bold "Comment"
            , Html.br [] []
            , if tabbable then
                definition.comment
                    |> inlines lang

              else
                Html.text ""
            ]
        |> CList.addIf (definition.author /= "")
            [ bold <| Trans.infoAuthor lang
            , Html.text definition.author
            ]
        |> List.map (Html.span [])


viewAttributes : Lang -> List Inlines -> Html Msg
viewAttributes lang =
    List.map (thanks lang) >> Html.div []


thanks : Lang -> Inlines -> Html Msg
thanks lang to =
    Html.span []
        [ Html.hr [] []
        , inlines lang to
        ]
        |> Html.map (\_ -> Ignore)


inlines lang =
    List.map (view_inf Array.empty lang)
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
                    ]
                    [ Html.text title, Html.br [] [] ]
            )
        >> List.append
            [ Html.span [ Attr.class "lia-link active" ]
                [ Trans.baseLang lang
                    |> Html.text
                ]
            ]


submenu : Bool -> List (Html Msg) -> Html Msg
submenu isActive =
    Html.div
        [ Attr.class "lia-support-menu__submenu"
        , Attr.class <|
            if isActive then
                "active"

            else
                ""
        , A11y_Widget.checked (Just isActive)
        ]


qrCodeView : String -> Html msg
qrCodeView =
    QRCode.fromString
        >> Result.map (QRCode.toSvgWithoutQuietZone [])
        >> Result.withDefault (Html.text "Error while encoding to QRCode.")


viewEditorTheme : Lang -> Bool -> String -> Html Msg
viewEditorTheme lang tabbable theme =
    let
        op =
            option theme
    in
    Html.div [ Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
        [ Html.text "Editor"
        , Html.select
            [ onInput ChangeEditor
            , A11y_Key.tabbable tabbable
            ]
            [ [ ( "chrome", "Chrome" )
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
                |> Html.optgroup [ Attr.attribute "label" (Trans.cBright lang) ]
            , [ ( "ambiance", "Ambiance" )
              , ( "chaos", "Chaos" )
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
                |> Html.optgroup [ Attr.attribute "label" (Trans.cDark lang) ]
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
    Html.button
        [ onClick <| Toggle TableOfContents
        , Attr.title (Trans.baseToc lang)
        , Attr.class "lia-btn lia-btn--icon lia-btn--transparent icon"
        , Attr.class <|
            if open then
                "icon-close"

            else
                "icon-table"
        , Attr.id "lia-btn-toc"
        , A11y_Aria.controls "lia-toc"
        , A11y_Widget.hasMenuPopUp
        , A11y_Widget.expanded open
        ]
        []


btnSupport : Bool -> Html Msg
btnSupport open =
    Html.button
        [ onClick <| Toggle SupportMenu
        , Attr.id "lia-btn-support"
        , Attr.class "lia-btn lia-btn--icon lia-btn--transparent lia-support-menu__toggler icon"
        , Attr.class <|
            if open then
                "icon-close"

            else
                "icon-more"
        , Attr.type_ "button"
        ]
        []


menuMode : Lang -> Bool -> Settings -> List (Html Msg)
menuMode lang tabbable settings =
    [ lang
        |> Trans.modeMode
        |> actionBtn ShowModes
            (settings.action == Just ShowModes)
            "icon-presentation"
    , viewModes lang tabbable settings
        |> submenu (settings.action == Just ShowModes)
    ]


menuSettings : Lang -> Bool -> Settings -> List (Html Msg)
menuSettings lang tabbable settings =
    [ lang
        |> Trans.confSettings
        |> actionBtn ShowSettings
            (settings.action == Just ShowSettings)
            "icon-settings"
    , viewSettings lang tabbable settings
        |> submenu (settings.action == Just ShowSettings)
    ]


menuTranslations : Definition -> Lang -> Bool -> Settings -> List (Html Msg)
menuTranslations defintion lang tabbable settings =
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
        [ Html.text <| String.toUpper defintion.language
        ]
    , defintion.translation
        |> viewTranslations lang tabbable
        |> submenu (settings.action == Just ShowTranslations)
    ]


menuShare : String -> Lang -> Bool -> Settings -> List (Html Msg)
menuShare url lang _ settings =
    [ lang
        |> Trans.confShare
        |> actionBtn Share
            (settings.action == Just Share)
            "icon-social"
    , Html.i
        [ Attr.class "icon icon-social hide-md-up"
        , lang
            |> Trans.confInformation
            |> Attr.title
        ]
        []
    , [ qrCodeView url
      ]
        |> submenu (settings.action == Just Share)
    ]


menuInformation : Definition -> Lang -> Bool -> Settings -> List (Html Msg)
menuInformation definition lang tabbable settings =
    [ Html.i
        [ Attr.class "icon icon-info hide-md-up"
        , lang
            |> Trans.confInformation
            |> Attr.title
        ]
        []
    , lang
        |> Trans.confInformation
        |> actionBtn
            ShowInformation
            (settings.action == Just ShowInformation)
            "icon-info"
    , viewInformation lang tabbable definition
        |> submenu (settings.action == Just ShowInformation)
    ]


actionBtn : Action -> Bool -> String -> String -> Html Msg
actionBtn msg open iconName title =
    Html.button
        (action msg
            open
            [ Attr.class <| "lia-btn--icon icon " ++ iconName
            , Attr.title title
            ]
        )
        []


action : Action -> Bool -> (List (Html.Attribute Msg) -> List (Html.Attribute Msg))
action msg open =
    List.append
        [ onClick (doAction msg)
        , A11y_Key.onKeyDown [ A11y_Key.escape (doAction Close) ]
        , Attr.class "lia-btn lia-btn--transparent hide-md-down"
        , A11y_Widget.hasDialogPopUp
        , A11y_Widget.expanded open
        ]


doAction : Action -> Msg
doAction =
    Action >> Toggle
