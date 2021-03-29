module Lia.Markdown.View exposing (view)

import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
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
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines, htmlBlock, mediaBlock)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Table.View as Table
import Lia.Markdown.Task.View as Task
import Lia.Markdown.Types exposing (Markdown(..), MarkdownS)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (SubSection(..))
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (btnIcon)
import Lia.Voice as Voice
import SvgBob


view : Config Msg -> Html Msg
view config =
    case config.section.error of
        Nothing ->
            view_body
                ( Config.setSubViewer (subView config) config
                , config.section.footnote2show
                , config.section.footnotes
                )
                config.section.body

        Just msg ->
            viewMain
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
                                    , code_model = x.code_model
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
        >> viewMain


viewMain : List (Html msg) -> Html msg
viewMain =
    Html.main_
        [ Attr.class "lia-slide__content"
        , A11y_Landmark.main_
        ]


view_footnote : (Markdown -> Html Msg) -> Maybe String -> Footnotes.Model -> Html Msg
view_footnote viewer key footnotes =
    case Maybe.andThen (Footnotes.getNote footnotes) key of
        Just notes ->
            Html.div
                [ Attr.style "position" "fixed"
                , Attr.style "display" "block"
                , Attr.style "width" "100%"
                , Attr.style "height" "100%"
                , Attr.style "top" "0"
                , Attr.style "right" "0"
                , Attr.style "background-color" "rgba(0,0,0,0.8)"
                , Attr.style "z-index" "9999"
                , Attr.style "overflow" "auto"

                --, onClick FootnoteHide
                ]
                [ notes
                    |> List.map viewer
                    |> (::) (Html.br [] [])
                    |> (::)
                        (btnIcon
                            { icon = "icon-close"
                            , msg = Just FootnoteHide
                            , tabbable = True
                            , title = "close"
                            }
                            [ Attr.class "lia-btn--transparent"
                            , Attr.style "float" "right"
                            , Attr.style "right" "-3.5rem"
                            ]
                        )
                    |> Html.div
                        [ Attr.style "position" "absolute"
                        , Attr.style "top" "30%"
                        , Attr.style "left" "50%"
                        , Attr.style "font-size" "20px"
                        , Attr.style "color" "white"
                        , Attr.style "transform" "translate(-50%,-30%)"
                        , Attr.style "-ms-transform" "translate(-50%,-30%)"
                        , A11y_Widget.modal True
                        , A11y_Role.dialog
                        , Attr.style "z-index" "10000"
                        ]
                ]

        Nothing ->
            Html.text ""


view_header : Config Msg -> Html Msg
view_header config =
    [ header config
        config.section.indentation
        0
        []
        config.section.title
    ]
        |> Html.header [ A11y_Key.tabbable False ]


header : Config Msg -> Int -> Int -> Parameters -> Inlines -> Html Msg
header config main sub attr =
    config.view
        >> (case sub of
                0 ->
                    Html.h1 (headerStyle (main + sub) attr)

                1 ->
                    Html.h2 (headerStyle (main + sub) attr)

                2 ->
                    Html.h3 (headerStyle (main + sub) attr)

                3 ->
                    Html.h4 (headerStyle (main + sub) attr)

                4 ->
                    Html.h5 (headerStyle (main + sub) attr)

                _ ->
                    Html.h6 (headerStyle (main + sub) attr)
           )


headerStyle i =
    annotation
        ("h"
            ++ (String.fromInt <|
                    if i > 4 then
                        4

                    else
                        i
               )
        )


