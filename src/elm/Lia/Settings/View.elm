module Lia.Settings.View exposing
    ( btnIndex
    , btnInformation
    , btnMode
    , btnSettings
    , btnShare
    , btnTranslations
    , design
    , view
    )

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


view :
    Lang
    -> String
    -> Definition
    -> Settings
    -> Html Msg -- String -> String -> Maybe Event -> Definition -> Html Msg
view lang url definition settings =
    case settings.action of
        Nothing ->
            Html.text ""

        Just ShowModes ->
            viewModes lang settings

        Just ShowSettings ->
            viewSettings lang settings

        Just Share ->
            qrCodeView url

        Just ShowTranslations ->
            viewTranslations definition.translation

        Just ShowInformation ->
            viewInformation lang definition


design : Settings -> List (Html.Attribute msg)
design model =
    let
        float =
            String.fromFloat (toFloat model.font_size / 100.0)
    in
    [ Attr.class
        ("lia-canvas lia-theme-"
            ++ model.theme
            ++ " lia-variant-"
            ++ (if model.light then
                    "light"

                else
                    "dark"
               )
        )
    ]


viewSettings : Lang -> Settings -> Html Msg
viewSettings lang settings =
    [ viewLightMode lang settings.light
    , Html.hr [] []
    , viewTheme lang settings.theme
    , Html.hr [] []
    , viewEditorTheme lang settings.editor
    , Html.hr [] []
    , viewSizing lang settings.font_size
    ]
        |> Html.div
            [ Attr.style "position" "absolute"
            , Attr.style "top" "50px"
            , Attr.style "zIndex" "1000"
            , Attr.style "color" "red"
            ]


viewLightMode : Lang -> Bool -> Html Msg
viewLightMode _ isLight =
    Html.span []
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked isLight
            , onClick (Toggle Light)
            ]
            []
        , Html.label []
            [ Html.text <|
                if isLight then
                    "Dark-Mode"

                else
                    "Light-Mode"
            ]
        ]


viewTheme : Lang -> String -> Html Msg
viewTheme lang theme =
    [ ( "turquoise", "Türkis" )
    , ( "blue", Trans.cBlue lang )
    , ( "red", "Rot" )
    , ( "yellow", "Gelb" )
    ]
        |> List.map
            (\( color, name ) ->
                [ Html.input
                    [ Attr.type_ "radio"
                    , Attr.checked (theme == color)
                    , onClick (ChangeTheme color)
                    ]
                    []
                , Html.label [] [ Html.text name ]
                ]
            )
        |> List.concat
        |> Html.span [ Attr.class "lia-settings__theme-colors" ]


viewModes : Lang -> Settings -> Html Msg
viewModes lang settings =
    [ viewMode lang Textbook settings.mode
    , Html.hr [] []
    , viewMode lang Presentation settings.mode
    , Html.hr [] []
    , viewMode lang Slides settings.mode
    ]
        |> Html.div
            [ Attr.style "position" "absolute"
            , Attr.style "top" "50px"
            , Attr.style "zIndex" "1000"
            , Attr.style "color" "red"
            ]


viewMode : Lang -> Mode -> Mode -> Html Msg
viewMode lang mode activeMode =
    Html.div []
        [ Html.input
            [ Attr.type_ "radio"
            , Attr.checked (mode == activeMode)
            , onClick (SwitchMode mode)
            ]
            []
        , Html.label []
            [ modeToString mode lang
                |> Html.text
            ]
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


viewInformation : Lang -> Definition -> Html Msg
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
        |> List.map (Html.div [])
        |> Html.div
            [ Attr.style "position" "absolute"
            , Attr.style "top" "50px"
            , Attr.style "zIndex" "1000"
            , Attr.style "color" "red"
            ]


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


viewTranslations : Dict String String -> Html Msg
viewTranslations =
    Dict.toList
        >> List.map
            (\( title, url ) ->
                Html.a
                    [ Attr.href url, Attr.class "lia-link" ]
                    [ Html.text title, Html.br [] [] ]
            )
        >> Html.div []


qrCodeView : String -> Html msg
qrCodeView =
    QRCode.fromString
        >> Result.map (QRCode.toSvgWithoutQuietZone [])
        >> Result.withDefault (Html.text "Error while encoding to QRCode.")
        >> List.singleton
        >> Html.div []


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


btnIndex : Lang -> Html Msg
btnIndex lang =
    Html.button
        [ onClick <| Toggle TableOfContents
        , Attr.title (Trans.baseToc lang)
        , Attr.class "lia-btn lia-toc-control lia-left"
        , Attr.id "lia-btn-toc"
        ]
        [ Html.text "toc" ]


btnMode : Lang -> Html Msg
btnMode _ =
    actionBtn ShowModes "Mode"


btnSettings : Lang -> Html Msg
btnSettings =
    Trans.confSettings
        >> actionBtn ShowSettings


btnTranslations : Lang -> Bool -> Html Msg
btnTranslations lang hide =
    if hide then
        Html.text ""

    else
        lang
            |> Trans.confTranslations
            |> actionBtn ShowTranslations


btnShare : Lang -> Html Msg
btnShare =
    Trans.confShare
        >> actionBtn Share


btnInformation : Lang -> Html Msg
btnInformation =
    Trans.confInformation
        >> actionBtn ShowInformation


actionBtn : Action -> String -> Html Msg
actionBtn msg title =
    Html.span [ doAction msg ]
        [ Html.text title ]


doAction : Action -> Html.Attribute Msg
doAction =
    Action >> Toggle >> onClick
