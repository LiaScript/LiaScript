module Lia.Markdown.View exposing
    ( addTranslation
    , view
    )

import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Conditional.List as CList
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Lazy as Lazy
import Json.Encode as JE
import Lia.Markdown.Chart.View as Charts
import Lia.Markdown.Code.View as Codes
import Lia.Markdown.Config as Config exposing (Config)
import Lia.Markdown.Effect.Model as Comments
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.Model as Footnotes
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.Gallery.View as Gallery
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines, htmlBlock, mediaBlock)
import Lia.Markdown.Inline.View as Inline
import Lia.Markdown.Json.Encode as Encode
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Table.View as Table
import Lia.Markdown.Task.View as Task
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (SubSection(..))
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (modal)
import Lia.Voice as Voice
import MD5
import SvgBob


view : Bool -> Bool -> Config Msg -> Html Msg
view hidden persistent config =
    case config.section.error of
        Nothing ->
            if persistent || not hidden then
                view_body hidden
                    ( Config.setSubViewer (subView config) config
                    , config.section.footnote2show
                    , config.section.footnotes
                    )
                    config.section.body

            else
                viewMain hidden [ view_header config ]

        Just msg ->
            viewMain hidden
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
                    |> Inline.viewer { main | scripts = x.effect_model.javascript }
                    |> List.map (Html.map Script)


view_body : Bool -> ( Config Msg, Maybe String, Footnotes.Model ) -> Blocks -> Html Msg
view_body hidden ( config, footnote2show, footnotes ) =
    fold config []
        >> (::) (view_footnote (view_block config) footnote2show footnotes)
        >> (::) (view_header config)
        >> (\s ->
                List.append s <|
                    if config.main.visible == Nothing then
                        [ Footnote.block (view_block config) footnotes ]

                    else
                        config.section.effect_model.comments
                            |> Comments.getHiddenComments
                            |> List.map
                                (\( id, voice, text ) ->
                                    Html.span
                                        (voice
                                            |> addTranslation True config.main.translations id
                                            |> toAttribute
                                        )
                                        [ Html.text text ]
                                )
           )
        >> viewMain hidden


toHash : Block -> String
toHash =
    List.singleton
        >> Encode.encode
        >> JE.encode 0
        >> MD5.hex
        >> String.slice 0 8


fold : Config Msg -> List (Html Msg) -> Blocks -> List (Html Msg)
fold config output blocks =
    case blocks of
        [] ->
            List.reverse output

        (Paragraph a e) :: (Quiz attr quiz solution) :: bs ->
            let
                id =
                    toHash (Paragraph a e)
            in
            fold config
                (viewQuiz config (Just id) attr quiz solution
                    :: view_block config (Paragraph (( "id", id ) :: a) e)
                    :: output
                )
                bs

        (HTML a e) :: (Quiz attr quiz solution) :: bs ->
            let
                id =
                    toHash (HTML a e)
            in
            fold config
                (viewQuiz config (Just id) attr quiz solution
                    :: view_block config (HTML (( "id", id ) :: a) e)
                    :: output
                )
                bs

        b :: bs ->
            fold config (view_block config b :: output) bs


addTranslation : Bool -> Maybe ( String, String ) -> Int -> String -> List ( String, String )
addTranslation hidden translations id narrator =
    case translations |> Maybe.andThen (Voice.getVoiceFor narrator) of
        Nothing ->
            []

        Just { translated, lang, name } ->
            [ ( "class"
              , case ( translated, hidden ) of
                    ( True, True ) ->
                        "translate hidden-visually"

                    ( False, True ) ->
                        "notranslate hide"

                    ( True, False ) ->
                        "translate"

                    ( False, False ) ->
                        "notranslate"
              )
            , ( "class", "lia-tts-" ++ String.fromInt id )
            , ( "data-voice", name )
            , ( "data-lang", lang )
            , ( "translate"
              , if translated then
                    "yes"

                else
                    "no"
              )
            ]
                |> CList.addIf hidden ( "aria-hidden", "true" )


viewMain : Bool -> List (Html msg) -> Html msg
viewMain hidden =
    Html.main_
        [ Attr.class "lia-slide__content"
        , A11y_Landmark.main_
        , Attr.hidden hidden
        ]


view_footnote : (Block -> Html Msg) -> Maybe String -> Footnotes.Model -> Html Msg
view_footnote viewer key footnotes =
    case Maybe.andThen (Footnotes.getNote footnotes) key of
        Just notes ->
            [ notes
                |> List.map viewer
                |> Html.div
                    [ Attr.style "max-height" "92%"
                    , Attr.style "overflow" "auto"
                    ]
                |> List.singleton
                |> Html.div
                    [ Attr.style "display" "flex"
                    , Attr.style "align-items" "center"
                    , Attr.style "max-width" "90%"
                    ]
            ]
                |> modal FootnoteHide Nothing

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


headerStyle : Int -> Parameters -> List (Attribute msg)
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


