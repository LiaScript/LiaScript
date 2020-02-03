module Lia.Settings.View exposing (design, switch_button_mode, toggle_button_toc, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy as Lazy
import Lia.Definition.Types exposing (Definition, get_translations)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Settings.Model exposing (Mode(..), Model)
import Lia.Settings.Update exposing (Button(..), Msg(..), Toggle(..))
import Translations as Trans exposing (Lang)


view : Model -> Definition -> String -> String -> Lang -> Html Msg
view model defines url origin lang =
    Html.div []
        [ Lazy.lazy2 view_settings model lang
        , Lazy.lazy3 view_information lang model.buttons.informations defines
        , view_translations lang model.buttons.translations (origin ++ "?") (Lia.Definition.Types.get_translations defines)
        , Lazy.lazy2 qrCodeView model.buttons.share url
        , Html.div
            [ Attr.class "lia-settings", Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
            [ dropdown model.buttons.settings "settings" (Trans.confSettings lang) (Toggle <| Button Settings)
            , dropdown model.buttons.informations "info" (Trans.confInformations lang) (Toggle <| Button Informations)
            , dropdown model.buttons.translations "translate" (Trans.confTranslations lang) (Toggle <| Button Translations)
            , dropdown model.buttons.share "share" (Trans.confShare lang) (Toggle <| Button Share)
            ]
        ]


design : Model -> List (Html.Attribute msg)
design model =
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
    , Attr.style "font-size" <| String.fromInt model.font_size ++ "%"
    ]


dropdown : Bool -> String -> String -> Msg -> Html Msg
dropdown active name alt msg =
    Html.button
        [ onClick msg
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


view_settings : Model -> Lang -> Html Msg
view_settings model lang =
    Html.div (menu_style model.buttons.settings)
        [ Html.p []
            [ Html.text <| Trans.cColor lang
            , view_light model.light
            , design_theme lang model.theme
            , view_ace lang model.editor
            , inc_font_size lang model.font_size
            , reset
            ]
        ]


reset : Html Msg
reset =
    Html.button [ onClick Reset ] [ Html.text "reset course" ]


navButton : String -> String -> msg -> Html msg
navButton str title msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class "lia-btn lia-slide-control lia-left"
        ]
        [ Html.text str ]


inc_font_size : Lang -> Int -> Html Msg
inc_font_size lang int =
    Html.div []
        [ Html.text <| Trans.baseFont lang ++ ":"
        , navButton "-" (Trans.baseDec lang) (ChangeFontSize False)
        , Html.text (String.fromInt int ++ "%")
        , navButton "+" (Trans.baseInc lang) (ChangeFontSize True)
        ]


design_theme : Lang -> String -> Html Msg
design_theme lang theme =
    [ ( "default", "left", Trans.cDefault lang )
    , ( "amber", "right", Trans.cAmber lang )
    , ( "blue", "left", Trans.cBlue lang )
    , ( "green", "right", Trans.cGreen lang )
    , ( "grey", "left", Trans.cGray lang )
    , ( "purple", "right", Trans.cPurple lang )
    ]
        |> List.map (\( c, b, text ) -> check_list (c == theme) c text b)
        |> Html.div [ Attr.class "lia-color" ]


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
                    [ Attr.href definition.email ]
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
                , view_attributes definition.attributes
                ]
        ]


view_attributes : List Inlines -> Html Msg
view_attributes thanks_to =
    thanks_to
        |> List.map thanks
        |> Html.span []


thanks : Inlines -> Html msg
thanks to =
    Html.span []
        [ Html.hr [] []
        , to
            |> List.map (view_inf Textbook)
            |> span_block
        ]


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
                            [ Attr.href (base ++ url) ]
                            [ Html.text lang_, Html.br [] [] ]
                    )


check_list : Bool -> String -> String -> String -> Html Msg
check_list checked label text dir =
    Html.label
        [ Attr.class label, Attr.style "float" dir ]
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
    Html.div (menu_style visible)
        [ Html.p []
            [ Html.img
                [ Attr.src ("https://api.qrserver.com/v1/create-qr-code/?size=222x222&data=" ++ url)
                , Attr.style "width" "99%"
                ]
                []
            ]
        ]


view_ace : Lang -> String -> Html Msg
view_ace lang theme =
    let
        op =
            option theme
    in
    Html.div [ Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
        [ Html.select [ onInput ChangeEditor ]
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
            Html.text "🌝"
        ]


option : String -> ( String, String ) -> Html Msg
option current ( val, text ) =
    Html.option
        [ Attr.value val
        , Attr.selected (val == current)
        ]
        [ Html.text text ]


toggle_button_toc : Lang -> Html Msg
toggle_button_toc lang =
    Html.button
        [ onClick <| Toggle TableOfContents
        , Attr.title (Trans.baseToc lang)
        , Attr.class "lia-btn lia-toc-control lia-left"
        ]
        [ Html.text "toc" ]


switch_button_mode : Lang -> Mode -> Html Msg
switch_button_mode lang mode =
    Html.button
        [ Attr.class "lia-btn lia-right"
        , onClick SwitchMode
        , Attr.title <|
            case mode of
                Slides ->
                    Trans.modeSlides lang

                Presentation ->
                    Trans.modePresentation lang

                Textbook ->
                    Trans.modeTextbook lang
        ]
        [ Html.text <|
            case mode of
                Slides ->
                    "visibility"

                Presentation ->
                    "hearing"

                Textbook ->
                    "book"
        ]
