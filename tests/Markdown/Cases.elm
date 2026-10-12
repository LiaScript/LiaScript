module Markdown.Cases exposing (suite)

{-| Cases of `Lia.Markdown` that do not occur in the LiaBooks and LiaTemplates
corpora, which are otherwise used as a golden master.
-}

import Array
import Dict
import Expect
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import HtmlSnapshot
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Gallery.Update as GalleryUpdate
import Lia.Markdown.Task.Update as TaskUpdate
import I18n.Translations exposing (Lang(..))
import Lia.Markdown.Code.Sync as CSync
import Lia.Markdown.Config as MConfig
import Lia.Markdown.Update as MU
import Lia.Markdown.View as MView
import Lia.Settings.Types as Settings exposing (Mode(..))
import Lia.Sync.Types as Sync
import Return
import Service.Event as Event
import Lia.Definition.Types exposing (default)
import Lia.Markdown.Inline.Types as Inline
import Lia.Markdown.Quiz.Types as Quiz exposing (Type(..))
import Lia.Markdown.Quiz.Update as QuizUpdate
import Lia.Markdown.Survey.Update as SurveyUpdate
import Lia.Markdown.Table.Update as TableUpdate
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Parser.Parser as Parser
import Lia.Section as Section
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Markdown"
        [ test "a grouped ordered list with inputs becomes one gap-text quiz" <|
            \_ ->
                case parse "<!-- data-group -->\n1. a [[x]]\n2. b [[y]]\n" of
                    Ok [ Quiz _ { quiz } Nothing ] ->
                        case quiz of
                            Multi_Type { elements } ->
                                case elements of
                                    [ OrderedList _ [ _, _ ] ] ->
                                        Expect.pass

                                    _ ->
                                        Expect.fail (Debug.toString elements)

                            _ ->
                                Expect.fail (Debug.toString quiz)

                    result ->
                        Expect.fail (Debug.toString result)
        , test "a grouped bullet list with inputs becomes one gap-text quiz" <|
            \_ ->
                case parse "<!-- data-group -->\n- a [[x]]\n- b [[y]]\n" of
                    Ok [ Quiz _ { quiz } Nothing ] ->
                        case quiz of
                            Multi_Type { elements } ->
                                case elements of
                                    [ BulletList _ [ _, _ ] ] ->
                                        Expect.pass

                                    _ ->
                                        Expect.fail (Debug.toString elements)

                            _ ->
                                Expect.fail (Debug.toString quiz)

                    result ->
                        Expect.fail (Debug.toString result)
        , test "a gallery with an input in an alt text becomes a gap-text quiz" <|
            \_ ->
                case parse "![a [[x]]](a.png)\n![b](b.png)\n" of
                    Ok [ Quiz _ { quiz } Nothing ] ->
                        case quiz of
                            Multi_Type { elements } ->
                                case elements of
                                    [ Gallery _ { media } ] ->
                                        Expect.equal 2 (List.length media)

                                    _ ->
                                        Expect.fail (Debug.toString elements)

                            _ ->
                                Expect.fail (Debug.toString quiz)

                    result ->
                        Expect.fail (Debug.toString result)
        , test "up to 8 backticks a drawing has to be closed by the same number" <|
            \_ ->
                parse "````ascii\n+--+\n``````\n"
                    |> Result.map (List.any isASCII)
                    |> Expect.equal (Ok False)
        , test "the indentation of a drawing within a list is removed" <|
            \_ ->
                case parse "- item\n\n  ```ascii\n  +--+\n  | |\n  ```\n" of
                    Ok [ BulletList _ [ [ Paragraph _ _, ASCII _ ( _, drawing ) ] ] ] ->
                        Expect.equal ( 4, 2 ) ( drawing.columns, drawing.rows )

                    result ->
                        Expect.fail (Debug.toString result)
        , test "a macro within the first line of a paragraph can create a setext header" <|
            \_ ->
                parse "<!--\n@under\nx\n===\n@end\n-->\nTitle @under\n"
                    |> Expect.equal (Ok [ Header [] ( 1, [ Inline.Chars "Title x" [] ] ) ])
        , test "only the scripts within a solution are run, when the solution gets visible" <|
            \_ ->
                "<script>0</script>\n\n[(X)] a\n[( )] b\n*****\n<script>1</script>\n*****\n"
                    |> section
                    |> Result.map (.effect_model >> .javascript >> Array.toList >> List.map .solution)
                    |> Expect.equal (Ok [ Nothing, Just "lia-tts-quiz-0" ])
        , test "annotations get the base url of the course" <|
            \_ ->
                parseWith "http://base.url/" "<!-- src=\"pic.jpg\" -->\ntext\n"
                    |> Expect.equal (Ok [ Paragraph [ ( "src", "http://base.url/pic.jpg" ) ] [ Inline.Chars "text" [] ] ])
        , test "a horizontal line can end with spaces" <|
            \_ ->
                parse "---   \ntext\n"
                    |> Expect.equal (Ok [ HLine [], Paragraph [] [ Inline.Chars "text" [] ] ])
        , test "a quiz input that spans two lines can be part of a setext header" <|
            \_ ->
                case parse "a [[x\ny]]\n===\n" of
                    Ok [ Quiz _ { quiz } Nothing ] ->
                        case quiz of
                            Multi_Type { elements } ->
                                case elements of
                                    [ Header _ ( 1, _ ) ] ->
                                        Expect.pass

                                    _ ->
                                        Expect.fail (Debug.toString elements)

                            _ ->
                                Expect.fail (Debug.toString quiz)

                    result ->
                        Expect.fail (Debug.toString result)
        , test "a script within a nested solution belongs to the inner solution" <|
            \_ ->
                "[(X)] a\n[( )] b\n*****\n[(X)] c\n[( )] d\n****\n<script>1</script>\n****\n*****\n"
                    |> section
                    |> Result.map (.effect_model >> .javascript >> Array.toList >> List.map .solution)
                    |> Expect.equal (Ok [ Just "lia-tts-quiz-1" ])
        , test "a footnote can contain multiple blocks" <|
            \_ ->
                "text[^1]\n\n[^1]: one\n    two\n\n    three\n"
                    |> section
                    |> Result.map (.footnotes >> Dict.toList)
                    |> Expect.equal
                        (Ok
                            [ ( "1"
                              , [ Paragraph [] [ Inline.Chars "one two" [] ]
                                , Paragraph [] [ Inline.Chars "three" [] ]
                                ]
                              )
                            ]
                        )
        , test "an annotation macro can be indented" <|
            \_ ->
                parse "<!--\n@cls\n<!-- class=\"x\" -->\n@end\n-->\n  @cls\ntext\n"
                    |> Expect.equal (Ok [ Paragraph [ ( "class", "x" ) ] [ Inline.Chars "text" [] ] ])
        , test "tasks with a script execute it" <|
            \_ ->
                events "- [ ] a\n- [X] b\n<script>@input</script>\n" (MU.UpdateTask (TaskUpdate.Toggle 0 0))
                    |> Expect.equal
                        [ "{\"reply\":true,\"track\":[[\"task\",0]],\"service\":\"db\",\"message\":{\"cmd\":\"store\",\"param\":{\"table\":\"task\",\"id\":0,\"data\":[[true,true]]}}}"
                        , "{\"reply\":true,\"track\":[[\"task\",0],[\"eval\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"eval\",\"param\":\"[true,true]\"}}"
                        ]
        , test "tasks pass the messages of scripts within them" <|
            \_ ->
                events "<script>1</script>\n\n- [ ] a\n" (MU.UpdateTask (TaskUpdate.Script (Script.Click 0)))
                    |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":0,\"code\":\"1\",\"worker\":false}}}" ]
        , test "galleries pass the messages of scripts in their captions" <|
            \_ ->
                events "<script>1</script>\n\n![a](a.png)\n![b](b.png)\n" (MU.UpdateGallery (GalleryUpdate.Script (Script.Click 0)))
                    |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":0,\"code\":\"1\",\"worker\":false}}}" ]
        , test "unclosed tags are parsed in linear time" <|
            \_ ->
                List.range 0 25
                    |> List.map (\i -> "[<t" ++ String.fromInt i ++ ">] ")
                    |> String.concat
                    |> (\line -> parse (line ++ "\n"))
                    |> Result.map List.length
                    |> Expect.equal (Ok 1)
        , test "footnotes are shown and hidden" <|
            \_ ->
                case section "text[^1]\n\n[^1]: note\n" of
                    Ok s ->
                        let
                            shown =
                                (MU.update (Sync.init []) (default "" "") (MU.FootnoteShow "1") s).value
                        in
                        ( shown.footnote2show, (MU.update (Sync.init []) (default "" "") MU.FootnoteHide shown).value.footnote2show )
                            |> Expect.equal ( Just "1", Nothing )

                    Err e ->
                        Expect.fail e
        , test "surveys are stored with the id of the section" <|
            \_ ->
                case section "[[___]]\n" of
                    Ok s ->
                        MU.update (Sync.init []) (default "" "") (MU.UpdateSurvey (SurveyUpdate.TextUpdate 0 "x")) s
                            |> .value
                            |> MU.update (Sync.init []) (default "" "") (MU.UpdateSurvey (SurveyUpdate.Submit 0))
                            |> encodeEvents
                            |> Expect.equal
                                [ "{\"reply\":true,\"track\":[[\"survey\",0]],\"service\":\"db\",\"message\":{\"cmd\":\"store\",\"param\":{\"table\":\"survey\",\"id\":0,\"data\":[{\"submitted\":true,\"state\":{\"Text\":\"x\"}}]}}}"
                                , "{\"reply\":false,\"track\":[[\"survey\",0]],\"service\":\"slide\",\"message\":{\"cmd\":\"scroll_into_view\",\"param\":{\"id\":\"lia-survey-solution-0\",\"delay\":0,\"block\":\"nearest\"}}}"
                                , "{\"reply\":false,\"track\":[[\"survey\",0]],\"service\":\"slide\",\"message\":{\"cmd\":\"scroll_into_view\",\"param\":{\"id\":\"lia-survey-feedback-0\",\"delay\":0,\"block\":\"nearest\"}}}"
                                ]

                    Err e ->
                        Expect.fail e
        , test "surveys pass the messages of scripts within them" <|
            \_ ->
                events "<script>1</script>\n\n[[ ]] a\n[[ ]] b\n" (MU.UpdateSurvey (SurveyUpdate.Script (Script.Click 0)))
                    |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":0,\"code\":\"1\",\"worker\":false}}}" ]
        , describe "solutions"
            [ test "a solution that gets visible runs its visible scripts and reads its comments" <|
                \_ ->
                    reveal { sound = True, runAll = False } []
                        |> Expect.equal
                            [ "{\"reply\":true,\"track\":[[\"settings\",0]],\"service\":\"tts\",\"message\":{\"cmd\":\"read\",\"param\":\"lia-tts-quiz-0\"}}"
                            , "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":100,\"code\":\"1\",\"worker\":false}}}"
                            ]
            , test "a solution that was visible before is ignored" <|
                \_ ->
                    reveal { sound = True, runAll = False } [ "lia-tts-quiz-0" ]
                        |> Expect.equal []
            , test "a solution can run all of its scripts" <|
                \_ ->
                    reveal { sound = False, runAll = True } []
                        |> Expect.equal
                            [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":100,\"code\":\"1\",\"worker\":false}}}"
                            , "{\"reply\":true,\"track\":[[\"effect\",0],[\"script\",1]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":100,\"code\":\"2\",\"worker\":false}}}"
                            ]
            , test "comments within unsolved solutions are hidden" <|
                \_ ->
                    "--{{1}}--\nvisible\n\n[(X)] a\n[( )] b\n*****\n--{{2}}--\nhidden\n*****\n"
                        |> section
                        |> Result.map (MView.hideUnsolvedComments >> .comments >> Dict.keys)
                        |> Expect.equal (Ok [ 1 ])
            ]
        , describe "narrator comments"
            [ test "a translated course has no recordings" <|
                \_ ->
                    MView.addTranslation { hidden = True, translations = Just { old = "de", new = "en", name = Just "English" }, id = 2, narrator = "unknown", audio = Array.fromList [ "a.mp3" ] }
                        |> Expect.equal [ ( "aria-hidden", "true" ), ( "class", "translate hidden-visually" ), ( "class", "lia-tts-2" ), ( "data-voice", "unknown" ), ( "data-lang", "en" ), ( "translate", "yes" ), ( "data-translated", "no" ) ]
            , test "an untranslated course has the recordings of a comment" <|
                \_ ->
                    MView.addTranslation { hidden = False, translations = Just { old = "en", new = "en", name = Just "English" }, id = 2, narrator = "unknown", audio = Array.fromList [ "a.mp3", "b.mp3" ] }
                        |> Expect.equal [ ( "data-file", "a.mp3,b.mp3" ), ( "class", "translate" ), ( "class", "lia-tts-2" ), ( "data-voice", "unknown" ), ( "data-lang", "en" ), ( "translate", "yes" ), ( "data-translated", "no" ) ]
            ]
        , describe "config"
            [ test "section formulas are merged into the global ones, global ones win" <|
                \_ ->
                    case section "text\n" of
                        Ok s ->
                            { s | definition = Just (default "" "" |> (\d -> { d | formulas = Dict.fromList [ ( "\\a", "section" ), ( "\\b", "section" ) ] })) }
                                |> config (Just (Dict.fromList [ ( "\\a", "global" ) ])) identity
                                |> .main
                                |> .formulas
                                |> Dict.toList
                                |> Expect.equal [ ( "\\a", "global" ), ( "\\b", "section" ) ]

                        Err e ->
                            Expect.fail e
            , test "tooltips are only shown on wide screens, the table of contents takes some space" <|
                \_ ->
                    case section "text\n" of
                        Ok s ->
                            [ config Nothing (\st -> { st | tooltips = True }) s
                            , config Nothing (\st -> { st | tooltips = True, table_of_contents = False }) s
                            , configWith 300 Nothing (\st -> { st | tooltips = True }) s
                            ]
                                |> List.map (\c -> ( c.main.tooltips, c.screen.width, c.main.theme ))
                                |> Expect.equal [ ( True, 740, Just "dreamweaver" ), ( True, 1000, Just "dreamweaver" ), ( False, 40, Just "dreamweaver" ) ]

                        Err e ->
                            Expect.fail e
            ]
        , describe "views"
            [ test "a quote with a citation keeps its annotations" <|
                \_ ->
                    section "<!-- class=\"q\" -->\n> text\n>\n> – cite\n"
                        |> Result.map (render Textbook >> String.contains "class=\"lia-quote q\"")
                        |> Expect.equal (Ok True)
            , test "the recordings of a comment are passed to the narrator" <|
                \_ ->
                    section "--{{0}}--\n?[a](a.mp3) narrated\n"
                        |> Result.map (render Presentation >> String.contains "data-file=\"a.mp3\"")
                        |> Expect.equal (Ok True)
            , test "the solution of a survey is shown after it has been submitted" <|
                \_ ->
                    case section "[[___]]\n***\nsolution\n***\n" of
                        Ok s ->
                            [ s
                            , MU.update (Sync.init []) (default "" "") (MU.UpdateSurvey (SurveyUpdate.TextUpdate 0 "x")) s
                                |> .value
                                |> MU.update (Sync.init []) (default "" "") (MU.UpdateSurvey (SurveyUpdate.Submit 0))
                                |> .value
                            ]
                                |> List.map (render Textbook >> String.contains "lia-survey-solution-0")
                                |> Expect.equal [ False, True ]

                        Err e ->
                            Expect.fail e
            , test "a survey within a sub-section uses its own state" <|
                \_ ->
                    withSub "[(1)] a\n[(2)] b\n"
                        |> Result.map (render Textbook >> String.contains "title=\"Submit\"")
                        |> Expect.equal (Ok True)
            , test "a submitted survey within a sub-section is shown as submitted" <|
                \_ ->
                    withSub "[[___]]\n"
                        |> Result.map
                            (\s ->
                                ( render Textbook s
                                , s
                                    |> MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 (MU.UpdateSurvey (SurveyUpdate.TextUpdate 0 "x"))))
                                    |> .value
                                    |> MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 (MU.UpdateSurvey (SurveyUpdate.Submit 0))))
                                    |> .value
                                    |> render Textbook
                                )
                            )
                        |> Result.map (\( before, after ) -> before == after)
                        |> Expect.equal (Ok False)
            , test "code blocks show the classroom versions of their own section" <|
                \_ ->
                    case Section.init 99 7 { indentation = 1, title = [], code = "```js\nx\n```\n<script>@input</script>\n" } |> Parser.parse_section identity (default "" "") of
                        Ok s ->
                            let
                                sync =
                                    Sync.init []

                                data =
                                    sync.data

                                classroom =
                                    { sync | state = Sync.Connected "me", data = { data | code = Dict.singleton 7 (Array.map CSync.sync s.code_model.evaluate) } }
                            in
                            renderSync classroom s
                                |> Expect.notEqual (renderSync { classroom | data = data } s)

                        Err e ->
                            Expect.fail e
            , test "a gallery within a sub-section uses its own state" <|
                \_ ->
                    withSub "![a](a.png)\n![b](b.png)\n"
                        |> Result.map
                            (\s ->
                                MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 (MU.UpdateGallery (GalleryUpdate.Show 0 1)))) s
                                    |> .value
                                    |> render Textbook
                                    |> String.indexes "src=\"b.png\""
                                    |> List.length
                            )
                        |> Expect.equal (Ok 2)
            ]
        , describe "LiaScript results within LiaScript results"
            [ test "scripts of results are run and their results are shown, at any depth" <|
                \_ ->
                    nestedCourse
                        |> Result.map (render Textbook >> (\html -> List.map (\text -> String.contains text html) [ "Level one", "Level two", "deep" ]))
                        |> Expect.equal (Ok [ True, True, True ])
            , test "a quiz within a result within a result is checked by its own script" <|
                \_ ->
                    case nestedCourse |> Result.andThen typeX of
                        Ok s ->
                            case nestedSub [ 0, 0 ] s |> Maybe.andThen (subQuiz (\quiz -> QuizUpdate.Check quiz.id quiz.quiz)) of
                                Just msg ->
                                    MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 0 (MU.Script (Script.Sub 0 msg)))) s
                                        |> (\r -> settle 20 r.events r.value)
                                        |> nestedSub [ 0, 0 ]
                                        |> Maybe.map
                                            (\sub ->
                                                case sub of
                                                    Section.SubSection { quiz_vector } ->
                                                        quiz_vector |> Array.toList |> List.map (.solved >> Debug.toString)

                                                    Section.SubSubSection _ ->
                                                        []
                                            )
                                        |> Expect.equal (Just [ "Solved" ])

                                Nothing ->
                                    Expect.fail "no nested quiz"

                        Err e ->
                            Expect.fail e
            ]
        , describe "LiaScript results of scripts (sub-sections)"
            [ test "quiz events are tracked with the id of the script" <|
                \_ ->
                    subEvents "[[x]]\n" (subQuiz (\quiz -> QuizUpdate.Check quiz.id quiz.quiz))
                        |> Expect.equal
                            [ "{\"reply\":false,\"track\":[[\"effect\",0],[\"sub\",1],[\"quiz\",1]],\"service\":\"slide\",\"message\":{\"cmd\":\"scroll_into_view\",\"param\":{\"id\":\"lia-quiz-solution-0\",\"delay\":0,\"block\":\"nearest\"}}}"
                            , "{\"reply\":false,\"track\":[[\"effect\",0],[\"sub\",1],[\"quiz\",1]],\"service\":\"slide\",\"message\":{\"cmd\":\"scroll_into_view\",\"param\":{\"id\":\"lia-quiz-feedback-0\",\"delay\":0,\"block\":\"nearest\"}}}"
                            ]
            , test "tasks within a sub-section are checked by their own scripts" <|
                \_ ->
                    subEvents "- [ ] a\n<script>@input</script>\n" (\_ -> Just (MU.UpdateTask (TaskUpdate.Toggle 0 0)))
                        |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"sub\",1],[\"task\",1],[\"eval\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"eval\",\"param\":\"[true]\"}}" ]
            , test "the scripts of a sub-section are started, when it is created" <|
                \_ ->
                    startEvents "<script>2</script>\n\ntext\n"
                        |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"sub\",1],[\"effect\",1],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":100,\"code\":\"2\",\"worker\":false}}}" ]
            , test "the scripts of a sub-sub-section are started, when it is created" <|
                \_ ->
                    startEvents "text <script>2</script>\n"
                        |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"sub\",1],[\"effect\",1],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":100,\"code\":\"2\",\"worker\":false}}}" ]
            , test "the result of a script within a sub-section is shown" <|
                \_ ->
                    case withSubReturn "<script>2</script>\n\ntext\n" of
                        Ok clicked ->
                            let

                                -- JavaScript replies with the same track, the section is popped by Lia.Update
                                reply =
                                    clicked.events
                                        |> List.head
                                        |> Maybe.andThen (Event.popWithId >> Maybe.map (\( _, _, e ) -> e))
                                        |> Maybe.map
                                            (\e ->
                                                { e
                                                    | message =
                                                        { cmd = "exec"
                                                        , param = JE.object [ ( "ok", JE.bool True ), ( "result", JE.string "forty-two" ), ( "details", JE.list identity [] ) ]
                                                        }
                                                }
                                            )
                            in
                            case reply of
                                Just event ->
                                    MU.handle (Sync.init []) (default "" "") "effect" event clicked.value
                                        |> .value
                                        |> render Textbook
                                        |> String.contains "forty-two"
                                        |> Expect.equal True

                                Nothing ->
                                    Expect.fail "no event"

                        Err e ->
                            Expect.fail e
            , test "a script message of a quiz within a sub-section is applied once" <|
                \_ ->
                    -- the script started with the sub-section has to finish first
                    case withSubReturn "[( )] <script>7</script>\n[(X)] b\n" |> Result.map (\r -> settleWith (\_ -> Just "done") 5 r.events r.value) of
                        Ok s ->
                            MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 (MU.UpdateQuiz (QuizUpdate.Script (Script.Click 0))))) s
                                |> encodeEvents
                                |> Expect.equal [ "{\"reply\":true,\"track\":[[\"effect\",0],[\"sub\",1],[\"effect\",1],[\"script\",0]],\"service\":\"script\",\"message\":{\"cmd\":\"exec\",\"param\":{\"delay\":0,\"code\":\"7\",\"worker\":false}}}" ]

                        Err e ->
                            Expect.fail e
            , test "a gallery within a sub-section opens its media" <|
                \_ ->
                    case withSub "![a](a.png)\n![b](b.png)\n" of
                        Ok s ->
                            MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 (MU.UpdateGallery (GalleryUpdate.Show 0 1)))) s
                                |> .value
                                |> subSection
                                |> Maybe.map
                                    (\sub ->
                                        case sub of
                                            Section.SubSection { gallery_vector } ->
                                                Array.toList gallery_vector

                                            Section.SubSubSection _ ->
                                                []
                                    )
                                |> Expect.equal (Just [ 1 ])

                        Err e ->
                            Expect.fail e
            ]
        , describe "script bodies"
            (List.map
                (\( code, expected ) ->
                    test ("<script>" ++ code) <|
                        \_ ->
                            section ("<script>" ++ code ++ "\n")
                                |> Result.map (.effect_model >> .javascript >> Array.toList >> List.map .script)
                                |> Expect.equal (Ok expected)
                )
                [ -- unclosed strings used to backtrack exponentially (this took minutes)
                  ( "`abcdefghijklmnopqrstuvwxyz0123456789-1. \n(<lia-keep>", [] )
                , ( "'abcdefghijklmnopqrstuvwxyz0123456789-1. \n(<lia-keep>", [] )
                , ( "let s = '</script>'; 1</script>", [ "let s = '</script>'; 1" ] )
                , ( "let s = \"</script>\"; 1</script>", [ "let s = \"</script>\"; 1" ] )
                , ( "`a\\`</script>` + 1</script>", [ "`a\\`</script>` + 1" ] )

                -- a backslash escapes the next character, also a backslash
                , ( "let s = '\\\\'; 1</script>", [ "let s = '\\\\'; 1" ] )
                , ( "let s = \"\\\\\"; 1</script>", [ "let s = \"\\\\\"; 1" ] )
                , ( "`\\\\\\`</script>`</script>", [ "`\\\\\\`</script>`" ] )
                , ( "`\\\\`; 1</script>", [ "`\\\\`; 1" ] )

                -- strings end at the end of the line, also after a backslash
                , ( "let s = 'a\\\n</script>", [ "let s = 'a\\" ] )

                -- only </script> ends the code, other closing tags belong to it
                , ( "s.replace(/</g, '&lt;')</script>", [ "s.replace(/</g, '&lt;')" ] )
                , ( "// see </div>\nx = 1</script>", [ "// see </div>\nx = 1" ] )
                , ( "x = `<ul>${xs.map(x => `<li>${x}</li>`).join('')}</ul>`</script>", [ "x = `<ul>${xs.map(x => `<li>${x}</li>`).join('')}</ul>`" ] )
                , ( "x = `${ { a: '`' }.a }`</script>", [ "x = `${ { a: '`' }.a }`" ] )

                -- quotes in regular expressions, a / after a value is a division
                , ( "x = /'/.test(s); y = '</script>'</script>", [ "x = /'/.test(s); y = '</script>'" ] )
                , ( "x = s.split(/\"/)</script>", [ "x = s.split(/\"/)" ] )
                , ( "x = a / 2; s = \"a/b\"</script>", [ "x = a / 2; s = \"a/b\"" ] )
                , ( "x = (a) / 2 / '</script>'</script>", [ "x = (a) / 2 / '</script>'" ] )
                , ( "x = { k: 1 } / 2 / '</script>'</script>", [ "x = { k: 1 } / 2 / '</script>'" ] )
                , ( "if (a) { b }\n/'/.test(s)</script>", [ "if (a) { b }\n/'/.test(s)" ] )
                , ( "return /[/']/</script>", [ "return /[/']/" ] )

                -- but a line comment ends at </script>, as in HTML
                , ( "x = 1 // one</script>", [ "x = 1 // one" ] )
                , ( "x = 1 <!-- one</script>", [ "x = 1 <!-- one" ] )
                , ( "/* </script> */</script>", [ "/* </script> */" ] )
                ]
            )
        ]


