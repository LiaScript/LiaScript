module Lia.View exposing (view)

--import Html.Lazy exposing (lazy2)
--import Lia.Index.Model as Index

import Array exposing (Array)
import Char
import Flip exposing (flip)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy as Lazy
import Lia.Definition.Types exposing (Definition, get_translations)
import Lia.Effect.Model exposing (current_paragraphs)
import Lia.Effect.View exposing (responsive, state)
import Lia.Index.View as Index
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Settings.Update exposing (toggle_sound, toggle_table_of_contents)
import Lia.Settings.View as Settings
import Lia.Types exposing (..)
import Lia.Update exposing (Msg(..), get_active_section)
import Translations exposing (..)


view : Model -> Html Msg
view model =
    Html.div
        (Settings.design model.settings)
        [ view_aside model
        , view_article model
        ]


view_aside : Model -> Html Msg
view_aside model =
    Html.aside
        [ Attr.class "lia-toc"
        , Attr.style "max-width" <|
            if model.settings.table_of_contents then
                "256px"

            else
                "0px"
        ]
        [ Html.map UpdateIndex <| Index.view_search model.translation model.index_model
        , Index.view model.section_active model.sections
        , Html.map UpdateSettings <|
            Settings.view model.settings
                (model
                    |> get_active_section
                    |> Maybe.andThen .definition
                    |> Maybe.withDefault model.definition
                )
                (model.origin ++ "?" ++ model.readme)
                model.origin
                model.translation
        ]



{-
   index_list index sections =
       let
           titles =
               sections
                   |> Array.map to_secList
                   |> Array.toIndexedList

           fn ( idx, _ ) =
               List.member idx index
       in
       --    case index of
       --        [] ->
       titles
-}
--        _ ->
--            List.filter fn titles
{-
   settings : Settings.Model -> Definition -> String -> String -> Lang -> Html Msg
   settings settings_ defines url origin lang =
       Html.div []
           [ Lazy.lazy3 view_settings lang settings_.buttons.settings design_
           , Lazy.lazy3 view_information lang show.informations defines
           , view_translations lang show.translations (origin ++ "?") (Lia.Definition.Types.get_translations defines)
           , Lazy.lazy2 qrCodeView show.share url
           , Html.div
               [ Attr.class "lia-settings", Attr.style "display" "inline-flex", Attr.style "width" "99%" ]
               [ dropdown show.settings "settings" (confSettings lang) (Toggle Settings)
               , dropdown show.informations "info" (confInformations lang) (Toggle Informations)
               , dropdown show.translations "translate" (confTranslations lang) (Toggle Translations)
               , dropdown show.share "share" (confShare lang) (Toggle Share)
               ]
           ]
-}


view_article : Model -> Html Msg
view_article model =
    Html.article [ Attr.class "lia-slide" ] <|
        case get_active_section model of
            Just section ->
                [ section
                    |> .effect_model
                    |> state
                    |> view_nav model.section_active model.settings.mode model.translation model.url (get_translations model.definition)
                , Html.map UpdateMarkdown <| Markdown.view model.translation model.settings.mode section model.settings.editor
                , view_footer model.translation model.settings.sound model.settings.mode section.effect_model
                ]

            Nothing ->
                [ Html.text "" ]


view_footer : Lang -> Bool -> Mode -> Lia.Effect.Model.Model -> Html Msg
view_footer lang sound mode effects =
    case mode of
        Slides ->
            effects
                |> current_paragraphs
                |> List.map (\( _, par ) -> Html.p [] (viewer 9999 par))
                |> flip List.append [ responsive lang sound (UpdateSettings toggle_sound) ]
                |> Html.footer [ Attr.class "lia-footer" ]

        Presentation ->
            Html.footer [ Attr.class "lia-footer" ] [ responsive lang sound (UpdateSettings toggle_sound) ]

        Textbook ->
            Html.text ""


navButton : String -> String -> msg -> Html msg
navButton str title msg =
    Html.button
        [ onClick msg
        , Attr.title title
        , Attr.class "lia-btn lia-slide-control lia-left"
        ]
        [ Html.text str ]


view_nav : Int -> Mode -> Lang -> String -> List ( String, String ) -> ( Bool, String ) -> Html Msg
view_nav section_active mode lang base translations ( speaking, state ) =
    Html.nav [ Attr.class "lia-toolbar" ]
        [ Html.map UpdateSettings <| Settings.toggle_button_toc lang
        , Html.span [ Attr.class "lia-spacer" ] []
        , navButton "navigate_before" (basePrev lang) PrevSection
        , Html.span [ Attr.class "lia-labeled lia-left" ]
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
                            " " ++ state
                ]
            ]
        , navButton "navigate_next" (baseNext lang) NextSection
        , Html.span [ Attr.class "lia-spacer" ] []
        , Html.map UpdateSettings <| Settings.switch_button_mode lang mode
        ]



{- "Bright">


   <optgroup label="Dark">

-}
