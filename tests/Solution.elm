module Solution exposing
    ( comments_Suite
    , hideUnsolvedComments_Suite
    , revealSolution_Suite
    , revealSolutions_Suite
    , solutions_Suite
    )

{-| Solution blocks `*****` below quizzes and surveys: their comments and
scripts are hidden until the quiz gets solved or the survey submitted, then
the scripts are executed and only the new comments are read out loud.
-}

import Array
import Dict
import Expect
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Update as Markdown
import Lia.Markdown.View exposing (hideUnsolvedComments)
import Lia.Section as Section exposing (Section)
import Parser.Block.Fixtures exposing (parseWithState)
import Return
import Test exposing (Test, describe, test)


{-| Comment 0.0 and script 0 are outside of any solution, the quiz solution
contains comment 0.1, script 1 and script 2 (within animation step 1), the
survey solution contains comment 0.2 and no script.
-}
course : String
course =
    String.join "\n"
        [ "--{{0}}--"
        , "Intro"
        , ""
        , "Question <script>0</script>"
        , ""
        , "- [(X)] yes"
        , "- [( )] no"
        , "*****"
        , "--{{0}}--"
        , "Quiz comment"
        , ""
        , "Solution <script>1</script>"
        , ""
        , "{{1}}"
        , "Step <script>2</script>"
        , "*****"
        , ""
        , "[(1)] a"
        , "[(2)] b"
        , "*****"
        , "--{{0}}--"
        , "Survey comment"
        , "*****"
        , ""
        ]


section : Section
section =
    let
        ( body, state ) =
            parseWithState course

        base =
            Section.init 0 0 { indentation = 1, title = [], code = course }
    in
    { base
        | body = body
        , parsed = True
        , quiz_vector = state.quiz_vector
        , survey_vector = state.survey_vector
        , effect_model = state.effect_model
    }


solveQuiz : Section -> Section
solveQuiz s =
    { s | quiz_vector = Array.map (\e -> { e | solved = Solution.Solved }) s.quiz_vector }


submitSurvey : Section -> Section
submitSurvey s =
    { s | survey_vector = Array.map (\e -> { e | submitted = True }) s.survey_vector }


commentTexts : Section -> List String
commentTexts s =
    s
        |> hideUnsolvedComments
        |> .comments
        |> Dict.get 0
        |> Maybe.map (.content >> Array.toList >> List.map (.content >> stringify >> String.trim))
        |> Maybe.withDefault []


comments_Suite : Test
comments_Suite =
    describe "parsing comments and scripts within solutions"
        [ test "comments get the class of their solution" <|
            \_ ->
                section.effect_model.comments
                    |> Dict.get 0
                    |> Maybe.map (.content >> Array.toList >> List.map .attr)
                    |> Expect.equal
                        (Just
                            [ []
                            , [ ( "class", "lia-tts-quiz-0" ) ]
                            , [ ( "class", "lia-tts-survey-0" ) ]
                            ]
                        )
        , test "scripts are marked with their solution" <|
            \_ ->
                section.effect_model.javascript
                    |> Array.toList
                    |> List.map (\js -> ( js.effect_id, js.solution ))
                    |> Expect.equal
                        [ ( 0, Nothing )
                        , ( 0, Just "lia-tts-quiz-0" )
                        , ( 1, Just "lia-tts-quiz-0" )
                        ]
        ]


solutions_Suite : Test
solutions_Suite =
    describe "Markdown.solutions"
        [ test "lists quiz and survey solutions with their comments" <|
            \_ ->
                Markdown.solutions section section.body
                    |> Expect.equal
                        [ { solved = False, class = "lia-tts-quiz-0", comments = [ ( 0, 1 ) ] }
                        , { solved = False, class = "lia-tts-survey-0", comments = [ ( 0, 2 ) ] }
                        ]
        , test "a solved quiz and a submitted survey are solved" <|
            \_ ->
                section
                    |> solveQuiz
                    |> submitSurvey
                    |> Markdown.solved
                    |> Expect.equal [ "lia-tts-quiz-0", "lia-tts-survey-0" ]
        ]


hideUnsolvedComments_Suite : Test
hideUnsolvedComments_Suite =
    describe "hideUnsolvedComments"
        [ test "hides the comments of unsolved solutions" <|
            \_ ->
                commentTexts section
                    |> Expect.equal [ "Intro" ]
        , test "shows the comments of a solved quiz" <|
            \_ ->
                commentTexts (solveQuiz section)
                    |> Expect.equal [ "Intro", "Quiz comment" ]
        , test "shows the comments of a submitted survey" <|
            \_ ->
                commentTexts (submitSurvey section)
                    |> Expect.equal [ "Intro", "Survey comment" ]
        ]


revealSolution_Suite : Test
revealSolution_Suite =
    let
        reveal runAll visible =
            Script.revealSolution runAll visible "lia-tts-quiz-0" section.effect_model.javascript
    in
    describe "Script.revealSolution"
        [ test "releases all scripts of the solution" <|
            \_ ->
                reveal False 0
                    |> Tuple.first
                    |> Array.toList
                    |> List.map .solution
                    |> Expect.equal [ Nothing, Nothing, Nothing ]
        , test "executes only scripts of the visible animation steps" <|
            \_ ->
                reveal False 0
                    |> Tuple.second
                    |> List.map (\( id, _, _ ) -> id)
                    |> Expect.equal [ 1 ]
        , test "executes scripts of earlier animation steps too" <|
            \_ ->
                reveal False 1
                    |> Tuple.second
                    |> List.map (\( id, _, _ ) -> id)
                    |> Expect.equal [ 1, 2 ]
        , test "executes all scripts in textbook mode" <|
            \_ ->
                reveal True 0
                    |> Tuple.second
                    |> List.map (\( id, _, _ ) -> id)
                    |> Expect.equal [ 1, 2 ]
        , test "does not touch scripts of other solutions" <|
            \_ ->
                Script.revealSolution False 0 "lia-tts-survey-0" section.effect_model.javascript
                    |> Expect.equal ( section.effect_model.javascript, [] )
        ]


revealSolutions_Suite : Test
revealSolutions_Suite =
    let
        reveal settings before =
            section
                |> solveQuiz
                |> Return.val
                |> Markdown.revealSolutions settings before

        events settings before =
            reveal settings before
                |> .events
                |> List.map (\e -> ( e.service, e.message.cmd ))
                |> List.sort
    in
    describe "Markdown.revealSolutions"
        [ test "executes the scripts and reads the comments of a new solution" <|
            \_ ->
                events { sound = True, runAll = False } []
                    |> Expect.equal [ ( "script", "exec" ), ( "tts", "read" ) ]
        , test "does not read out loud without sound" <|
            \_ ->
                events { sound = False, runAll = False } []
                    |> Expect.equal [ ( "script", "exec" ) ]
        , test "ignores solutions that were visible before" <|
            \_ ->
                events { sound = True, runAll = False } [ "lia-tts-quiz-0" ]
                    |> Expect.equal []
        , test "releases the scripts of the new solution" <|
            \_ ->
                reveal { sound = False, runAll = False } []
                    |> .value
                    |> .effect_model
                    |> .javascript
                    |> Array.toList
                    |> List.map .solution
                    |> Expect.equal [ Nothing, Nothing, Nothing ]
        ]