{-| The events of revealing the solution of a resolved quiz, whose solution
contains a visible and a hidden script and a comment.
-}
reveal : { sound : Bool, runAll : Bool } -> List String -> List String
reveal flags before =
    case section "[(X)] a\n[( )] b\n*****\n<script>1</script>\n\n    {{1}}\n<script>2</script>\n\n--{{0}}--\nnarrated\n*****\n" of
        Ok s ->
            case s.body of
                (Quiz _ quiz _) :: _ ->
                    MU.update (Sync.init []) (default "" "") (MU.UpdateQuiz (QuizUpdate.ShowSolution quiz.id quiz.quiz)) s
                        |> (\r -> { r | events = [] })
                        |> MU.revealSolutions flags before
                        |> encodeEvents

                _ ->
                    [ "no quiz" ]

        Err e ->
            [ e ]


config : Maybe (Dict.Dict String String) -> (Settings.Settings -> Settings.Settings) -> Section.Section -> MConfig.Config MU.Msg
config =
    configWith 1000


configWith : Int -> Maybe (Dict.Dict String String) -> (Settings.Settings -> Settings.Settings) -> Section.Section -> MConfig.Config MU.Msg
configWith width formulas settings s =
    MConfig.init En
        { old = "en", new = "en", name = Nothing }
        (settings (Settings.init Nothing False Textbook))
        (Sync.init [])
        { width = width, height = 800 }
        s.id
        formulas
        Dict.empty
        s