view_block : Config Msg -> Block -> Html Msg
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
                (annotation
                    (if
                        List.head elements
                            |> Maybe.map mediaBlock
                            |> Maybe.withDefault False
                     then
                        "lia-paragraph clearfix"

                     else
                        "lia-paragraph"
                    )
                    attr
                )
                (config.view elements)

        Effect attr e ->
            e.content
                |> List.map (view_block config)
                |> Effect.block config.main config.section.effect_model attr e

        BulletList attr list ->
            list
                |> view_bulletList config
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
            viewQuiz config Nothing attr quiz solution

        Survey attr survey ->
            config.section.sync
                |> Maybe.andThen .survey
                |> Surveys.view config.main attr survey config.section.survey_vector
                |> Tuple.mapSecond (Html.map UpdateSurvey)
                |> scriptView config.view

        Comment ( id1, id2 ) ->
            case
                ( config.mode
                  -- , config.main.visible
                , Comments.get_paragraph
                    (config.main.visible /= Nothing)
                    id1
                    id2
                    config.section.effect_model
                )
            of
                ( Textbook, Just ( _, comment ) ) ->
                    view_block config (Paragraph comment.attr comment.content)

                ( Presentation, Just ( narrator, comment ) ) ->
                    comment.content
                        |> Inline.reduce config.main
                        |> Html.div
                            (narrator
                                |> addTranslation True config.main.translations id1
                                |> toAttribute
                            )
                        |> Html.map Script

                _ ->
                    Html.text ""

        Header attr ( sub, elements ) ->
            header config
                config.section.indentation
                sub
                attr
                elements

        Chart attr chart ->
            Lazy.lazy2 Charts.view
                { lang = config.main.lang
                , attr = attr
                , light = config.light
                }
                chart

        ASCII attr bob ->
            view_ascii config attr bob

        Task attr list ->
            Task.view config.main config.section.task_vector attr list
                |> Tuple.mapSecond (Html.map UpdateTask)
                |> scriptView config.view

        Gallery attr media ->
            Gallery.view config.main config.section.gallery_vector attr media
                |> Html.map UpdateGallery

        Citation attr quote ->
            quote
                |> config.view
                |> (::) (Html.text "—")
                |> Html.cite (annotation "lia-cite" attr)

        Problem element ->
            Html.p [ Attr.class "lia-problem" ] (config.view element)

        HtmlComment ->
            Html.text ""


scriptView : (Inlines -> List (Html Msg)) -> ( Maybe Int, Html Msg ) -> Html Msg
scriptView viewer content =
    case content of
        ( Nothing, sub ) ->
            sub

        ( Just id, sub ) ->
            Html.div []
                [ sub
                , [ Inline.toScript id [ ( "display", "inline-block" ) ] ]
                    |> viewer
                    |> Html.div [ Attr.class "lia-paragraph" ]
                ]


viewQuote : Config Msg -> Parameters -> Blocks -> Html Msg
viewQuote config attr elements =
    case elements of
        [ Paragraph pAttr pElement, Citation cAttr citation ] ->
            [ [ Paragraph pAttr pElement ]
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

        _ ->
            elements
                |> List.map (view_block config)
                |> Html.blockquote (annotation "lia-quote" attr)


view_ascii : Config Msg -> Parameters -> ( Maybe Inlines, SvgBob.Configuration Blocks ) -> Html Msg
view_ascii config attr ( caption, image ) =
    image
        |> SvgBob.drawElements (toAttribute attr)
            (\list ->
                Html.div [] <|
                    case list of
                        [ Paragraph [] content ] ->
                            config.view content

                        _ ->
                            List.map (view_block config) list
            )
        |> (\svg ->
                Html.figure [ Attr.class "lia-figure" ]
                    [ Html.div
                        ([ Attr.class "lia-figure__media" ]
                            |> CList.appendIf (not config.light)
                                [ Attr.style "-webkit-filter" "invert(100%)"
                                , Attr.style "filter" "invert(100%)"
                                ]
                        )
                        [ svg
                        ]
                    , case caption of
                        Nothing ->
                            Html.text ""

                        Just content ->
                            content
                                |> config.view
                                |> Html.figcaption [ Attr.class "lia-figure__caption" ]
                    ]
           )


viewQuiz : Config Msg -> Maybe String -> Parameters -> Quiz.Quiz -> Maybe ( Blocks, Int ) -> Html Msg
viewQuiz config labeledBy attr quiz solution =
    scriptView config.view <|
        case solution of
            Nothing ->
                config.section.sync
                    |> Maybe.andThen .quiz
                    |> Quizzes.view config.main labeledBy quiz config.section.quiz_vector
                    |> Tuple.mapSecond (Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr))
                    |> Tuple.mapSecond (Html.map UpdateQuiz)

            Just ( answer, hidden_effects ) ->
                if Quizzes.showSolution quiz config.section.quiz_vector then
                    config.section.sync
                        |> Maybe.andThen .quiz
                        |> Quizzes.view config.main labeledBy quiz config.section.quiz_vector
                        |> Tuple.mapSecond (List.map (Html.map UpdateQuiz))
                        |> Tuple.mapSecond
                            (\list ->
                                List.append list
                                    [ answer
                                        |> List.map (view_block config)
                                        |> Html.div [ Attr.class "lia-quiz__solution" ]
                                    ]
                            )
                        |> Tuple.mapSecond (Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr))

                else
                    config.section.sync
                        |> Maybe.andThen .quiz
                        |> Quizzes.view config.main labeledBy quiz config.section.quiz_vector
                        |> Tuple.mapSecond (List.map (Html.map UpdateQuiz))
                        |> Tuple.mapSecond (Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr))


view_list : Config Msg -> List ( String, Blocks ) -> List (Html Msg)
view_list config =
    let
        viewer ( value, sub_list ) =
            Html.li [ Attr.value value ]
                (List.map (view_block config) sub_list)
    in
    List.map viewer


view_bulletList : Config Msg -> List Blocks -> List (Html Msg)
view_bulletList config =
    let
        viewer =
            List.map (view_block config)
                >> Html.li []
    in
    List.map viewer
