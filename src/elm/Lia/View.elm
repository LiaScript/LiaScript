module Lia.View exposing (view)

import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Const
import Flip exposing (flip)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Index.View as Index
import Lia.Markdown.Config as Config
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.Effect.View exposing (responsive, state)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Section exposing (Section, SubSection)
import Lia.Settings.Types exposing (Mode(..), Settings)
import Lia.Settings.Update exposing (Toggle(..), toggle_sound)
import Lia.Settings.View as Settings
import Lia.Update exposing (Msg(..), get_active_section)
import Port.Share exposing (share)
import Session exposing (Screen)
import Translations as Trans exposing (Lang)


{-| Main view for the entire LiaScript model with the parameters:

1.  `screen`: width and heigth of the window
2.  `hasShareAPI`: will enable sharing vie the `navigation.share` api, otherwise
    create an QR-code with the entire course-URL
3.  `hasIndex`: display a home-button or not
4.  `model`: the preprocessed LiaScript Model

-}
view : Screen -> Bool -> Model -> Html Msg
view screen hasIndex model =
    Html.div
        (Settings.design model.settings)
        (viewIndex hasIndex model :: viewSlide screen model)


{-| **@private:** Display the side section that contains the document search,
table of contents and the home button.
-}
viewIndex : Bool -> Model -> Html Msg
viewIndex hasIndex model =
    Html.div
        [ Attr.class "lia-toc"
        , Attr.id "lia-toc"
        , Attr.class <|
            if model.settings.table_of_contents then
                "lia-toc--open"

            else
                "lia-toc--closed"
        ]
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
            |> Html.nav
                [ Attr.class "lia-toc__content"
                , A11y_Landmark.navigation
                ]

        --|> Html.map Script
        , if hasIndex then
            Html.div [ Attr.class "lia-toc__bottom" ]
                [ Index.bottom model.settings.table_of_contents Home ]

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
viewSlide : Screen -> Model -> List (Html Msg)
viewSlide screen model =
    case get_active_section model of
        Just section ->
            [ Html.div [ Attr.class "lia-slide" ]
                [ slideTopBar model.translation screen model.url model.settings model.definition
                , Config.init
                    model.translation
                    ( model.langCodeOriginal, model.langCode )
                    model.settings
                    screen
                    section
                    model.section_active
                    |> Markdown.view
                    |> Html.map UpdateMarkdown
                , slideBottom
                    model.translation
                    model.settings
                    model.section_active
                    section.effect_model
                ]
            , slideA11y
                model.translation
                model.settings.mode
                section.effect_model
                model.section_active
            ]

        Nothing ->
            [ Html.div [ Attr.class "lia-slide" ]
                [ slideTopBar
                    model.translation
                    screen
                    model.url
                    model.settings
                    model.definition
                , Html.text "Ups, something went wrong"
                ]
            ]


{-| **@private:** used to diplay the text2speech output settings and spoken
comments in text, depending on the currently applied rendering mode.
-}
slideBottom : Lang -> Settings -> Int -> Effect.Model SubSection -> Html Msg
slideBottom lang settings slide effects =
    Html.footer
        [ Attr.class "lia-slide__footer" ]
        [ slideNavigation lang settings.mode slide effects
        , case settings.mode of
            Textbook ->
                Html.text ""

            _ ->
                Html.div [ Attr.class "lia-responsive-voice" ]
                    [ Html.button
                        [ Attr.class "lia-btn lia-responsive-voice__play"
                        , onClick <| TTSReplay (not settings.speaking)
                        , Attr.disabled (not settings.sound)
                        ]
                        [ if settings.speaking then
                            Html.text "stop"

                          else
                            Html.i [ Attr.class "icon icon-play-circle" ] []
                        ]
                    , responsive lang settings.sound (UpdateSettings toggle_sound)
                    ]
        ]