renderSync : Sync.Settings -> Section.Section -> String
renderSync sync s =
    MConfig.init En
        { old = "en", new = "en", name = Nothing }
        (Settings.init Nothing False Textbook)
        sync
        { width = 1000, height = 800 }
        s.id
        Nothing
        Dict.empty
        s
        |> MView.view False True
        |> HtmlSnapshot.toString


render : Mode -> Section.Section -> String
render mode s =
    MConfig.init En
        { old = "en", new = "en", name = Nothing }
        (Settings.init Nothing False mode)
        (Sync.init [])
        { width = 1000, height = 800 }
        s.id
        Nothing
        Dict.empty
        s
        |> MView.view False True
        |> HtmlSnapshot.toString


{-| A course whose script returns LiaScript with a script, which returns
LiaScript with a quiz (checked by a script) and a script that returns text.
-}
nestedCourse : Result String Section.Section
nestedCourse =
    section "<script>0</script>\n"
        |> Result.map
            (\s ->
                MU.update (Sync.init []) (default "" "") (MU.Script (Script.Click 0)) s
                    |> (\r -> settle 20 r.events r.value)
            )


{-| Type `x` into the (only) input of the rendered section, the message takes
its way through all LiaScript results.
-}
typeX : Section.Section -> Result String Section.Section
typeX s =
    MConfig.init En { old = "en", new = "en", name = Nothing } (Settings.init Nothing False Textbook) (Sync.init []) { width = 1000, height = 800 } s.id Nothing Dict.empty s
        |> MView.view False True
        |> Query.fromHtml
        |> Query.find [ Selector.tag "input" ]
        |> HE.simulate (HE.input "x")
        |> HE.toResult
        |> Result.map (\msg -> (MU.update (Sync.init []) (default "" "") msg s).value)


