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
            "lia-toc--hidden"

        else
            "lia-toc--visible"
    , Attr.class <|
        if model.support_menu then
            "lia-support--hidden"

        else
            "lia-support--visible"
    , Attr.class <|
        case model.mode of
            Textbook ->
                "lia-mode--textbook"

            Presentation ->
                "lia-mode--presentation"

            Slides ->
                "lia-mode--slides"
    ]


viewSettings : Lang -> Settings -> List (Html Msg)
viewSettings lang settings =
    [ viewLightMode lang settings.light
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewTheme lang settings.theme
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewEditorTheme lang settings.editor
    , Html.hr [ Attr.class "nav__divider" ] []
    , viewSizing lang settings.font_size
    ]


viewLightMode : Lang -> Bool -> Html Msg
viewLightMode _ isLight =
    Html.button
        [ Attr.class "lia-btn lia-btn--transparent"
        , onClick (Toggle Light)
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


viewTheme : Lang -> String -> Html Msg
viewTheme lang theme =
    [ ( "turquoise", "Türkis", "is-turquoise mr-1" )
    , ( "blue", Trans.cBlue lang, "is-blue mr-1" )
    , ( "red", "Rot", "is-red mr-1" )
    , ( "yellow", "Gelb", "is-yellow" )
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
                    ]
                    []
                ]
            )
        |> List.concat
        |> Html.div [ Attr.class "lia-radio-group lia-settings-theme-colors" ]


viewModes : Lang -> Settings -> List (Html Msg)
viewModes lang settings =
    [ viewMode lang Textbook settings.mode "lia-mode-textbook" "icon-book" "mb-1"
    , viewMode lang Presentation settings.mode "lia-mode-presentation" "icon-presentation" "mb-1"
    , viewMode lang Slides settings.mode "lia-mode-slides" "icon-slides" ""
    ]


viewMode : Lang -> Mode -> Mode -> String -> String -> String -> Html Msg
viewMode lang mode activeMode id iconName additionalCSSClass =
    Html.button
        [ Attr.id id
        , Attr.class <| "lia-btn lia-btn--transparent lia-btn--icon " ++ additionalCSSClass
        , onClick (SwitchMode mode)
        , A11y_Key.onKeyDown [ A11y_Key.enter (SwitchMode mode) ]
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


viewSizing : Lang -> Int -> Html Msg
viewSizing lang int =
    Html.div []
        [ Html.text <| Trans.baseFont lang ++ ":"
        , btnFont "-" (Trans.baseDec lang) (ChangeFontSize False)
        , Html.text (String.fromInt int ++ "%")
        , btnFont "+" (Trans.baseInc lang) (ChangeFontSize True)
        ]


btnFont : String -> String -> msg -> Html msg
btnFont str title msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class "lia-btn lia-slide-control lia-left"
        ]
        [ Html.text str ]


bold : String -> Html msg
bold =
    Html.text >> List.singleton >> Html.b []


viewInformation : Lang -> Definition -> List (Html Msg)
viewInformation lang definition =
    []
        |> CList.addIf (definition.attributes /= [])
            [ bold "Attributes:"
            , Html.br [] []
            , viewAttributes lang definition.attributes
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
                [ Attr.href definition.email, Attr.class "lia-link" ]
                [ Html.text definition.email ]
            ]
        |> CList.addIf (definition.author /= "")
            [ bold <| Trans.infoAuthor lang
            , Html.text definition.author
            ]
        |> List.map (Html.span [])


viewAttributes : Lang -> List Inlines -> Html Msg
viewAttributes lang =
    List.map (thanks lang) >> Html.span []


thanks : Lang -> Inlines -> Html Msg
thanks lang to =
    Html.span []
        [ Html.hr [] []
        , to
            |> List.map (view_inf Array.empty lang)
            |> Html.div []
        ]
        |> Html.map (\_ -> Ignore)


viewTranslations : Lang -> Dict String String -> List (Html Msg)
viewTranslations lang =
    Dict.toList
        >> List.map
            (\( title, url ) ->
                Html.a
                    [ Attr.href url, Attr.class "lia-link" ]
                    [ Html.text title, Html.br [] [] ]
            )
        >> List.append
            [ Html.span [ Attr.class "lia-link active" ] [ Html.text "TODO" ]
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


viewEditorTheme : Lang -> String -> Html Msg
viewEditorTheme lang theme =
    let
        op =
            option theme
    in
    Html.div [ Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
        [ Html.text "Editor"
        , Html.select [ onInput ChangeEditor ]
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
        , Attr.class "lia-btn lia-btn--transparent"
        , Attr.id "lia-btn-toc"
        , A11y_Aria.controls "lia-toc"
        ]
        [ Html.i
            [ Attr.class "lia-btn__icon icon"
            , Attr.class <|
                if open then
                    "icon-table"

                else
                    "icon-close"
            ]
            []
        ]


btnSupport : Bool -> Html Msg
btnSupport open =
    Html.button
        [ onClick <| Toggle SupportMenu
        , Attr.id "lia-btn-support"
        , Attr.class "lia-btn lia-btn--transparent lia-support-menu__toggler"
        , Attr.type_ "button"
        ]
        [ Html.i
            [ Attr.class "lia-btn__icon icon"
            , Attr.class <|
                if open then
                    "icon-more"

                else
                    "icon-close"
            ]
            []
        ]


menuMode : Lang -> Settings -> List (Html Msg)
menuMode lang settings =
    [ actionBtn ShowModes "icon-presentation" "Mode"
    , viewModes lang settings
        |> submenu (settings.action == Just ShowModes)
    ]


menuSettings : Lang -> Settings -> List (Html Msg)
menuSettings lang settings =
    [ lang
        |> Trans.confSettings
        |> actionBtn ShowSettings "icon-settings"
    , viewSettings lang settings
        |> submenu (settings.action == Just ShowSettings)
    ]


menuTranslations : Lang -> Definition -> Settings -> List (Html Msg)
menuTranslations lang defintion settings =
    [ Html.button
        (action ShowTranslations
            [ lang
                |> Trans.confTranslations
                |> Attr.title
            ]
        )
        [ Html.text <| String.toUpper defintion.language
        ]
    , defintion.translation
        |> viewTranslations lang
        |> submenu (settings.action == Just ShowTranslations)
    ]


menuShare : Lang -> String -> Settings -> List (Html Msg)
menuShare lang url settings =
    [ lang
        |> Trans.confShare
        |> actionBtn Share "icon-social"
    , [ qrCodeView url ]
        |> submenu (settings.action == Just Share)
    ]


menuInformation : Lang -> Definition -> Settings -> List (Html Msg)
menuInformation lang definition settings =
    [ lang
        |> Trans.confInformation
        |> actionBtn ShowInformation "icon-info"
    , viewInformation lang definition
        |> submenu (settings.action == Just ShowInformation)
    ]


actionBtn : Action -> String -> String -> Html Msg
actionBtn msg iconName title =
    Html.button
        (action msg
            [ Attr.class <| "icon " ++ iconName
            , Attr.title title
            ]
        )
        []


action : Action -> (List (Html.Attribute Msg) -> List (Html.Attribute Msg))
action msg =
    List.append
        [ onClick (doAction msg)
        , A11y_Key.onKeyDown [ A11y_Key.escape (doAction Close) ]
        , Attr.class "hide-md-down"
        ]


doAction : Action -> Msg
doAction =
    Action >> Toggle
