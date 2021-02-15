module Lia.Settings.View exposing
    ( btnIndex
    , btnMode
    , btnSettings
    , btnShare
    , btnTranslations
    , design
    , view
    )

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Settings.Types exposing (Action(..), Mode(..), Settings)
import Lia.Settings.Update exposing (Msg(..), Toggle(..))
import Port.Event exposing (Event)
import QRCode
import Translations as Trans exposing (Lang)


view :
    Lang
    -> Settings
    -> Html Msg -- String -> String -> Maybe Event -> Definition -> Html Msg
view lang settings =
    --url origin share defines =
    case settings.action of
        Nothing ->
            Html.text ""

        Just ShowModes ->
            viewModes lang settings

        Just ShowSettings ->
            viewSettings lang settings

        Just a ->
            Html.div []
                [ --Lazy.lazy2 view_settings settings lang
                  --, Lazy.lazy3 view_information lang settings.buttons.informations defines
                  -- , view_translations lang settings.buttons.translations (origin ++ "?") (Lia.Definition.Types.get_translations defines)
                  -- , qrCodeView settings.buttons.share url
                  Html.div
                    [ Attr.class "lia-settings", Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
                    [-- dropdown model.buttons.settings "settings" (Trans.confSettings lang) (Toggle <| Button BtnSettings)
                     --, dropdown model.buttons.informations "info" (Trans.confInformation lang) (Toggle <| Button BtnInformations)
                     --, dropdown model.buttons.translations "translate" (Trans.confTranslations lang) (Toggle <| Button BtnTranslations)
                     --, dropdown model.buttons.share "share" (Trans.confShare lang) (share |> Maybe.map ShareCourse |> Maybe.withDefault (Toggle <| Button BtnShare))
                    ]
                ]


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
    , Attr.style "height" <| "calc(100vh / " ++ float ++ ")"
    , Attr.style "width" <| "calc(100vw / " ++ float ++ ")"
    , Attr.style "transform" <| "scale(" ++ float ++ ")"
    , Attr.style "-webkit-transform-origin" "top left"
    , Attr.style "-moz-transform-origin" "top left"

    --, Attr.style "transform-origin" "bottom left"
    , Attr.style "transform-origin" "top left"
    , Attr.style "position" "absolute"
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


dropdown : Bool -> String -> String -> Msg -> Html Msg
dropdown active name alt msg =
    Html.button
        [ onClick msg
        , Attr.id <| "lia-btn-" ++ name
        , Attr.class <|
            "lia-btn lia-icon"
                ++ (if active then
                        " lia-selected"

                    else
                        ""
                   )
        , Attr.title alt
        , Attr.style "width" "56px"
        , Attr.style "padding" "0px"
        ]
        [ Html.text name ]


reset : Html Msg
reset =
    Html.button [ onClick Reset ] [ Html.text "reset course" ]


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


span_block : List (Html msg) -> Html msg
span_block =
    Html.span [ Attr.style "display" "block" ]


bold : String -> Html msg
bold =
    Html.text >> List.singleton >> Html.b []


view_information : Lang -> Bool -> Definition -> Html Msg
view_information lang visible definition =
    Html.div (menu_style visible)
        [ if String.isEmpty definition.author then
            Html.text ""

          else
            span_block
                [ bold <| Trans.infoAuthor lang
                , Html.text definition.author
                ]
        , if String.isEmpty definition.email then
            Html.text ""

          else
            span_block
                [ bold <| Trans.infoEmail lang
                , Html.a
                    [ Attr.href definition.email, Attr.class "lia-link" ]
                    [ Html.text definition.email ]
                ]
        , if String.isEmpty definition.version then
            Html.text ""

          else
            span_block
                [ bold <| Trans.infoVersion lang
                , Html.text definition.version
                ]
        , if String.isEmpty definition.date then
            Html.text ""

          else
            span_block
                [ bold <| Trans.infoDate lang
                , Html.text definition.date
                ]
        , if List.isEmpty definition.attributes then
            Html.text ""

          else
            span_block
                [ bold "Attributes:"
                , Html.br [] []
                , view_attributes lang definition.attributes
                ]
        ]


view_attributes : Lang -> List Inlines -> Html Msg
view_attributes lang =
    List.map (thanks lang)
        >> Html.span []


thanks : Lang -> Inlines -> Html Msg
thanks lang to =
    Html.span []
        [ Html.hr [] []
        , to
            |> List.map (view_inf Array.empty lang)
            |> span_block
        ]
        |> Html.map (\_ -> Ignore)


view_translations : Lang -> Bool -> String -> List ( String, String ) -> Html Msg
view_translations lang visible base list =
    Html.div (menu_style visible) <|
        if List.isEmpty list then
            [ Html.text (Trans.no_translation lang) ]

        else
            list
                |> List.map
                    (\( lang_, url ) ->
                        Html.a
                            [ Attr.href (base ++ url), Attr.class "lia-link" ]
                            [ Html.text lang_, Html.br [] [] ]
                    )


check_list : Bool -> String -> String -> String -> Html Msg
check_list checked label text dir =
    Html.label
        [ Attr.class label, Attr.style "float" dir, Attr.style "overflow" "hidden", Attr.style "width" "42%" ]
        [ Html.input
            [ Attr.type_ "radio"
            , Attr.name "toggle"
            , Attr.checked checked
            , onClick (ChangeTheme label)
            ]
            []
        , Html.span
            []
            [ Html.text text ]
        ]


menu_style : Bool -> List (Html.Attribute msg)
menu_style visible =
    [ Attr.class <|
        "lia-slide-animation"
            ++ (if visible then
                    " lia-settings"

                else
                    ""
               )
    , Attr.style "max-height" <|
        if visible then
            "256px"

        else
            "0px"
    ]


qrCodeView : Bool -> String -> Html msg
qrCodeView visible url =
    Html.div
        (Attr.style "padding-top" "3px"
            :: Attr.style "background-color" "white"
            :: Attr.style "overflow" "hidden"
            :: menu_style visible
        )
        [ url
            |> QRCode.fromString
            |> Result.map (QRCode.toSvgWithoutQuietZone [])
            |> Result.withDefault (Html.text "Error while encoding to QRCode.")

        --Html.img
        --    [ Attr.src ("https://api.qrserver.com/v1/create-qr-code/?size=222x222&data=" ++ url)
        --    , Attr.style "height" "240px"
        --    , Attr.style "width" "100%"
        --    ]
        --    []
        ]


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


view_light : Bool -> Html Msg
view_light light =
    Html.span
        [ Attr.class "lia-btn"
        , onClick <| Toggle Light
        , Attr.style "text-align" "right"
        ]
        [ if light then
            Html.text "🌞"

          else
            Html.text "🌘"
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
    Html.span
        [ toggle ShowModes
        ]
        [ Html.text "Mode"
        ]


btnSettings : Lang -> Html Msg
btnSettings _ =
    Html.span
        [ toggle ShowSettings
        ]
        [ Html.text "Settings"
        ]


btnTranslations : Lang -> Html Msg
btnTranslations _ =
    Html.span
        [ toggle ShowTranslations
        ]
        [ Html.text "Settings"
        ]


btnShare : Lang -> Html Msg
btnShare _ =
    Html.span
        [ toggle Share
        ]
        [ Html.text "Settings"
        ]


toggle =
    Action >> Toggle >> onClick