{-| Plays JavaScript: every `exec` and `eval` of a script is answered, until no
event is left. As in `Lia.Update` the first point of the track selects the
section, its topic is passed to `Markdown.handle`.
-}
settle : Int -> List Event.Event -> Section.Section -> Section.Section
settle =
    settleWith answer


settleWith : (Event.Event -> Maybe String) -> Int -> List Event.Event -> Section.Section -> Section.Section
settleWith reply rounds pending s =
    if rounds == 0 then
        s

    else
        case pending of
            [] ->
                s

            event :: rest ->
                case ( Event.popWithId event, event.service, reply event ) of
                    ( Just ( topic, _, inner ), "script", Just result ) ->
                        let
                            r =
                                MU.handle (Sync.init [])
                                    (default "" "")
                                    topic
                                    { inner | message = { cmd = event.message.cmd, param = JE.object [ ( "ok", JE.bool True ), ( "result", JE.string result ), ( "details", JE.list identity [] ) ] } }
                                    s
                        in
                        settleWith reply (rounds - 1) (rest ++ r.events) r.value

                    _ ->
                        settleWith reply rounds rest s


answer : Event.Event -> Maybe String
answer event =
    case ( event.message.cmd, JD.decodeValue (JD.oneOf [ JD.field "code" JD.string, JD.string ]) event.message.param ) of
        ( "exec", Ok "0" ) ->
            Just "LIASCRIPT:Level one\n\n<script>1</script>\n"

        ( "exec", Ok "1" ) ->
            Just "LIASCRIPT:Level two\n\n[[x]]\n<script>\"@input\" == \"x\"</script>\n\n<script>2</script>\n"

        ( "exec", Ok "2" ) ->
            Just "deep"

        ( "eval", Ok code ) ->
            Just
                (if code == "\"x\" == \"x\"" then
                    "true"

                 else
                    "false"
                )

        _ ->
            Nothing


