module Lia.Json.Meta exposing (encode, slide)

{-| Describes every quiz, survey, task list and code project of a course in
plain text: the question in front of it, its options and, for quizzes, the
solution. The SCORM "suspend" connectors use it to report readable answers to
an LMS (see `src/typescript/connectors/SCORMSuspend/meta.ts` for the format).

The entries of a slide are stored at the id of their state, so `quiz[i]`
describes `quiz_vector[i]`, and every list has the length of its vector.
Elements that cannot be found in the body (e.g. created by scripts) are
marked as `unknown`.

-}

import Array
import Dict exposing (Dict)
import Json.Encode as JE
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Stringify exposing (stringify, stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Quiz.Vector.Types as Vector
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Task.Types as Task
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Model exposing (Model)
import Lia.Section exposing (Section)


{-| The meta data of all (parsed) sections.
-}
encode : Model -> JE.Value
encode lia =
    JE.object
        [ ( "version", JE.int 1 )
        , ( "lang", JE.string lia.definition.language )
        , ( "slides", JE.array slide lia.sections )
        ]


type alias Found =
    { quiz : Dict Int JE.Value
    , survey : Dict Int JE.Value
    , task : Dict Int JE.Value
    , code : Dict Int JE.Value
    }


{-| The meta data of one section.
-}
slide : Section -> JE.Value
slide section =
    let
        found =
            collect section Nothing section.body (Found Dict.empty Dict.empty Dict.empty Dict.empty)

        vector length dict =
            List.range 0 (length - 1)
                |> JE.list
                    (\i ->
                        dict
                            |> Dict.get i
                            |> Maybe.withDefault unknown
                    )
    in
    JE.object
        [ ( "title", JE.string (clean (stringify section.title)) )
        , ( "quiz", vector (Array.length section.quiz_vector) found.quiz )
        , ( "survey", vector (Array.length section.survey_vector) found.survey )
        , ( "task", vector (Array.length section.task_vector) found.task )
        , ( "code", vector (Array.length section.code_model.evaluate) found.code )
        ]


unknown : JE.Value
unknown =
    JE.object
        [ ( "question", JE.string "" )
        , ( "unknown", JE.bool True )
        ]


{-| Walks the blocks in order, remembering the text of the block in front,
which is the question of a quiz (as `Lia.Markdown.View` labels it).
-}
collect : Section -> Maybe String -> Blocks -> Found -> Found
collect section previous blocks found =
    case blocks of
        [] ->
            found

        block :: rest ->
            collect section (label block) rest (visit section (Maybe.withDefault "" previous) block found)


{-| The text of a block that can be the question of the next one.
-}
label : Block -> Maybe String
label block =
    case block of
        Paragraph _ inlines ->
            Just (stringify inlines)

        HTML _ _ ->
            Just (text stringify [ block ])

        Effect _ effect ->
            case effect.content of
                [ inner ] ->
                    label inner

                _ ->
                    Nothing

        _ ->
            Nothing


visit : Section -> String -> Block -> Found -> Found
visit section question block found =
    case block of
        Quiz _ quiz _ ->
            { found | quiz = Dict.insert quiz.id (quizMeta section question quiz) found.quiz }

        Survey _ survey ->
            { found | survey = Dict.insert survey.id (surveyMeta question survey) found.survey }

        Task _ task ->
            { found | task = Dict.insert task.id (taskMeta question task) found.task }

        Code (Code.Evaluate i) ->
            { found | code = Dict.insert i (codeMeta section question i) found.code }

        Quote _ _ blocks ->
            collect section Nothing blocks found

        BulletList _ items ->
            List.foldl (\blocks -> collect section Nothing blocks) found items

        OrderedList _ items ->
            List.foldl (\( _, blocks ) -> collect section Nothing blocks) found items

        Effect _ effect ->
            collect section (Just question) effect.content found

        HTML _ (HTML.Node _ _ blocks) ->
            collect section Nothing blocks found

        HTML _ (HTML.SvgNode _ _ list) ->
            List.foldl (\( _, blocks ) -> collect section Nothing blocks) found list

        _ ->
            found



-- QUIZZES


quizMeta : Section -> String -> Quiz.Quiz Block -> JE.Value
quizMeta section question quiz =
    let
        scripted =
            section.quiz_vector
                |> Array.get quiz.id
                |> Maybe.andThen .scriptID
                |> (/=) Nothing

        -- a script decides, the solution in the Markdown may not be the one
        solution encoder value =
            if scripted then
                JE.null

            else
                encoder value

        base type_ q fields =
            JE.object
                (( "type", JE.string type_ )
                    :: ( "question", JE.string (clean q) )
                    :: fields
                    ++ (if scripted then
                            [ ( "script", JE.bool True ) ]

                        else
                            []
                       )
                )
    in
    case quiz.quiz of
        Quiz.Generic_Type ->
            JE.object
                [ ( "type", JE.string "generic" )
                , ( "question", JE.string (clean question) )
                , ( "solution", JE.null )
                , ( "script", JE.bool True )
                ]

        Quiz.Block_Type block ->
            case block.solution of
                Block.Text str ->
                    base "text" question [ ( "solution", solution JE.string str ) ]

                Block.Select _ list ->
                    base "select"
                        question
                        [ ( "options", inlinesList block.options )
                        , ( "solution", solution (JE.list JE.int) list )
                        ]

                Block.Drop _ _ list ->
                    base "drop"
                        question
                        [ ( "options", inlinesList block.options )
                        , ( "solution", solution (JE.list JE.int) list )
                        ]

        Quiz.Vector_Type vector ->
            let
                ( type_, bools ) =
                    choices vector.solution
            in
            base type_
                question
                [ ( "options", JE.list (text stringify >> clean >> JE.string) vector.options )
                , ( "solution", solution (JE.list JE.bool) bools )
                ]

        Quiz.Matrix_Type matrix ->
            let
                rows =
                    Array.toList matrix.solution
            in
            base "matrix"
                question
                [ ( "rows", inlinesList matrix.options )
                , ( "columns", inlinesList matrix.headers )
                , ( "multiple", JE.list (choices >> Tuple.first >> (==) "multiple" >> JE.bool) rows )
                , ( "solution", solution (JE.list (choices >> Tuple.second >> JE.list JE.bool)) rows )
                ]

        Quiz.Multi_Type multi ->
            let
                gaps =
                    Array.length multi.solution

                -- the gaps of the text become [1], [2], …
                numbered =
                    stringify_
                        { scripts = Array.empty
                        , visible = Nothing
                        , input =
                            { state = Array.initialize gaps (\i -> Block.Text ("[" ++ String.fromInt (i + 1) ++ "]"))
                            , options = Array.empty
                            }
                        }

                body =
                    text numbered multi.elements
            in
            base "gap"
                (String.trim (question ++ " " ++ body))
                [ ( "gaps"
                  , multi.solution
                        |> Array.toList
                        |> List.indexedMap
                            (\i state ->
                                gap
                                    (multi.options |> Array.get i |> Maybe.withDefault [])
                                    state
                                    (solution identity)
                            )
                        |> JE.list identity
                  )
                ]


gap : List Inlines -> Block.State -> (JE.Value -> JE.Value) -> JE.Value
gap options state solution =
    case state of
        Block.Text str ->
            JE.object
                [ ( "type", JE.string "text" )
                , ( "solution", solution (JE.string str) )
                ]

        Block.Select _ list ->
            JE.object
                [ ( "type", JE.string "select" )
                , ( "options", inlinesList options )
                , ( "solution", solution (JE.list JE.int list) )
                ]

        Block.Drop _ _ list ->
            JE.object
                [ ( "type", JE.string "drop" )
                , ( "options", inlinesList options )
                , ( "solution", solution (JE.list JE.int list) )
                ]


choices : Vector.State -> ( String, List Bool )
choices state =
    case state of
        Vector.SingleChoice list ->
            ( "single", list )

        Vector.MultipleChoice list ->
            ( "multiple", list )



-- SURVEYS, TASKS, CODE


surveyMeta : String -> Survey.Survey Block -> JE.Value
surveyMeta question survey =
    let
        base type_ fields =
            JE.object
                (( "type", JE.string type_ )
                    :: ( "question", JE.string (clean question) )
                    :: fields
                )

        option key label_ =
            JE.object [ ( "key", JE.string key ), ( "label", JE.string (clean label_) ) ]
    in
    case survey.survey of
        Survey.Text lines ->
            base
                (if lines > 1 then
                    "textarea"

                 else
                    "text"
                )
                []

        Survey.Select options ->
            base "select" [ ( "options", JE.list identity (List.indexedMap (\i o -> option (String.fromInt i) (stringify o)) options) ) ]

        Survey.DragAndDrop options ->
            base "drop" [ ( "options", JE.list identity (List.indexedMap (\i o -> option (String.fromInt i) (stringify o)) options) ) ]

        -- brackets: several answers, parentheses: one
        Survey.Vector multiple options _ ->
            base
                (if multiple then
                    "multiple"

                 else
                    "single"
                )
                [ ( "options", JE.list (\( key, body ) -> option key (text stringify body)) options ) ]

        Survey.Matrix multiple headers keys rows ->
            base
                (if multiple then
                    "matrix-multiple"

                 else
                    "matrix-single"
                )
                [ ( "options", JE.list identity (List.map2 (\key header -> option key (stringify header)) keys headers) )
                , ( "rows", inlinesList rows )
                ]


taskMeta : String -> Task.Task Block -> JE.Value
taskMeta question task =
    JE.object
        [ ( "question", JE.string (clean question) )
        , ( "items", JE.list (text stringify >> clean >> JE.string) task.items )
        ]


codeMeta : Section -> String -> Int -> JE.Value
codeMeta section question i =
    JE.object
        [ ( "question", JE.string (clean question) )
        , ( "files"
          , section.code_model.evaluate
                |> Array.get i
                |> Maybe.map (.file >> Array.toList)
                |> Maybe.withDefault []
                |> JE.list
                    (\file ->
                        JE.object
                            [ ( "name", JE.string file.name )
                            , ( "lang", JE.string file.lang )
                            ]
                    )
          )
        ]



-- TEXT


inlinesList : List Inlines -> JE.Value
inlinesList =
    JE.list (stringify >> clean >> JE.string)


{-| Plain text of blocks, paragraphs separated by a space.
-}
text : (Inlines -> String) -> Blocks -> String
text toString blocks =
    blocks
        |> List.map (blockText toString)
        |> List.filter ((/=) "")
        |> String.join " "


blockText : (Inlines -> String) -> Block -> String
blockText toString block =
    case block of
        Paragraph _ inlines ->
            toString inlines

        Header _ ( _, inlines ) ->
            toString inlines

        Citation _ inlines ->
            toString inlines

        Quote _ _ blocks ->
            text toString blocks

        BulletList _ items ->
            items |> List.map (text toString) |> String.join "; "

        OrderedList _ items ->
            items |> List.map (Tuple.second >> text toString) |> String.join "; "

        Effect _ effect ->
            text toString effect.content

        HTML _ (HTML.Node _ _ blocks) ->
            text toString blocks

        _ ->
            ""


{-| One line, single spaces.
-}
clean : String -> String
clean =
    String.words >> String.join " "
