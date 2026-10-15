module Lia.Markdown.View exposing
    ( addTranslation
    , hideUnsolvedComments
    , view
    , viewContent
    , viewHidden
    )

import Accessibility.Key as A11y_Key
import Accessibility.Landmark as A11y_Landmark
import Array exposing (Array)
import Conditional.List as CList
import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Lazy as Lazy
import I18n.Translations exposing (Lang)
import Lia.Markdown.Chart.Types as ChartTypes
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
import Lia.Markdown.Inline.Config as InlineConfig
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types as Inline exposing (Inlines, htmlBlock, mediaBlock)
import Lia.Markdown.Inline.View as Inline
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Table.View as Table
import Lia.Markdown.Task.View as Task
import Lia.Markdown.Types exposing (Alert(..), Block(..), Blocks)
import Lia.Markdown.Update exposing (Msg(..), solutions)
import Lia.Section exposing (SubSection(..))
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (icon, modal, shuffle)
import Lia.Voice as Voice
import SvgBob


{-| Render a section, a `hidden` section that is not `persistent` only renders
an empty `main`. If the section could not be parsed, only its title and the
error are shown.
-}
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
                viewMain hidden []

        Just msg ->
            viewMain hidden
                [ view_header config
                , Html.text msg
                ]


{-| Render the LiaScript result `sub` of script `id`, with its own vectors but
the effects of the section.
-}
subView : Config Msg -> Int -> Int -> SubSection -> List (Html (Script.Msg Msg))
subView config slide id sub =
    let
        section =
            config.section

        effects =
            config.section.effect_model

        main =
            config.main
    in
    List.map (Html.map (Script.Sub id)) <|
        case sub of
            SubSection x ->
                let
                    input =
                        main.input
                in
                List.map
                    (view_block
                        (withSubViewer
                            { config
                                | main = { main | scripts = x.effect_model.javascript, input = { input | path = ( "effect", slide ) :: ( "sub", id ) :: input.path } }
                                , section =
                                    { section
                                        | table_vector = x.table_vector
                                        , quiz_vector = x.quiz_vector
                                        , survey_vector = x.survey_vector
                                        , code_model = x.code_model
                                        , task_vector = x.task_vector
                                        , gallery_vector = x.gallery_vector
                                        , effect_model =
                                            { effects
                                                | comments = x.effect_model.comments
                                                , javascript = x.effect_model.javascript
                                            }
                                    }
                            }
                        )
                    )
                    x.body

            SubSubSection x ->
                { config
                    | main = { main | scripts = x.effect_model.javascript }
                    , section = { section | effect_model = { effects | javascript = x.effect_model.javascript } }
                }
                    |> withSubViewer
                    |> .view
                    |> (|>) x.body


{-| Inlines (and their scripts) of a sub-section use its own scripts, results of
these scripts are sub-sections again.
-}
withSubViewer : Config Msg -> Config Msg
withSubViewer config =
    let
        main =
            InlineConfig.setViewer (subView config) config.main
    in
    { config | main = main, view = Inline.viewer main >> List.map (Html.map Script) }


{-| The title, the opened footnote, all blocks, and at the end either all
footnotes (textbook mode) or the comments for the narrator (presentation mode).
-}
view_body : Bool -> ( Config Msg, Maybe String, Footnotes.Model ) -> Blocks -> Html Msg
view_body hidden ( config, footnote2show, footnotes ) =
    fold config []
        >> (::) (view_footnote (view_block config) footnote2show footnotes)
        >> (::) (view_header config)
        >> (\s ->
                List.append s <|
                    if config.main.visible == Nothing then
                        [ Footnote.block config.main.lang (view_block config) footnotes ]

                    else if config.mode == Presentation then
                        config.section.effect_model.comments
                            |> Comments.getHiddenComments
                            |> List.map
                                (\( id, voice, text ) ->
                                    Html.span
                                        ({ hidden = True
                                         , translations = config.main.translations
                                         , id = id
                                         , narrator = voice
                                         , audio = Array.empty
                                         }
                                            |> addTranslation
                                            |> toAttribute
                                        )
                                        [ Html.text text ]
                                )

                    else
                        []
           )
        >> viewMain hidden


{-| Only the blocks of a section (used by the chat).
-}
viewContent : Config Msg -> List (Html Msg)
viewContent config =
    let
        config_ =
            Config.setSubViewer (subView config) config
    in
    fold config_ [] config_.section.body


