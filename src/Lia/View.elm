module Lia.View exposing (view)

--import Html.Lazy exposing (lazy2)

import Array exposing (Array)
import Char
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Effect.Model exposing (current_paragraphs)
import Lia.Effect.View exposing (responsive, state)
import Lia.Helper exposing (ID)
import Lia.Index.Model
import Lia.Index.View
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.View as Markdown
import Lia.Model exposing (Model)
import Lia.Types exposing (..)
import Lia.Update exposing (Msg(..), get_active_section)


view : Model -> Html Msg
view model =
    Html.div [ design model.design ]
        [ if model.loc then
            view_aside model.index_model model.section_active model.sections
          else
            Html.text ""
        , view_article model
        ]


design : { theme : String, light : String } -> Html.Attribute msg
design s =
    Attr.class
        ("lia-canvas lia-theme-"
            ++ s.theme
            ++ " lia-variant-"
            ++ s.light
        )


view_aside : Lia.Index.Model.Model -> ID -> Sections -> Html Msg
view_aside index active sections =
    Html.aside
        [ Attr.class "lia-toc" ]
        [ index
            |> Lia.Index.View.view
            |> Html.map UpdateIndex
        , sections
            |> Array.map
                (\sec ->
                    ( sec.title
                    , sec.indentation
                    , sec.visited
                    , case sec.error of
                        Nothing ->
                            False

                        _ ->
                            True
                    )
                )
            |> Array.toIndexedList
            |> (\titles ->
                    if [] == index.index then
                        titles
                    else
                        List.filter (\( idx, _ ) -> List.member idx index.index) titles
               )
            |> view_loc active
        ]


view_loc : ID -> List ( ID, ( Inlines, Int, Bool, Bool ) ) -> Html Msg
view_loc active titles =
    let
        loc ( idx, ( title, indent, visited, error ) ) =
            Html.a
                [ onClick (Load idx)
                , Attr.class
                    ("lia-toc-l"
                        ++ toString indent
                        ++ (if error then
                                " lia-error"
                            else if active == idx then
                                " lia-active"
                            else if visited then
                                ""
                            else
                                " lia-not-visited"
                           )
                    )
                , Attr.href ("#" ++ toString (idx + 1))
                ]
                (viewer 9999 title)
    in
    titles
        |> List.map loc
        |> Html.div [ Attr.class "lia-content" ]


view_article : Model -> Html Msg
view_article model =
    Html.article [ Attr.class "lia-slide" ] <|
        case get_active_section model of
            Just section ->
                [ section
                    |> .effect_model
                    |> state
                    |> view_nav model.section_active model.mode model.design
                , Html.map UpdateMarkdown <| Markdown.view model.mode section
                , view_footer model.sound model.mode section.effect_model
                ]

            Nothing ->
                [ Html.text "" ]


view_footer : Bool -> Mode -> Lia.Effect.Model.Model -> Html Msg
view_footer sound mode effects =
    case mode of
        Slides ->
            effects
                |> current_paragraphs
                |> List.map (\( a, par ) -> Html.p [] (viewer 9999 par))
                |> (\l -> List.append l [ responsive sound ToggleSound ])
                |> Html.footer []

        Presentation ->
            Html.footer [] [ responsive sound ToggleSound ]

        Textbook ->
            Html.text ""



--|> Html.footer


navButton : String -> msg -> Html msg
navButton str msg =
    Html.button [ Attr.href "#33", onClick msg, Attr.class "lia-btn lia-slide-control lia-left" ]
        [ Html.text str ]


view_nav : ID -> Mode -> Design -> String -> Html Msg
view_nav section_active mode design state =
    Html.nav [ Attr.class "lia-toolbar" ]
        [ Html.button
            [ onClick ToggleLOC
            , Attr.class "lia-btn lia-toc-control lia-left"
            ]
            [ Html.text "toc" ]
        , Html.button
            [ Attr.class "lia-btn lia-left"
            , onClick SwitchMode
            ]
            [ case mode of
                Slides ->
                    Html.text "visibility"

                Presentation ->
                    Html.text "hearing"

                Textbook ->
                    Html.text "book"
            ]
        , Html.span [ Attr.class "lia-spacer" ] []
        , navButton "navigate_before" PrevSection
        , Html.span [ Attr.class "lia-labeled lia-left" ]
            [ Html.span [ Attr.class "lia-label" ]
                [ Html.text (toString (section_active + 1))
                , Html.text <|
                    case mode of
                        Textbook ->
                            ""

                        _ ->
                            " " ++ state
                ]
            ]
        , navButton "navigate_next" NextSection
        , Html.span [ Attr.class "lia-spacer" ] []
        , view_design_light design.light
        , view_design_theme design.theme
        ]


capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, ss ) ->
            String.cons (Char.toUpper c) ss

        Nothing ->
            s


view_design_theme : String -> Html Msg
view_design_theme theme =
    [ "default", "amber", "blue", "green", "grey", "purple" ]
        |> List.map
            (\t ->
                Html.option
                    [ Attr.value t, Attr.selected (t == theme) ]
                    [ Html.text (capitalize t) ]
            )
        |> Html.select [ onInput DesignTheme, Attr.class "lia-right lia-select" ]


view_design_light : String -> Html Msg
view_design_light light =
    Html.button [ Attr.class "lia-btn lia-right", onClick DesignLight ]
        [ if light == "light" then
            Html.text "star"
          else
            Html.text "star_border"
        ]
