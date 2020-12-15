module Lia.View exposing (view)

import Flip exposing (flip)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, preventDefaultOn)
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
import Lia.Update exposing (Msg(..), get_active_section, key_decoder)
import Port.Share exposing (share)
import Session exposing (Screen)
import Translations as Trans exposing (Lang)


view : Screen -> Bool -> Bool -> Model -> Html Msg
view screen hasShareAPI hasIndex model =
    Html.div
        (preventDefaultOn "keydown" key_decoder :: Settings.design model.settings)
        [ view_aside hasShareAPI model
        , view_article screen hasIndex model
        ]


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
                        model.url
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

        Newspaper ->
            Html.text ""


navButton : String -> String -> String -> msg -> Html msg
navButton str title id msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class "lia-btn lia-control lia-slide-control lia-left"

        --, Attr.style "padding-left" padding
        --, Attr.style "margin-left" margin
        --, Attr.style "padding" "0px 8px"
        , Attr.id id
        ]
        [ Html.text str ]


view_nav : Int -> Bool -> Mode -> Lang -> String -> Bool -> String -> Html Msg
view_nav section_active hasIndex mode lang base speaking state =
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

                        Newspaper ->
                            ""

                        _ ->
                            state
                ]
            ]
        , navButton "navigate_next" (Trans.baseNext lang) "lia-btn-next" NextSection
        , Html.span [ Attr.class "lia-spacer", Attr.id "lia-spacer-right" ] []
        , Html.map UpdateSettings <| Settings.switch_button_mode lang mode
        ]