{-| Id of the block in front of a quiz, survey or task list, which labels it
(aria-labelledby), it only has to be unique within the page.
-}
labelID : Config Msg -> Block -> Maybe String
labelID config block =
    let
        prefix name id =
            Just ("lia-" ++ name ++ "-" ++ String.fromInt config.section.id ++ "-" ++ String.fromInt id)
    in
    case block of
        Quiz _ quiz _ ->
            prefix "quiz" quiz.id

        Survey _ survey _ ->
            prefix "survey" survey.id

        Task _ task ->
            prefix "task" task.id

        _ ->
            Nothing


{-| Render blocks, a paragraph or HTML block in front of a quiz, survey or task
list becomes its label.
-}
fold : Config Msg -> List (Html Msg) -> Blocks -> List (Html Msg)
fold config output blocks =
    case blocks of
        [] ->
            List.reverse output

        b :: next :: bs ->
            case
                labelID config next
                    |> Maybe.andThen (\id -> withId id b |> Maybe.map (Tuple.pair id))
            of
                Just ( id, label ) ->
                    fold config
                        (viewLabeled config (Just id) next
                            :: view_block config label
                            :: output
                        )
                        bs

                Nothing ->
                    fold config (view_block config b :: output) (next :: bs)

        b :: bs ->
            fold config (view_block config b :: output) bs


{-| Render a quiz, survey or task list, which is labeled by the block with the
id `labeledBy`.
-}
viewLabeled : Config Msg -> Maybe String -> Block -> Html Msg
viewLabeled config labeledBy block =
    case block of
        Quiz attr quiz solution ->
            viewQuiz config labeledBy attr quiz solution

        Survey attr survey solution ->
            viewSurvey config labeledBy attr survey solution

        Task attr task ->
            task.items
                |> List.map (viewBlocks config)
                |> Task.view
                    ("lia-task-" ++ String.fromInt config.section.id ++ "-" ++ String.fromInt task.id)
                    labeledBy
                    config.section.task_vector
                    attr
                    task
                |> scriptView config.view

        _ ->
            view_block config block


withId : String -> Block -> Maybe Block
withId id block =
    case block of
        Paragraph a e ->
            Just (Paragraph (( "id", id ) :: a) e)

        HTML a e ->
            Just (HTML (( "id", id ) :: a) e)

        _ ->
            Nothing


{-| Attributes of a comment for the narrator: its voice and language, whether
it may be translated by the browser, and its recorded audio files (only used if
the course is not translated).
-}
addTranslation :
    { hidden : Bool
    , translations : Maybe { old : String, new : String, name : Maybe String }
    , id : Int
    , narrator : String
    , audio : Array String
    }
    -> List ( String, String )
addTranslation { hidden, translations, id, narrator, audio } =
    let
        -- Google's automatic page translation should pick up every
        -- comment that is spoken in the document's own language. Only a
        -- narrator that explicitly speaks a different language (e.g. a
        -- French quote within a German course) must stay untouched, no
        -- matter whether the document itself was translated (already or
        -- not) by Google/the browser in the meantime.
        isForeignNarrator =
            case translations of
                Just { old } ->
                    case Voice.getLang narrator of
                        Just narratorLang ->
                            narratorLang /= old

                        Nothing ->
                            False

                Nothing ->
                    False

        translateClass =
            case ( isForeignNarrator, hidden ) of
                ( True, True ) ->
                    "notranslate hide"

                ( True, False ) ->
                    "notranslate"

                ( False, True ) ->
                    "translate hidden-visually"

                ( False, False ) ->
                    "translate"

        translateAttr =
            if isForeignNarrator then
                "no"

            else
                "yes"
    in
    -- getVoiceFor only fails without a language name of the translation
    case translations |> Maybe.andThen (Voice.getVoiceFor narrator) of
        Nothing ->
            []

        Just { translated, lang, name } ->
            [ ( "class", translateClass )
            , ( "class", "lia-tts-" ++ String.fromInt id )
            , ( "data-voice", name )
            , ( "data-lang", lang )
            , ( "translate", translateAttr )

            -- consumed by the TTS service to decide whether a video's own
            -- audio should keep playing (untranslated) or be muted and
            -- overlaid with synthesized speech (translated)
            , ( "data-translated"
              , if translated then
                    "yes"

                else
                    "no"
              )
            ]
                |> CList.addIf hidden ( "aria-hidden", "true" )
                |> CList.addIf
                    ((Maybe.map (\t -> t.old == t.new) translations == Just True)
                        && not (Array.isEmpty audio)
                    )
                    ( "data-file", audio |> Array.toList |> String.join "," )


