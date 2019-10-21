module Lia.Markdown.View exposing (view)

import Color
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy2)
import Lia.Markdown.Chart.View as Charts
import Lia.Markdown.Code.View as Codes
import Lia.Markdown.Effect.Model as Comments
import Lia.Markdown.Effect.View as Effects
import Lia.Markdown.Footnote.Model as Footnotes
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, attributes, viewer)
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode(..))
import Lia.Types exposing (Section)
import Svg.Attributes
import SvgBob
import Translations exposing (Lang)


type alias Config =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , lang : Lang
    , light : Bool
    }


view : Lang -> Mode -> Section -> String -> Bool -> Html Msg
view lang mode section ace_theme light =
    let
        config =
            Config mode
                (viewer <|
                    if mode == Textbook then
                        9999

                    else
                        section.effect_model.visible
                )
                section
                ace_theme
                lang
                light
    in
    case section.error of
        Just msg ->
            Html.section [ Attr.class "lia-content" ]
                [ view_header config
                , Html.text msg
                ]

        Nothing ->
            lazy2 view_body ( config, section.footnote2show, section.footnotes ) section.body


view_body : ( Config, Maybe String, Footnotes.Model ) -> List Markdown -> Html Msg
view_body ( config, footnote2show, footnotes ) body =
    body
        |> List.map (view_block config)
        |> (::) (view_footnote (view_block config) footnote2show footnotes)
        |> (::) (view_header config)
        |> (\s ->
                if config.mode == Textbook then
                    List.append s [ Footnote.block (view_block config) footnotes ]

                else
                    s
           )
        |> Html.section [ Attr.class "lia-content" ]


view_footnote : (Markdown -> Html Msg) -> Maybe String -> Footnotes.Model -> Html Msg
view_footnote viewer key footnotes =
    case Maybe.andThen (Footnotes.getNote footnotes) key of
        Just notes ->
            Html.div
                [ onClick FootnoteHide
                , Attr.style "position" "fixed"
                , Attr.style "display" "block"
                , Attr.style "width" "100%"
                , Attr.style "height" "100%"
                , Attr.style "top" "0"
                , Attr.style "left" "0"
                , Attr.style "right" "0"
                , Attr.style "bottom" "0"
                , Attr.style "background-color" "rgba(0,0,0,0.6)"
                , Attr.style "z-index" "2"
                , Attr.style "cursor" "pointer"
                , Attr.style "overflow" "auto"
                ]
                [ Html.div
                    [ Attr.style "position" "absolute"
                    , Attr.style "top" "50%"
                    , Attr.style "left" "50%"
                    , Attr.style "font-size" "20px"
                    , Attr.style "color" "white"
                    , Attr.style "transform" "translate(-50%,-50%)"
                    , Attr.style "-ms-transform" "translate(-50%,-50%)"
                    ]
                    (List.map viewer notes)
                ]

        Nothing ->
            Html.text ""


view_header : Config -> Html Msg
view_header config =
    config.view config.section.title
        |> (case config.section.indentation of
                1 ->
                    Html.h1 [ Attr.class "lia-inline lia-h1" ]

                2 ->
                    Html.h2 [ Attr.class "lia-inline lia-h2" ]

                3 ->
                    Html.h3 [ Attr.class "lia-inline lia-h3" ]

                4 ->
                    Html.h4 [ Attr.class "lia-inline lia-h4" ]

                5 ->
                    Html.h5 [ Attr.class "lia-inline lia-h5" ]

                _ ->
                    Html.h6 [ Attr.class "lia-inline lia-h6" ]
           )
        |> List.singleton
        |> Html.header []