view_block : Config Msg -> Markdown -> Html Msg
view_block config block =
    case block of
        HLine attr ->
            Html.hr (annotation "lia-divider" attr) []

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
                    if mediaBlock element && attr == [] then
                        config.view [ element ]
                            |> List.head
                            |> Maybe.withDefault (Html.text "")

                    else
                        Html.p (annotation "lia-paragraph" attr) (config.view [ element ])

        Paragraph attr elements ->
            Html.p
                (annotation "lia-paragraph" attr)
                (config.view elements)

        Effect attr e ->
            e.content
                |> List.map (view_block config)
                |> Effect.block config.main config.section.effect_model attr e

        BulletList attr list ->
            list
                |> view_bulletlist config
                |> Html.ul (annotation "lia-list--unordered" attr)

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol (annotation "lia-list--ordered" attr)

        Table attr table ->
            Table.view config attr table

        Quote attr quote ->
            viewQuote config attr quote

        HTML attr node ->
            HTML.view Html.div (view_block config) attr node

        Code code ->
            code
                |> Codes.view config.main.lang config.ace_theme config.section.code_model
                |> Html.map UpdateCode

        Quiz attr quiz solution ->
            viewQuiz config attr quiz solution

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
                ( Nothing, Just ( _, ( attr, par ) ) ) ->
                    par
                        |> Paragraph attr
                        |> view_block config

                ( Just _, Just ( narrator, ( attr, par ) ) ) ->
                    let
                        attributes =
                            case Voice.getVoiceFor narrator config.translations of
                                Nothing ->
                                    []

                                Just ( translate, voice ) ->
                                    [ ( "class", "lia-tts-" ++ String.fromInt id1 )
                                    , ( "class"
                                      , if translate then
                                            "hidden-visually translate"

                                        else
                                            "hide notranslate"
                                      )
                                    , ( "data-voice", voice )
                                    , ( "translate"
                                      , if translate then
                                            "yes"

                                        else
                                            "no"
                                      )
                                    , ( "aria-hidden", "true" )
                                    ]
                    in
                    par
                        |> Paragraph (List.append attributes attr)
                        |> view_block config

                ( _, Nothing ) ->
                    Html.text ""

        Header attr ( elements, sub ) ->
            header config
                config.section.indentation
                sub
                attr
                elements

        Chart attr chart ->
            Lazy.lazy4 Charts.view config.main.lang attr config.light chart

        ASCII attr bob ->
            view_ascii config attr bob

        Task attr list ->
            Task.view config.main config.section.task_vector attr list
                |> Html.map UpdateTask

        Gallery attr list ->
            list
                |> config.view
                |> Html.div (annotation "lia-gallery" attr)


viewQuote : Config Msg -> Parameters -> ( List Markdown, Maybe ( Parameters, Inlines ) ) -> Html Msg
viewQuote config attr ( elements, cite ) =
    case cite of
        Nothing ->
            elements
                |> List.map (view_block config)
                |> Html.blockquote (annotation "lia-quote" attr)

        Just ( cAttr, citation ) ->
            [ elements
                |> List.map (view_block config)
                |> Html.em [ Attr.class "lia-quote__text" ]
            , citation
                |> config.view
                |> (::) (Html.text "—")
                |> Html.cite (annotation "lia-quote__cite" cAttr)
            ]
                |> Html.blockquote
                    (Attr.cite
                        (citation
                            |> stringify_ config.main.scripts config.main.visible
                            |> String.trim
                        )
                        :: annotation "lia-quote" attr
                    )


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


viewQuiz : Config Msg -> Parameters -> Quiz.Quiz -> Maybe ( MarkdownS, Int ) -> Html Msg
viewQuiz config attr quiz solution =
    case solution of
        Nothing ->
            Quizzes.view config.main quiz config.section.quiz_vector
                |> Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr)
                |> Html.map UpdateQuiz

        Just ( answer, hidden_effects ) ->
            Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr) <|
                if Quizzes.showSolution config.section.quiz_vector quiz then
                    (config.section.quiz_vector
                        |> Quizzes.view config.main quiz
                        |> List.map (Html.map UpdateQuiz)
                    )
                        ++ [ Html.div [ Attr.class "lia-quiz__solution" ] <| List.map (view_block config) answer ]

                else
                    config.section.quiz_vector
                        |> Quizzes.view config.main quiz
                        |> List.map (Html.map UpdateQuiz)


view_list : Config Msg -> List ( String, List Markdown ) -> List (Html Msg)
view_list config =
    let
        viewer ( value, sub_list ) =
            Html.li [ Attr.value value ]
                [ List.map (view_block config) sub_list
                    |> Html.span []
                ]
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
