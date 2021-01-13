module Lia.Markdown.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Lazy as Lazy
import Lia.Markdown.Chart.View as Charts
import Lia.Markdown.Code.View as Codes
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Effect.Model as Comments
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.Model as Footnotes
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Types exposing (Inlines, htmlBlock)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Table.View as Table
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (SubSection(..))
import Lia.Settings.Model exposing (Mode(..))
import Lia.Utils as Utils
import SvgBob


view : Config Msg -> Html Msg
view config =
    case config.section.error of
        Nothing ->
            if config.mode == Newspaper then
                config.section.body
                    |> List.map (view_block config)
                    |> List.foldl
                        (\a ( b, bs ) ->
                            if List.length b > 12 then
                                ( [ a ], List.append bs [ b ] )

                            else
                                ( List.append b [ a ], bs )
                        )
                        ( [], [] )
                    |> (\( b, bs ) ->
                            List.append bs [ b ]
                       )
                    |> List.map
                        (Html.div
                            [ Attr.style "display" "block"
                            , Attr.style "column-count" "3"
                            , Attr.style "column-width" "600px"
                            , Attr.style "column-fill" "auto"
                            , Attr.style "column-gap" "40px"
                            , Attr.style "column-rule" "1px dotted #ddd"
                            ]
                        )
                    |> List.intersperse
                        (Html.hr
                            [ Attr.style "border" "2px inset"
                            , Attr.style "margin" "30px"
                            ]
                            []
                        )
                    |> (::) (view_header config)
                    |> Html.section
                        [ Attr.class "lia-content"
                        ]

            else
                view_body
                    ( Config.setSubViewer (subView config) config
                    , config.section.footnote2show
                    , config.section.footnotes
                    )
                    config.section.body

        Just msg ->
            Html.section [ Attr.class "lia-content" ]
                [ view_header config
                , Html.text msg
                ]


subView : Config Msg -> Int -> SubSection -> List (Html (Script.Msg Msg))
subView config id sub =
    List.map (Html.map (Script.Sub id)) <|
        case sub of
            SubSection x ->
                let
                    section =
                        config.section

                    effects =
                        config.section.effect_model

                    main =
                        config.main
                in
                List.map
                    (view_block
                        { config
                            | main = { main | scripts = x.effect_model.javascript }
                            , section =
                                { section
                                    | table_vector = x.table_vector
                                    , quiz_vector = x.quiz_vector
                                    , survey_vector = x.survey_vector
                                    , code_vector = x.code_vector
                                    , effect_model =
                                        { effects
                                            | comments = x.effect_model.comments
                                            , javascript = x.effect_model.javascript
                                        }
                                }
                        }
                    )
                    x.body

            SubSubSection x ->
                let
                    main =
                        config.main
                in
                x.body
                    |> viewer { main | scripts = x.effect_model.javascript }
                    |> List.map (Html.map Script)


view_body : ( Config Msg, Maybe String, Footnotes.Model ) -> List Markdown -> Html Msg
view_body ( config, footnote2show, footnotes ) =
    List.map (view_block config)
        >> (::) (view_footnote (view_block config) footnote2show footnotes)
        >> (::) (view_header config)
        >> (\s ->
                if config.main.visible == Nothing then
                    List.append s [ Footnote.block (view_block config) footnotes ]

                else
                    s
           )
        >> Html.section [ Attr.class "lia-content" ]


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


view_header : Config Msg -> Html Msg
view_header config =
    [ header config
        config.section.indentation
        []
        config.section.title
    ]
        |> Html.header []


header : Config Msg -> Int -> Parameters -> Inlines -> Html Msg
header config i attr =
    config.view
        >> (case i of
                1 ->
                    Html.h1 (annotation "lia-inline lia-h1" attr)

                2 ->
                    Html.h2 (annotation "lia-inline lia-h2" attr)

                3 ->
                    Html.h3 (annotation "lia-inline lia-h3" attr)

                4 ->
                    Html.h4 (annotation "lia-inline lia-h4" attr)

                5 ->
                    Html.h5 (annotation "lia-inline lia-h5" attr)

                _ ->
                    Html.h6 (annotation "lia-inline lia-h6" attr)
           )


view_block : Config Msg -> Markdown -> Html Msg
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
                    Html.p (annotation "lia-paragraph" attr |> Utils.avoidColumn) (config.view [ element ])

        Paragraph attr elements ->
            Html.p
                (annotation "lia-paragraph" attr
                    |> Utils.avoidColumn
                )
                (config.view elements)

        Effect attr e ->
            e.content
                |> List.map (view_block config)
                |> Effect.block config.main config.section.effect_model attr e

        BulletList attr list ->
            list
                |> view_bulletlist config
                |> Html.ul
                    (annotation "lia-list lia-unordered" attr
                        |> Utils.avoidColumn
                    )

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol
                    (annotation "lia-list lia-ordered" attr
                        |> Utils.avoidColumn
                    )

        Table attr table ->
            Table.view
                config
                attr
                table

        Quote attr elements ->
            elements
                |> List.map (\e -> view_block config e)
                |> Html.blockquote (annotation "lia-quote" attr)

        HTML attr node ->
            HTML.view Html.div (view_block config) attr node

        Code code ->
            code
                |> Codes.view config.main.lang config.ace_theme config.section.code_vector
                |> Html.map UpdateCode

        Quiz attr quiz Nothing ->
            Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr)
                [ Quizzes.view config.main quiz config.section.quiz_vector
                    |> Html.map UpdateQuiz
                ]

        Quiz attr quiz (Just ( answer, hidden_effects )) ->
            Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr) <|
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

        Header attr ( elements, sub ) ->
            header config
                (config.section.indentation + sub)
                attr
                elements

        Chart attr chart ->
            Lazy.lazy3 Charts.view attr config.light chart

        ASCII attr bob ->
            view_ascii config attr bob


view_ascii : Config Msg -> Parameters -> SvgBob.Configuration (List Markdown) -> Html Msg
view_ascii config attr =
    SvgBob.drawElements (toAttribute attr)
        (\list ->
            Html.div [] <|
                case list of
                    [ Paragraph [] content ] ->
                        config.view content

                    -- TODO: remove after styling
                    (Code _) :: _ ->
                        [ List.map (view_block config) list
                            |> Html.div [ Attr.style "margin-top" "-16px" ]
                        ]

                    _ ->
                        List.map (view_block config) list
        )
        >> (\svg ->
                if config.light then
                    svg

                else
                    Html.div
                        [ Attr.style "-webkit-filter" "invert(100%)"
                        , Attr.style "filter" "invert(100%)"
                        ]
                        [ svg ]
           )


view_list : Config Msg -> List ( String, List Markdown ) -> List (Html Msg)
view_list config =
    let
        viewer ( value, sub_list ) =
            List.map (view_block config) sub_list
                |> Html.li [ Attr.value value ]
    in
    List.map viewer


view_bulletlist : Config Msg -> List (List Markdown) -> List (Html Msg)
view_bulletlist config =
    let
        viewer =
            List.map (view_block config)
                >> Html.li []
    in
    List.map viewer
