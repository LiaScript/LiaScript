module Lia.View exposing (view)

--import Html.Lazy exposing (lazy2)

import Array exposing (Array)
import Char
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Definition.Types exposing (Definition, get_translations)
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
import Lia.Update exposing (Msg(..), Toggle(..), get_active_section)


view : Model -> Html Msg
view model =
    Html.div
        (design model.design)
        [ view_aside model
        , view_article model
        ]


design : Design -> List (Html.Attribute msg)
design s =
    [ Attr.class
        ("lia-canvas lia-theme-"
            ++ s.theme
            ++ " lia-variant-"
            ++ s.light
        )
    , Attr.style [ ( "font-size", toString s.font_size ++ "%" ) ]
    ]


view_aside : Model -> Html Msg
view_aside model =
    Html.aside
        [ Attr.class "lia-toc"
        , Attr.style
            [ ( "max-width"
              , if model.show.loc then
                    "250px"
                else
                    "0px"
              )
            ]
        ]
        [ model.index_model
            |> Lia.Index.View.view
            |> Html.map UpdateIndex
        , model.sections
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
                    if [] == model.index_model.index then
                        titles
                    else
                        List.filter (\( idx, _ ) -> List.member idx model.index_model.index) titles
               )
            |> view_loc model.section_active
        , settings model.show
            model.design
            (model
                |> get_active_section
                |> Maybe.andThen .definition
                |> Maybe.withDefault model.definition
            )
            (model.origin ++ "?" ++ model.readme)
            model.origin
        ]


settings show design defines url origin =
    Html.div
        [ Attr.style
            [ ( "border-top", "4px solid black" )
            ]
        ]
        [ Html.div
            [ Attr.style
                [ ( "max-height"
                  , if show.settings then
                        "250px"
                    else
                        "0px"
                  )
                , ( "margin-left", "4px" )
                , ( "padding-left", "5px" )
                , ( "margin-right", "4px" )
                , ( "padding-right", "5px" )
                , ( "overflow-y", "auto" )
                , ( "transition", "max-height 0.5s ease-out" )
                ]
            ]
            [ Html.p []
                [ Html.text "Color"
                , view_design_light design.light
                , design_theme design
                , Html.hr [] []
                , inc_font_size design.font_size
                ]
            ]
        , view_information show.informations defines
        , view_translations show.translations (origin ++ "?") (Lia.Definition.Types.get_translations defines)
        , qrCodeView show.share url
        , Html.div
            [ Attr.style
                [ ( "overflow-x", "auto" )

                --, ( "border-top", "4px solid black" )
                ]
            ]
            [ dropdown "settings" (Toggle Settings)
            , dropdown "info" (Toggle Informations)
            , dropdown "translate" (Toggle Translations)
            , dropdown "share" (Toggle Share)
            ]
        ]


dropdown name msg =
    Html.button
        [ onClick msg
        , Attr.class "lia-btn lia-icon"
        , Attr.style [ ( "width", "40px" ), ( "padding", "0px" ) ]
        ]
        [ Html.text name ]


inc_font_size : Int -> Html Msg
inc_font_size int =
    Html.div []
        [ Html.text "Font:"
        , navButton "-" (IncreaseFontSize False)
        , Html.text (toString int ++ "%")
        , navButton "+" (IncreaseFontSize True)
        ]


design_theme : Design -> Html Msg
design_theme design =
    [ ( "default", "left" )
    , ( "amber", "right" )
    , ( "blue", "left" )
    , ( "green", "right" )
    , ( "grey", "left" )
    , ( "purple", "right" )
    ]
        |> List.map (\( c, b ) -> check_list (c == design.theme) c b)
        |> Html.div [ Attr.class "lia-color" ]