slideA11y : Lang -> Mode -> Effect.Model SubSection -> Int -> Html Msg
slideA11y lang mode effect id =
    case mode of
        Slides ->
            let
                comments =
                    effect
                        |> Effect.current_paragraphs
                        |> List.map
                            (\( active, counter, par ) ->
                                par
                                    |> List.map
                                        (Tuple.second
                                            >> List.map (view_inf effect.javascript lang)
                                            >> Html.p []
                                        )
                                    |> (::)
                                        (Html.small [ Attr.class "lia-notes__counter" ]
                                            [ String.fromInt counter
                                                ++ "/"
                                                ++ String.fromInt effect.effects
                                                |> Html.text
                                            ]
                                        )
                                    |> Html.div
                                        [ Attr.class
                                            ("lia-notes__content"
                                                ++ (if active then
                                                        " active"

                                                    else
                                                        ""
                                                   )
                                            )
                                        , Attr.id
                                            (if active then
                                                "lia-notes-active"

                                             else
                                                ""
                                            )
                                        ]
                            )
            in
            comments
                |> Html.aside
                    [ Attr.class "lia-notes" ]
                |> Html.map (Tuple.pair id >> Script)

        _ ->
            Html.text ""


{-| **@private:** create a navigation button with:

1.  `str`: string to be displayed in the body
2.  `title`: attribute
3.  `id`: so that it can be identfied by external css
4.  `msg`: to release if pressed

-}
navButton : String -> String -> String -> String -> msg -> Html msg
navButton str title id class msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class <| "lia-btn lia-btn--icon lia-btn--transparent icon " ++ class
        , Attr.id id
        ]
        []


{-| **@private:** the navigation abr:

1.  `section_active`: section id to display
2.  `hasIndex`: display home/index button
3.  `mode`: to define the rendering type
4.  `lang`: used for translations
5.  `speaking`: underlines the section number, to indicate if the text2speech
    output is currently active
6.  `state`: fragments, if animations are active, not visible in textbook mode

-}
slideTopBar : Lang -> Screen -> String -> Settings -> Definition -> Html Msg
slideTopBar lang screen url settings def =
    let
        tabbable =
            screen.width >= Const.globalBreakpoints.md || settings.support_menu
    in
    [ Html.div [ Attr.class "lia-header__left" ] []
    , Html.div [ Attr.class "lia-header__middle" ]
        [ Html.img
            [ def
                |> Definition.getIcon
                |> Attr.src
            , Attr.class "lia_header__logo"
            , Attr.alt "LiaScript"
            ]
            []
        ]
    , Html.div [ Attr.class "lia-header__right" ]
        [ Html.div
            [ Attr.class "lia-support-menu"
            , Attr.class <|
                if settings.support_menu then
                    "lia-support-menu--open"

                else
                    "lia-support-menu--closed"
            ]
            [ Settings.btnSupport settings.support_menu
            , Html.div
                [ Attr.class "lia-support-menu__collapse"
                ]
                [ [ ( Settings.menuMode, "mode" )
                  , ( Settings.menuSettings, "settings" )
                  , ( Settings.menuTranslations def, "lang" )
                  , ( Settings.menuShare url, "share" )
                  , ( Settings.menuInformation def, "info" )
                  ]
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
            , A11y_Landmark.navigation
            ]
        |> Html.map UpdateSettings


slideNavigation : Lang -> Mode -> Int -> Effect.Model SubSection -> Html Msg
slideNavigation lang mode slide effect =
    Html.div [ Attr.class "lia-pagination" ]
        [ Html.div [ Attr.class "lia-pagination__content" ]
            [ navButton "navigate_before" (Trans.basePrev lang) "lia-btn-prev" "icon-arrow-left" PrevSection
            , Html.span
                [ Attr.class "lia-pagination__current" ]
                [ Html.text (String.fromInt (slide + 1))
                , Html.text <|
                    case mode of
                        Textbook ->
                            ""

                        _ ->
                            state effect
                ]
            , navButton "navigate_next" (Trans.baseNext lang) "lia-btn-next" "icon-arrow-right" NextSection
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