{-| The sub-section that is the result of script `id`, `ids` from the section
down.
-}
nestedSub : List Int -> Section.Section -> Maybe Section.SubSection
nestedSub ids s =
    let
        result id javascript =
            case javascript |> Array.get id |> Maybe.andThen .result of
                Just (Script.IFrame sub) ->
                    Just sub

                _ ->
                    Nothing

        scriptsOf sub =
            case sub of
                Section.SubSection x ->
                    x.effect_model.javascript

                Section.SubSubSection x ->
                    x.effect_model.javascript
    in
    case ids of
        id :: rest ->
            List.foldl (\i -> Maybe.andThen (scriptsOf >> result i)) (result id s.effect_model.javascript) rest

        [] ->
            Nothing


{-| A section with two scripts, the second one returned LiaScript `code`.
-}
withSub : String -> Result String Section.Section
withSub =
    withSubReturn >> Result.map .value


withSubReturn : String -> Result String (Return.Return Section.Section MU.Msg MU.Msg)
withSubReturn code =
    section "<script>0</script>\n\n<script>1</script>\n"
        |> Result.map
            (MU.handle (Sync.init [])
                (default "" "")
                "effect"
                (Event.init "script"
                    { cmd = "exec"
                    , param = JE.object [ ( "ok", JE.bool True ), ( "result", JE.string ("LIASCRIPT:" ++ code) ), ( "details", JE.list identity [] ) ]
                    }
                    |> Event.pushWithId "script" 1
                )
            )