{-| The `main` element of a section, hidden sections are not announced.
-}
viewMain : Bool -> List (Html msg) -> Html msg
viewMain hidden =
    Html.main_ <|
        if hidden then
            [ Attr.hidden hidden
            ]

        else
            -- no live region, the focus moves to the heading of a new section
            [ Attr.class "lia-slide__content"
            , A11y_Landmark.main_
            ]


{-| The footnote `key` as a modal.
-}
view_footnote : (Block -> Html Msg) -> Maybe String -> Footnotes.Model -> Html Msg
view_footnote viewer key footnotes =
    case Maybe.andThen (\k -> Dict.get k footnotes) key of
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
                |> modal True FootnoteHide Nothing

        Nothing ->
            Html.text ""


{-| The title of the section.
-}
view_header : Config Msg -> Html Msg
view_header config =
    [ header config
        config.section.indentation
        0
        []
        config.section.title
    ]
        |> Html.header [ A11y_Key.tabbable False ]


{-| A header of level `main + sub`, where `main` is the level of the section
title and `sub` the level of a header within the section (0 for the title).
Levels above 6 become `h6`, the class (`h1` to `h5`) only depends on `sub`.
-}
header : Config Msg -> Int -> Int -> Parameters -> Inlines -> Html Msg
header config main sub attr =
    let
        level =
            if main + sub >= 1 && main + sub <= 5 then
                main + sub

            else
                6
    in
    config.view
        >> Html.node ("h" ++ String.fromInt level)
            (annotation ("h" ++ String.fromInt (min 5 (sub + 1))) attr)


