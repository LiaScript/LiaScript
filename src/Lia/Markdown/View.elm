module Lia.Markdown.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Chart.View as Charts
import Lia.Code.View as Codes
import Lia.Effect.Model as Comments
import Lia.Effect.View as Effects
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Inline.View exposing (annotation, viewer)
import Lia.Markdown.Types exposing (..)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Quiz.View as Quizzes
import Lia.Survey.View as Surveys
import Lia.Types exposing (Mode(..), Section)


type alias Config =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    }


view : Mode -> Section -> Html Msg
view mode section =
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
    in
    case section.error of
        Just msg ->
            Html.section [ Attr.class "lia-content" ]
                [ view_header config
                , Html.text msg
                ]

        Nothing ->
            section.body
                |> List.map (view_block config)
                |> (::) (view_header config)
                |> Html.section [ Attr.class "lia-content" ]


view_header : Config -> Html Msg
view_header config =
    config.view config.section.title
        |> (case config.section.indentation of
                0 ->
                    Html.h1 [ Attr.class "lia-inline lia-h1" ]

                1 ->
                    Html.h2 [ Attr.class "lia-inline lia-h2" ]

                2 ->
                    Html.h3 [ Attr.class "lia-inline lia-h3" ]

                3 ->
                    Html.h4 [ Attr.class "lia-inline lia-h4" ]

                4 ->
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
            Html.hr (annotation attr "lia-horiz-line") []

        Paragraph attr elements ->
            Html.p (annotation attr "lia-paragraph") (config.view elements)

        Effect attr ( id_in, id_out, sub_blocks ) ->
            if config.mode == Textbook || ((id_in <= config.section.effect_model.visible) && (id_out > config.section.effect_model.visible)) then
                Html.div
                    ((if id_in == config.section.effect_model.visible then
                        Attr.id "focused"
                      else
                        Attr.id (toString id_in)
                     )
                        :: annotation attr "lia-effect-inline"
                    )
                    (Effects.view_block (view_block config) id_in sub_blocks)
            else
                Html.text ""

        BulletList attr list ->
            list
                |> view_list config
                |> Html.ul (annotation attr "lia-list lia-unordered")

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol (annotation attr "lia-list lia-ordered")

        Table attr header format body ->
            view_table config attr header format body

        Quote attr elements ->
            elements
                |> List.map (\e -> view_block config e)
                |> Html.blockquote (annotation attr "lia-quote")

        Code attr code ->
            code
                |> Codes.view attr config.section.code_vector
                |> Html.map UpdateCode

        Quiz attr quiz Nothing ->
            Html.div [ Attr.class "lia-quiz" ]
                [ Quizzes.view attr quiz config.section.quiz_vector
                    |> Html.map UpdateQuiz
                ]

        Quiz attr quiz (Just ( answer, hidden_effects )) ->
            Html.div [ Attr.class "lia-quiz" ] <|
                case Quizzes.view_solution config.section.quiz_vector quiz of
                    ( empty, True ) ->
                        List.append
                            [ Html.map UpdateQuiz <| Quizzes.view attr quiz config.section.quiz_vector ]
                            ((if empty then
                                Html.text ""
                              else
                                Html.hr [] []
                             )
                                :: List.map (view_block config) answer
                            )

                    _ ->
                        [ Quizzes.view attr quiz config.section.quiz_vector
                            |> Html.map UpdateQuiz
                        ]

        Survey attr survey ->
            config.section.survey_vector
                |> Surveys.view attr survey
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

                --(Presentation, True) ->
                _ ->
                    Html.text ""

        Chart attr chart ->
            Charts.view attr chart


view_table : Config -> Annotation -> MultInlines -> List String -> List MultInlines -> Html Msg
view_table config attr header format body =
    let
        view_row fct row =
            List.map2
                (\r f -> r |> config.view |> fct [ Attr.align f ])
                row
                format
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
        |> Html.table (annotation attr "lia-table")


view_list : Config -> List (List Markdown) -> List (Html Msg)
view_list config list =
    let
        viewer sub_list =
            List.map (view_block config) sub_list

        html =
            Html.li []
    in
    list
        |> List.map viewer
        |> List.map html