view_information : Bool -> Definition -> Html Msg
view_information visible definition =
    Html.div
        [ Attr.style
            [ ( "max-height"
              , if visible then
                    "250px"
                else
                    "0px"
              )
            , ( "margin-left", "4px" )
            , ( "padding-left", "5px" )
            , ( "margin-right", "4px" )
            , ( "padding-right", "5px" )
            , ( "overflow-y", "auto" )
            , ( "transition", "max-height 0.5s ease-out" )
            ]
        ]
        [ Html.p [] [ Html.text ("Author: " ++ definition.author) ]
        , Html.p [] [ Html.text "Email: ", Html.a [ Attr.href definition.email ] [ Html.text definition.email ] ]
        , Html.p [] [ Html.text ("Version: " ++ definition.version) ]
        , Html.p [] [ Html.text ("Date: " ++ definition.date) ]
        ]


view_translations : Bool -> String -> List ( String, String ) -> Html Msg
view_translations visible base list =
    Html.div
        [ Attr.style
            [ ( "max-height"
              , if visible then
                    "250px"
                else
                    "0px"
              )
            , ( "margin-left", "4px" )
            , ( "padding-left", "5px" )
            , ( "margin-right", "4px" )
            , ( "padding-right", "5px" )
            , ( "overflow-y", "auto" )
            , ( "transition", "max-height 0.5s ease-out" )
            ]
        ]
    <|
        if List.isEmpty list then
            [ Html.text "no translations yet" ]
        else
            list
                |> List.map
                    (\( lang, url ) ->
                        Html.a
                            [ Attr.href (base ++ url) ]
                            [ Html.text lang ]
                    )


check_list : Bool -> String -> String -> Html Msg
check_list checked label dir =
    Html.label
        [ Attr.class label, Attr.style [ ( "float", dir ) ] ]
        [ Html.input [ Attr.type_ "radio", Attr.name "toggle", Attr.checked checked, onClick (DesignTheme label) ] []
        , Html.span
            []
            [ Html.text (capitalize label) ]
        ]


qrCodeView : Bool -> String -> Html msg
qrCodeView visible url =
    Html.div
        [ Attr.style
            [ ( "max-height"
              , if visible then
                    "250px"
                else
                    "0px"
              )
            , ( "margin-left", "4px" )
            , ( "padding-left", "5px" )
            , ( "margin-right", "4px" )
            , ( "padding-right", "5px" )
            , ( "overflow-y", "auto" )
            , ( "transition", "max-height 0.5s ease-out" )
            ]
        ]
        [ Html.p []
            [ Html.img
                [ Attr.src ("https://api.qrserver.com/v1/create-qr-code/?size=222x222&data=" ++ url)
                , Attr.style [ ( "width", "99%" ) ]
                ]
                []
            ]
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
                    |> view_nav model.section_active model.mode model.design model.url (get_translations model.definition)
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
                |> (\l -> List.append l [ responsive sound (Toggle Sound) ])
                |> Html.footer [ Attr.class "lia-footer" ]

        Presentation ->
            Html.footer [ Attr.class "lia-footer" ] [ responsive sound (Toggle Sound) ]

        Textbook ->
            Html.text ""


navButton : String -> msg -> Html msg
navButton str msg =
    Html.button [ onClick msg, Attr.class "lia-btn lia-slide-control lia-left" ]
        [ Html.text str ]


view_nav : ID -> Mode -> Design -> String -> List ( String, String ) -> String -> Html Msg
view_nav section_active mode design base translations state =
    Html.nav [ Attr.class "lia-toolbar" ]
        [ Html.button
            [ onClick (Toggle LOC)
            , Attr.class "lia-btn lia-toc-control lia-left"
            ]
            [ Html.text "toc" ]
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
        , Html.button
            [ Attr.class "lia-btn lia-right"
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
        ]


capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, ss ) ->
            String.cons (Char.toUpper c) ss

        Nothing ->
            s


view_design_light : String -> Html Msg
view_design_light light =
    Html.button [ Attr.class "lia-btn lia-right", onClick DesignLight ]
        [ if light == "light" then
            Html.text "star"
          else
            Html.text "star_border"
        ]