{-| Render a single block.
-}
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
                    if mediaBlock element then
                        if attr == [] then
                            [ element ]
                                |> config.view
                                |> List.head
                                |> Maybe.withDefault (Html.text "")

                        else
                            [ element ]
                                |> config.view
                                |> Html.div (toAttribute attr)

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
                |> viewBlocks config
                |> Effect.block config.main config.section.effect_model attr e

        BulletList attr list ->
            list
                |> List.map (viewBlocks config >> Html.li [])
                |> Html.ul (annotation "lia-list--unordered" attr)

        OrderedList attr list ->
            list
                |> List.map (\( value, blocks ) -> Html.li [ Attr.value value ] (viewBlocks config blocks))
                |> Html.ol (annotation "lia-list--ordered" attr)

        Table attr table ->
            Table.view config attr table

        Quote attr alert quote ->
            viewQuote config attr alert quote

        HTML attr node ->
            HTML.view Html.div (view_block config) attr node

        Code code ->
            { lang = config.main.lang
            , theme = config.ace_theme
            , model = config.section.code_model
            , code = code
            , sync =
                config.main.sync
                    |> Maybe.andThen (.data >> .code >> Dict.get config.section.id)
                    |> Maybe.withDefault Array.empty
            , cursors =
                config.main.sync
                    |> Maybe.map
                        (.data
                            >> .cursor
                            >> List.filter (\cursor -> cursor.section == config.section.id)
                        )
                    |> Maybe.withDefault []
            }
                |> Codes.view
                |> Html.map UpdateCode

        Quiz _ _ _ ->
            viewLabeled config Nothing block

        Survey _ _ _ ->
            viewLabeled config Nothing block

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
                            ({ hidden = True
                             , translations = config.main.translations
                             , id = id1
                             , narrator = narrator
                             , audio = comment.audio
                             }
                                |> addTranslation
                                |> List.append comment.attr
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
            Lazy.lazy4 viewChart config.main.lang attr config.light chart

        ASCII attr bob ->
            view_ascii config attr bob

        Task _ _ ->
            viewLabeled config Nothing block

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


{-| Lazy needs stable arguments, a record literal would be new on every frame.
-}
viewChart : Lang -> Parameters -> Bool -> ChartTypes.Chart -> Html msg
viewChart lang attr light =
    Charts.view { lang = lang, attr = attr, light = light }


{-| Hidden sections that are not `persistent` render an empty `main`, which does
not require a `Config`.
-}
viewHidden : Html msg
viewHidden =
    viewMain True []


viewBlocks : Config Msg -> Blocks -> List (Html Msg)
viewBlocks config =
    fold config []


{-| Pre-render a Quiz-Vector's option content (used only for `Vector_Type`) via
`viewBlocks`, since option bodies may contain arbitrary Markdown block content
that only the top-level renderer knows how to display - see `Quiz.Vector.Parser`.
-}
quizVectorOptions : Config Msg -> Quiz.Type Block -> List (List (Html Msg))
quizVectorOptions config type_ =
    case type_ of
        Quiz.Vector_Type q ->
            q.options |> List.map (viewBlocks config)

        _ ->
            []


{-| Render a survey, which is labeled by the block with the id `labeledBy`, and
its solution, if it has been submitted.
-}
viewSurvey : Config Msg -> Maybe String -> Parameters -> Survey.Survey Block -> Maybe ( Blocks, Int ) -> Html Msg
viewSurvey config labeledBy attr survey solution =
    Surveys.view config.main labeledBy attr survey config.section.survey_vector (surveyVectorOptions config survey.survey)
        |> Tuple.mapSecond
            (\html ->
                case solution of
                    Just ( blocks, _ ) ->
                        if
                            config.section.survey_vector
                                |> Array.get survey.id
                                |> Maybe.map .submitted
                                |> Maybe.withDefault False
                        then
                            Html.div [] [ html, viewSolution config "survey" survey.id blocks ]

                        else
                            html

                    Nothing ->
                        html
            )
        |> scriptView config.view


{-| Pre-render a Survey-Vector's option content (used only for `Vector`) via
`viewBlocks` - see `Survey.Parser.vector`.
-}
surveyVectorOptions : Config Msg -> Survey.Type Block -> List ( String, List (Html Msg) )
surveyVectorOptions config type_ =
    case type_ of
        Survey.Vector _ options _ ->
            options |> List.map (Tuple.mapSecond (viewBlocks config))

        _ ->
            []


{-| The solution of quiz or survey `id` (`name`), which is shown after it
has been solved or submitted.
-}
viewSolution : Config Msg -> String -> Int -> Blocks -> Html Msg
viewSolution config name id =
    viewBlocks config
        >> Html.div
            [ Attr.class "lia-quiz__solution"
            , Attr.id ("lia-" ++ name ++ "-solution-" ++ String.fromInt id)
            ]


{-| Blocks with a script (quizzes, surveys and tasks with `@input`) get the
result of the script below.
-}
scriptView : (Inlines -> List (Html Msg)) -> ( Maybe Int, Html Msg ) -> Html Msg
scriptView viewer content =
    case content of
        ( Nothing, sub ) ->
            sub

        ( Just id, sub ) ->
            Html.div []
                [ sub
                , [ Inline.Script id [ ( "display", "inline-block" ) ] ]
                    |> viewer
                    |> Html.div [ Attr.class "lia-paragraph" ]
                ]


{-| A quote with a citation as its last paragraph, or an alert
(`> [!NOTE] optional title`).
-}
viewQuote : Config Msg -> Parameters -> Maybe ( Alert, Maybe Inlines ) -> Blocks -> Html Msg
viewQuote config attr alert elements =
    let
        alert_class =
            case alert of
                Just ( type_, _ ) ->
                    "lia-quote lia-quote__alert-" ++ String.toLower (alertName type_)

                Nothing ->
                    "lia-quote"

        alert_title =
            case alert of
                Just ( type_, Nothing ) ->
                    Just
                        [ icon ("icon-alert-" ++ String.toLower (alertName type_)) [ Attr.class "lia-quote__alert-icon" ]
                        , Html.text (alertName type_)
                        ]

                Just ( _, Just title ) ->
                    Just (config.view title)

                Nothing ->
                    Nothing
    in
    case elements of
        [ Paragraph pAttr pElement, Citation cAttr citation ] ->
            [ [ Paragraph pAttr pElement |> view_block config ]
                |> Html.em [ Attr.class "lia-quote__text" ]
            , citation
                |> config.view
                |> (::) (Html.text "―")
                |> Html.cite (annotation "lia-quote__cite" cAttr)
            ]
                |> Html.blockquote
                    (Attr.cite
                        (citation
                            |> stringify_ config.main
                            |> String.trim
                        )
                        :: annotation "lia-quote" attr
                    )

        _ ->
            elements
                |> fold config []
                |> CList.addWhen (alert_title |> Maybe.map (Html.p []))
                |> Html.blockquote (annotation alert_class attr)


alertName : Alert -> String
alertName alert =
    case alert of
        NOTE ->
            "Note"

        TIP ->
            "Tip"

        IMPORTANT ->
            "Important"

        WARNING ->
            "Warning"

        CAUTION ->
            "Caution"


{-| An ASCII drawing, with an optional caption.
-}
view_ascii : Config Msg -> Parameters -> ( Maybe Inlines, SvgBob.Configuration Blocks ) -> Html Msg
view_ascii config attr ( caption, image ) =
    (if List.isEmpty image.foreign then
        -- without embedded Markdown the drawing does not depend on the config
        Lazy.lazy3 drawAscii config.light attr image

     else
        drawAscii_ (svgElement config) config.light attr image
    )
        |> svgFigure config caption


{-| A drawing without embedded Markdown.
-}
drawAscii : Bool -> Parameters -> SvgBob.Configuration Blocks -> Html msg
drawAscii =
    drawAscii_ (\_ -> Html.text "")


{-| Draw the svgbob image, `foreign` renders the embedded Markdown.
-}
drawAscii_ : (Blocks -> Html msg) -> Bool -> Parameters -> SvgBob.Configuration Blocks -> Html msg
drawAscii_ foreign light attr =
    SvgBob.setColorsIn
        (if light then
            { text = "#4b4b4b"
            , background = "white"
            , stroke = "black"
            }

         else
            { text = "white"
            , background = "#323232"
            , stroke = "#ddd"
            }
        )
        >> SvgBob.drawElements (toAttribute attr) foreign


{-| Embedded Markdown within a drawing, a single paragraph is rendered as inlines.
-}
svgElement : Config Msg -> Blocks -> Html Msg
svgElement config list =
    Html.div [] <|
        case list of
            [ Paragraph [] content ] ->
                config.view content

            _ ->
                List.map (view_block config) list


svgFigure : Config Msg -> Maybe Inlines -> Html Msg -> Html Msg
svgFigure config caption svg =
    Html.figure [ Attr.class "lia-figure" ]
        [ Html.div
            [ Attr.class "lia-figure__media" ]
            [ svg ]
        , case caption of
            Nothing ->
                Html.text ""

            Just content ->
                content
                    |> config.view
                    |> Html.figcaption [ Attr.class "lia-figure__caption" ]
        ]


{-| Comments within the solution of a quiz or survey are only shown and read out
loud (slides mode), after the quiz has been solved or the survey submitted.
-}
hideUnsolvedComments :
    { section | body : Blocks, quiz_vector : Quiz.Vector, survey_vector : Survey.Vector, effect_model : Comments.Model a }
    -> Comments.Model a
hideUnsolvedComments section =
    let
        effect_model =
            section.effect_model
    in
    case
        solutions section section.body
            |> List.filter (.solved >> not)
            |> List.concatMap .comments
    of
        [] ->
            effect_model

        hidden ->
            { effect_model
                | comments =
                    effect_model.comments
                        |> Dict.map
                            (\id1 element ->
                                { element
                                    | content =
                                        element.content
                                            |> Array.toIndexedList
                                            |> List.filter (\( id2, _ ) -> not (List.member ( id1, id2 ) hidden))
                                            |> List.map Tuple.second
                                            |> Array.fromList
                                }
                            )
                        |> Dict.filter (\_ element -> not (Array.isEmpty element.content))
            }


{-| A quiz, gap texts and selections within blocks (`Quizzes.maybeConfig`)
render their blocks with the quiz state, drag & drop quizzes also get the
draggable items below.
-}
viewQuiz : Config Msg -> Maybe String -> Parameters -> Quiz.Quiz Block -> Maybe ( Blocks, Int ) -> Html Msg
viewQuiz config labeledBy attr quiz solution =
    case Quizzes.maybeConfig config.main quiz config.section.quiz_vector of
        Just ( main, md, randomize ) ->
            let
                mainConfig =
                    Config.setMain main config
            in
            Html.div []
                [ view_block mainConfig md
                , Inline.viewQuizDrops mainConfig.main
                    |> shuffle randomize
                    |> Html.div
                        [ Attr.style "display" "flex"
                        , Attr.style "flex-wrap" "wrap"
                        , Attr.style "gap" "0.5rem"
                        , Attr.style "align-items" "flex-start"
                        ]
                    |> Html.map Script
                , Inline.viewDragHint mainConfig.main
                , quizControl config labeledBy attr quiz solution
                ]

        Nothing ->
            quizControl config labeledBy attr quiz solution


{-| The quiz with its controls, hints, the solution (once it is visible) and the
script output.
-}
quizControl : Config Msg -> Maybe String -> Parameters -> Quiz.Quiz Block -> Maybe ( Blocks, Int ) -> Html Msg
quizControl config labeledBy attr quiz solution =
    Quizzes.view config.main
        labeledBy
        quiz
        config.section.quiz_vector
        (quizVectorOptions config quiz.quiz)
        (List.map (viewBlocks config) quiz.hints)
        |> Tuple.mapSecond
            (\list ->
                (case solution of
                    Just ( answer, _ ) ->
                        if Quizzes.showSolution quiz config.section.quiz_vector then
                            list ++ [ viewSolution config "quiz" quiz.id answer ]

                        else
                            list

                    Nothing ->
                        list
                )
                    |> Html.div (annotation (Quizzes.class quiz.id config.section.quiz_vector) attr)
            )
        |> scriptView config.view
