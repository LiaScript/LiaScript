module Lia.View exposing (view)

import Flip exposing (flip)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, preventDefaultOn)
import Json.Decode as JD
import Lia.Index.View as Index
import Lia.Markdown.Config as Config
import Lia.Markdown.Effect.Model exposing (current_paragraphs)
import Lia.Markdown.Effect.View exposing (responsive, state)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Section exposing (SubSection)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Settings.Update exposing (toggle_sound)
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
view : Screen -> Bool -> Bool -> Model -> Html Msg
view screen hasShareAPI hasIndex model =
    Html.div
        (onNavigationKey :: Settings.design model.settings)
        [ view_aside hasShareAPI model
        , view_article screen hasIndex model
        ]


{-| **@private:** release a navigation event, if the arrow key left or right had
been pressed.
-}
onNavigationKey : Html.Attribute Msg
onNavigationKey =
    JD.field "key" JD.string
        |> JD.andThen decodeNavigationKey
        |> preventDefaultOn "keydown"


decodeNavigationKey : String -> JD.Decoder ( Msg, Bool )
decodeNavigationKey s =
    case s of
        "ArrowLeft" ->
            JD.succeed ( PrevSection, True )

        "ArrowRight" ->
            JD.succeed ( NextSection, True )

        _ ->
            JD.fail "no arrow key"


{-| **@private:** Display the aside section that contains the document search,
table of contents and settings.
-}
view_aside : Bool -> Model -> Html Msg
view_aside hasShareAPI model =
    Html.aside
        [ Attr.class "lia-toc"
        , Attr.style "max-width" <|
            if model.settings.table_of_contents then
                "280px"

            else
                "0px"
        ]
        [ Html.map UpdateIndex <| Index.view_search model.translation model.index_model
        , model.sections
            |> Index.view model.translation model.section_active
            |> Html.map Script
        , model
            |> get_active_section
            |> Maybe.andThen .definition
            |> Maybe.withDefault model.definition
            |> Settings.view model.settings
                model.url
                model.origin
                model.translation
                (if hasShareAPI then
                    Just <| share model.title (stringify model.definition.comment) model.url

                 else
                    Nothing
                )
            |> Html.map UpdateSettings
        ]


{-| **@private:** show the current section, with navigation on top as well as a
footer, if it is required by the current display mode.
-}
view_article : Screen -> Bool -> Model -> Html Msg
view_article screen hasIndex model =
    case get_active_section model of
        Just section ->
            Html.article [ Attr.class "lia-slide" ]
                [ section
                    |> .effect_model
                    |> state
                    |> view_nav
                        model.section_active
                        hasIndex
                        model.settings.mode
                        model.translation
                        model.settings.speaking
                , Config.init
                    model.settings.mode
                    section
                    model.section_active
                    model.settings.editor
                    model.translation
                    model.settings.light
                    (if model.settings.table_of_contents then
                        { screen | width = screen.width - 260 }

                     else
                        screen
                    )
                    |> Markdown.view
                    |> Html.map UpdateMarkdown
                , view_footer
                    model.translation
                    model.settings.sound
                    model.settings.mode
                    model.section_active
                    section.effect_model
                ]

        Nothing ->
            Html.text "no content"


{-| **@private:** used to diplay the text2speech output settings and spoken
comments in text, depending on the currently applied rendering mode.
-}
view_footer : Lang -> Bool -> Mode -> Int -> Lia.Markdown.Effect.Model.Model SubSection -> Html Msg
view_footer lang sound mode slide effects =
    case mode of
        Slides ->
            effects
                |> current_paragraphs
                |> List.map
                    (Tuple.second
                        >> List.map (view_inf effects.javascript lang)
                        >> Html.p []
                        >> Html.map (Tuple.pair slide >> Script)
                    )
                |> flip List.append [ responsive lang sound (UpdateSettings toggle_sound) ]
                |> Html.footer [ Attr.class "lia-footer" ]

        Presentation ->
            Html.footer [ Attr.class "lia-footer" ] [ responsive lang sound (UpdateSettings toggle_sound) ]

        Textbook ->
            Html.text ""


{-| **@private:** create a navigation button with:

1.  `str`: string to be displayed in the body
2.  `title`: attribute
3.  `id`: so that it can be identfied by external css
4.  `msg`: to release if pressed

-}
navButton : String -> String -> String -> msg -> Html msg
navButton str title id msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class "lia-btn lia-control lia-slide-control lia-left"
        , Attr.id id
        ]
        [ Html.text str ]


{-| **@private:** the navigation abr:

1.  `section_active`: section id to display
2.  `hasIndex`: display home/index button
3.  `mode`: to define the rendering type
4.  `lang`: used for translations
5.  `speaking`: underlines the section number, to indicate if the text2speech
    output is currently active
6.  `state`: fragments, if animations are active, not visible in textbook mode

-}
view_nav : Int -> Bool -> Mode -> Lang -> Bool -> String -> Html Msg
view_nav section_active hasIndex mode lang speaking state =
    Html.nav [ Attr.class "lia-toolbar", Attr.id "lia-toolbar-nav" ]
        [ Html.map UpdateSettings <| Settings.toggle_button_toc lang
        , if hasIndex then
            navButton "home" "index" "lia-btn-home" Home

          else
            Html.text ""
        , Html.span [ Attr.class "lia-spacer", Attr.id "lia-spacer-left" ] []
        , navButton "navigate_before" (Trans.basePrev lang) "lia-btn-prev" PrevSection
        , Html.span [ Attr.class "lia-labeled lia-left", Attr.id "lia-label-section" ]
            [ Html.span
                [ Attr.class "lia-label"
                , if speaking then
                    Attr.style "text-decoration" "underline"

                  else
                    Attr.style "" ""
                ]
                [ Html.text (String.fromInt (section_active + 1))
                , Html.text <|
                    case mode of
                        Textbook ->
                            ""

                        _ ->
                            state
                ]
            ]
        , navButton "navigate_next" (Trans.baseNext lang) "lia-btn-next" NextSection
        , Html.span [ Attr.class "lia-spacer", Attr.id "lia-spacer-right" ] []
        , Html.map UpdateSettings <| Settings.switch_button_mode lang mode
        ]