view_block : Config -> Markdown -> Html Msg
view_block config block =
    case block of
        HLine attr ->
            Html.hr (annotation "lia-horiz-line" attr) []

        Paragraph attr elements ->
            Html.p (annotation "lia-paragraph" attr) (config.view elements)

        Effect attr ( id_in, id_out, sub_blocks ) ->
            if config.mode == Textbook || ((id_in <= config.section.effect_model.visible) && (id_out > config.section.effect_model.visible)) then
                Html.div
                    ((if id_in == config.section.effect_model.visible then
                        Attr.id "focused"

                      else
                        Attr.id (String.fromInt id_in)
                     )
                        :: annotation "lia-effect-inline" attr
                    )
                    (Effects.view_block (view_block config) id_in sub_blocks)

            else
                Html.text ""

        BulletList attr list ->
            list
                |> view_bulletlist config
                |> Html.ul (annotation "lia-list lia-unordered" attr)

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol (annotation "lia-list lia-ordered" attr)

        Table attr header format body ->
            view_table config attr header format body

        Quote attr elements ->
            elements
                |> List.map (\e -> view_block config e)
                |> Html.blockquote (annotation "lia-quote" attr)

        Code attr code ->
            code
                |> Codes.view config.lang config.ace_theme attr config.section.code_vector
                |> Html.map UpdateCode

        Quiz attr quiz Nothing ->
            Html.div (annotation "lia-quiz lia-card" attr)
                [ Quizzes.view config.lang quiz config.section.quiz_vector
                    |> Html.map UpdateQuiz
                ]

        Quiz attr quiz (Just ( answer, hidden_effects )) ->
            Html.div (annotation "lia-quiz lia-card" attr) <|
                case Quizzes.view_solution config.section.quiz_vector quiz of
                    ( empty, True ) ->
                        List.append
                            [ Html.map UpdateQuiz <| Quizzes.view config.lang quiz config.section.quiz_vector ]
                            ((if empty then
                                Html.text ""

                              else
                                Html.hr [] []
                             )
                                :: List.map (view_block config) answer
                            )

                    _ ->
                        [ Quizzes.view config.lang quiz config.section.quiz_vector
                            |> Html.map UpdateQuiz
                        ]

        Survey attr survey ->
            config.section.survey_vector
                |> Surveys.view config.lang attr survey
                |> Html.map UpdateSurvey

        Comment ( id1, id2 ) ->
            case
                ( config.mode
                , id1 == config.section.effect_model.visible
                , Comments.get_paragraph id1 id2 config.section.effect_model
                )
            of
                ( Textbook, _, Just ( attr, par ) ) ->
                    par
                        |> Paragraph attr
                        |> view_block config

                _ ->
                    Html.text ""

        Chart attr chart ->
            Charts.view (not config.light) attr chart

        ASCII attr txt ->
            txt
                |> SvgBob.init SvgBob.default
                |> SvgBob.getSvg (attributes attr)
                |> (\svg ->
                        if config.light then
                            svg

                        else
                            Html.div
                                [ Attr.style "-webkit-filter" "invert(100%)"
                                , Attr.style "filter" "invert(100%)"
                                ]
                                [ svg ]
                   )


view_table : Config -> Annotation -> MultInlines -> List String -> List MultInlines -> Html Msg
view_table config attr header format body =
    let
        view_row fct row =
            row
                |> (if header == [] then
                        List.map
                            (\r -> r |> config.view |> fct [ Attr.align "left" ])

                    else
                        List.map2
                            (\f r -> r |> config.view |> fct [ Attr.align f ])
                            format
                   )
    in
    body
        |> List.map
            (\row ->
                row
                    |> view_row Html.td
                    |> Html.tr [ Attr.class "lia-inline lia-table-row" ]
            )
        |> (::)
            (header
                |> view_row Html.th
                |> Html.thead [ Attr.class "lia-inline lia-table-head" ]
            )
        |> Html.table (annotation "lia-table" attr)


view_list : Config -> List ( String, List Markdown ) -> List (Html Msg)
view_list config list =
    let
        viewer ( value, sub_list ) =
            List.map (view_block config) sub_list
                |> Html.li [ Attr.value value ]
    in
    list
        |> List.map viewer


view_bulletlist : Config -> List (List Markdown) -> List (Html Msg)
view_bulletlist config list =
    let
        viewer =
            List.map (view_block config)
                >> Html.li []
    in
    list
        |> List.map viewer