{-| The events of creating a sub-section.
-}
startEvents : String -> List String
startEvents =
    withSubReturn >> Result.map encodeEvents >> Result.withDefault []


{-| The sub-section of the second script.
-}
subSection : Section.Section -> Maybe Section.SubSection
subSection s =
    case s.effect_model.javascript |> Array.get 1 |> Maybe.andThen .result of
        Just (Script.IFrame sub) ->
            Just sub

        _ ->
            Nothing


{-| The events of a message for the sub-section, `toMsg` gets the sub-section.
-}
subEvents : String -> (Section.SubSection -> Maybe MU.Msg) -> List String
subEvents code toMsg =
    case withSub code of
        Ok s ->
            case subSection s |> Maybe.andThen toMsg of
                Just msg ->
                    MU.update (Sync.init []) (default "" "") (MU.Script (Script.Sub 1 msg)) s
                        |> encodeEvents

                Nothing ->
                    [ "no sub-section or message" ]

        Err e ->
            [ e ]


{-| A message for the first quiz of a sub-section.
-}
subQuiz : (Quiz.Quiz Block -> QuizUpdate.Msg MU.Msg) -> Section.SubSection -> Maybe MU.Msg
subQuiz toMsg sub =
    case sub of
        Section.SubSection { body } ->
            List.filterMap
                (\block ->
                    case block of
                        Quiz _ quiz _ ->
                            Just (MU.UpdateQuiz (toMsg quiz))

                        _ ->
                            Nothing
                )
                body
                |> List.head

        Section.SubSubSection _ ->
            Nothing


{-| The events of a message for the parsed section, encoded as JSON.
-}
events : String -> MU.Msg -> List String
events code msg =
    case section code of
        Ok s ->
            MU.update (Sync.init []) (default "" "") msg s
                |> encodeEvents

        Err e ->
            [ e ]


encodeEvents : { r | events : List Event.Event } -> List String
encodeEvents =
    .events >> List.map (Event.encode >> JE.encode 0)


parseWith : String -> String -> Result String Blocks
parseWith base code =
    Section.init 99 0 { indentation = 1, title = [], code = code }
        |> Parser.parse_section identity (default base "")
        |> Result.map .body


section : String -> Result String Section.Section
section code =
    Section.init 99 0 { indentation = 1, title = [], code = code }
        |> Parser.parse_section identity (default "" "")


parse : String -> Result String Blocks
parse =
    section >> Result.map .body


isASCII : Block -> Bool
isASCII block =
    case block of
        ASCII _ _ ->
            True

        _ ->
            False
