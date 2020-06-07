module Lia.Markdown.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Chart.View as Charts
import Lia.Markdown.Code.View as Codes
import Lia.Markdown.Config exposing (Config)
import Lia.Markdown.Effect.Model as Comments
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.Model as Footnotes
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (annotation, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Types exposing (htmlBlock)
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Table.View as Table
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Settings.Model exposing (Mode(..))
import SvgBob


view : Config -> Html Msg
view config =
    case config.section.error of
        Just msg ->
            Html.section [ Attr.class "lia-content" ]
                [ view_header config
                , Html.text msg
                ]

        Nothing ->
            view_body ( config, config.section.footnote2show, config.section.footnotes ) config.section.body


view_body : ( Config, Maybe String, Footnotes.Model ) -> List Markdown -> Html Msg
view_body ( config, footnote2show, footnotes ) body =
    body
        |> List.map (view_block config)
        |> (::) (view_footnote (view_block config) footnote2show footnotes)
        |> (::) (view_header config)
        |> (\s ->
                if config.main.visible == Nothing then
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

        Paragraph attr [ element ] ->
            case htmlBlock element of
                Just ( name, attributes, inlines ) ->
                    HTML.view
                        Html.div
                        (config.view
                            >> List.head
                            >> Maybe.withDefault
                                (Html.p (annotation "lia-paragraph" attr) (config.view [ element ]))
                        )
                        attr
                        (Node name attributes [ inlines ])

                Nothing ->
                    Html.p (annotation "lia-paragraph" attr) (config.view [ element ])

        Paragraph attr elements ->
            Html.p (annotation "lia-paragraph" attr) (config.view elements)

        Effect attr e ->
            e.content
                |> List.map (view_block config)
                |> Effect.block config.main config.section.effect_model attr e

        BulletList attr list ->
            list
                |> view_bulletlist config
                |> Html.ul (annotation "lia-list lia-unordered" attr)

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol (annotation "lia-list lia-ordered" attr)

        Table attr table ->
            Table.view
                config.view
                config.screen.width
                config.main.visible
                attr
                config.light
                table
                config.section.table_vector

        Quote attr elements ->
            elements
                |> List.map (\e -> view_block config e)
                |> Html.blockquote (annotation "lia-quote" attr)

        HTML attr node ->
            HTML.view Html.div (view_block config) attr node

        Code attr code ->
            code
                |> Codes.view config.main.lang config.ace_theme attr config.section.code_vector
                |> Html.map UpdateCode

        Quiz attr quiz Nothing ->
            Html.div (annotation "lia-quiz lia-card" attr)
                [ Quizzes.view config.main quiz config.section.quiz_vector
                    |> Html.map UpdateQuiz
                ]

        Quiz attr quiz (Just ( answer, hidden_effects )) ->
            Html.div (annotation "lia-quiz lia-card" attr) <|
                if Quizzes.view_solution config.section.quiz_vector quiz then
                    List.append
                        [ Html.map UpdateQuiz <| Quizzes.view config.main quiz config.section.quiz_vector ]
                        (Html.hr [] [] :: List.map (view_block config) answer)

                else
                    [ Quizzes.view config.main quiz config.section.quiz_vector
                        |> Html.map UpdateQuiz
                    ]

        Survey attr survey ->
            config.section.survey_vector
                |> Surveys.view config.main attr survey
                |> Html.map UpdateSurvey

        Comment ( id1, id2 ) ->
            case
                ( config.main.visible
                , Comments.get_paragraph id1 id2 config.section.effect_model
                )
            of
                ( Nothing, Just ( attr, par ) ) ->
                    par
                        |> Paragraph attr
                        |> view_block config

                _ ->
                    Html.text ""

        Chart attr chart ->
            Charts.view attr config.light chart

        ASCII attr txt ->
            txt
                |> SvgBob.init SvgBob.default
                |> SvgBob.getSvg (toAttribute attr)
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

        Skip ->
            Html.text ""


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
