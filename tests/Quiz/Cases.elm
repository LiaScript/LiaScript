module Quiz.Cases exposing (suite)

{-| Cases of `Lia.Markdown.Quiz` that do not occur in the LiaBooks and
LiaTemplates corpora, which are otherwise used as a golden master.
-}

import Accessibility.Aria as Aria
import Array
import Dict
import Expect
import Html
import I18n.Translations exposing (Lang(..))
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Block.Update as BlockMsg
import Lia.Markdown.Quiz.Multi.Update as MultiMsg
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Sync as QuizSync
import Lia.Markdown.Quiz.Types as Quiz exposing (Element, State(..), Type(..))
import Lia.Markdown.Quiz.Update as Update
import Lia.Markdown.Quiz.Vector.Types as VectorTypes
import Lia.Markdown.Quiz.Vector.Update as VectorMsg
import Lia.Markdown.Quiz.View as View
import Lia.Markdown.Types as Markdown
import Lia.Markdown.Update as Main
import Lia.Settings.Types exposing (Mode(..))
import Lia.Sync.Container as Container
import Lia.Sync.Types as Sync
import Parser.Block.Fixtures exposing (parseWithState)
import Service.Event as Event
import Test exposing (Test, describe, test)
import Test.Html.Event as HtmlEvent
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Quiz"
        [ cases
        , fixes
        ]


fixes : Test
fixes =
    describe "Quiz fixes"
        [ test "a matrix may be written as list with + or *" <|
            \_ ->
                [ "+ [(a) (b)]\n+ [(X) ( )] one\n+ [( ) (X)] two\n"
                , "* [(a) (b)]\n* [(X) ( )] one\n* [( ) (X)] two\n"
                ]
                    |> List.map (parseQuiz >> Maybe.map (Tuple.first >> .quiz >> Quiz.toState >> Quiz.getClass))
                    |> Expect.equal [ Just "matrix", Just "matrix" ]
        , test "escaped pipes do not separate the options of a selection" <|
            \_ ->
                parseQuiz "[[ a\\|b | (c) | d\\\\|e ]]\n"
                    |> Maybe.map (Tuple.first >> .quiz >> options)
                    |> Expect.equal (Just 3)
        , test "a script result with brackets marks the correct inputs" <|
            \_ ->
                case parseQuiz "<!-- data-show-partial-solution -->\na [[x]] b [[y]] <script>@input</script>\n" of
                    Just ( quiz, e ) ->
                        [ "[true,false]", "[true, true]", "true,false" ]
                            |> List.map
                                (\result ->
                                    Array.fromList [ e ]
                                        |> Update.update Sync.disconnected Nothing Array.empty (Update.handle (evalResult result))
                                        |> .value
                                        |> Array.get 0
                                        |> Maybe.map (\el -> ( el.solved, Array.toList el.partiallySolved ))
                                )
                            |> Expect.equal
                                [ Just ( Solution.Open, [ True, False ] )
                                , Just ( Solution.Solved, [ True, True ] )
                                , Just ( Solution.Open, [ True, False ] )
                                ]

                    Nothing ->
                        Expect.fail "no quiz"
        ]


cases : Test
cases =
    describe "Quiz cases missing in the corpora"
        [ test "a drop with several correct options accepts each of them" <|
            \_ ->
                case parseQuiz "[->[ (a) | (b) | c ]]\n" of
                    Just ( quiz, _ ) ->
                        [ 0, 1, 2 ]
                            |> List.map (\i -> Quiz.comp quiz.quiz (Block_State (Block.Drop False False [ i ])))
                            |> Expect.equal [ Solution.Solved, Solution.Solved, Solution.Open ]

                    Nothing ->
                        Expect.fail "no quiz"
        , test "data-hint-button hides the hint button until the given trial" <|
            \_ ->
                case parseQuiz "<!-- data-hint-button=\"2\" -->\n[[x]]\n[[?]] hint\n" of
                    Just ( quiz, e ) ->
                        [ 1, 2 ]
                            |> List.map
                                (\trial ->
                                    render config quiz { e | trial = trial }
                                        |> Query.findAll [ Selector.class "lia-quiz__hint" ]
                                        |> Query.count (Expect.equal (trial - 1))
                                )
                            |> (\expectations -> Expect.all (List.map always expectations) ())

                    Nothing ->
                        Expect.fail "no quiz"
        , test "data-score is shown for solved quizzes in the classroom table" <|
            \_ ->
                case parseQuiz "<!-- data-score=\"2.5\" -->\n[[x]]\n" of
                    Just ( quiz, e ) ->
                        render (classroom (JE.object [ ( "trial", JE.int 1 ), ( "state", JE.object [ ( "Text", JE.string "x" ) ] ) ])) quiz e
                            |> Query.findAll [ Selector.tag "td" ]
                            |> Query.index -1
                            |> Query.has [ Selector.text "2.5" ]

                    Nothing ->
                        Expect.fail "no quiz"
        , test "a generic quiz may be written as list item" <|
            \_ ->
                parseQuiz "- [[!]]\n"
                    |> Maybe.map (Tuple.first >> .quiz >> isGeneric)
                    |> Expect.equal (Just True)
        , test "the script after a gap-text checks it, it is hidden and does not run on its own" <|
            \_ ->
                let
                    ( _, context ) =
                        parseWithState "a [[x]] <script>@input == '\"x\"'</script>\n"
                in
                ( context.quiz_vector |> Array.get 0 |> Maybe.andThen .scriptID
                , context.effect_model.javascript
                    |> Array.get 0
                    |> Maybe.map (\js -> ( js.block, js.input.type_ ))
                )
                    |> Expect.equal ( Just 0, Just ( True, Just Input.Hidden_ ) )
        , test "a negative number of trials for a button counts like a positive one" <|
            \_ ->
                parseQuiz "<!-- data-solution-button=\"-2\" -->\n[[x]]\n"
                    |> Maybe.map (Tuple.second >> .opt >> .showResolveAt)
                    |> Expect.equal (Just 2)
        , test "data-show-partials is an alias of data-show-partial-solution" <|
            \_ ->
                parseQuiz "<!-- data-show-partials -->\n[[x]]\n"
                    |> Maybe.map (Tuple.second >> .opt >> .showPartialSolution)
                    |> Expect.equal (Just True)
        , test "a check with a missing script only activates the quiz" <|
            \_ ->
                case parseQuiz "[[x]]\n" of
                    Just ( quiz, e ) ->
                        Array.fromList [ { e | scriptID = Just 3, deactivated = True } ]
                            |> Update.update Sync.disconnected (Just 0) Array.empty (Update.Check 0 quiz.quiz)
                            |> (\r -> ( Array.toList r.value |> List.map (\el -> ( el.deactivated, el.trial )), List.length r.events ))
                            |> Expect.equal ( [ ( False, 0 ) ], 0 )

                    Nothing ->
                        Expect.fail "no quiz"
        , test "choices may be written as list with *" <|
            \_ ->
                parseQuiz "* [(X)] a\n* [( )] b\n"
                    |> Maybe.map (Tuple.second >> .state >> Quiz.getClass)
                    |> Expect.equal (Just "single-choice")
        , test "the header of a matrix may start with spaces" <|
            \_ ->
                parseQuiz "[ (a) (b) ]\n[ (X) ( ) ] one\n"
                    |> Maybe.map (Tuple.second >> .state >> Quiz.getClass)
                    |> Expect.equal (Just "matrix")
        , test "matrix rows are marked as correct or invalid" <|
            \_ ->
                case parseQuiz "[(a) (b)]\n[(X) ( )] one\n[( ) (X)] two\n" of
                    Just ( quiz, e ) ->
                        render config quiz { e | trial = 1, partiallySolved = Array.fromList [ True, False ] }
                            |> Query.find [ Selector.tag "tbody" ]
                            |> Query.findAll [ Selector.tag "tr" ]
                            |> Expect.all
                                [ Query.index 0 >> Query.findAll [ Selector.tag "input" ] >> Query.first >> Query.has [ Selector.attribute (Aria.invalid False) ]
                                , Query.index 0 >> Query.findAll [ Selector.class "is-success" ] >> Query.count (Expect.equal 2)
                                , Query.index 1 >> Query.findAll [ Selector.tag "input" ] >> Query.first >> Query.has [ Selector.attribute (Aria.invalid True) ]
                                ]

                    Nothing ->
                        Expect.fail "no quiz"
        , test "[[?]] is not a text input" <|
            \_ ->
                parseQuiz "[[?]]\n"
                    |> Expect.equal Nothing
        , test "\\@ is unescaped within a solution" <|
            \_ ->
                parseQuiz "[[ \\@x ]]\n"
                    |> Maybe.map (Tuple.first >> .quiz >> Quiz.toState)
                    |> Expect.equal (Just (Block_State (Block.Text "@x")))
        , test "a click on a filled drop zone empties it" <|
            \_ ->
                Block.Drop True False [ 2 ]
                    |> BlockMsg.update BlockMsg.DropTarget
                    |> .value
                    |> Expect.equal (Block.Drop True False [])
        , test "a highlighted drop zone gets a wider border" <|
            \_ ->
                case parseQuiz "[->[ (a) | b ]]\n" of
                    Just ( quiz, e ) ->
                        render config quiz { e | state = Block_State (Block.Drop True False []) }
                            |> Query.has [ Selector.style "border" "5px dotted #888" ]

                    Nothing ->
                        Expect.fail "no quiz"
        , test "an option dragged into another drop zone leaves its previous one" <|
            \_ ->
                Array.fromList [ Block.Drop False False [ 0, 1 ], Block.Drop True False [] ]
                    |> MultiMsg.update (MultiMsg.handle ( "dragend", JE.object [ ( "id", JE.int 1 ), ( "value", JE.list JE.int [ 0, 1 ] ) ] ))
                    |> .value
                    |> Array.toList
                    |> Expect.equal [ Block.Drop False False [], Block.Drop False False [ 0, 1 ] ]
        , test "clicking a selected single choice clears it" <|
            \_ ->
                VectorTypes.SingleChoice [ True, False ]
                    |> VectorMsg.toggle 0
                    |> Expect.equal (VectorTypes.SingleChoice [ False, False ])
        , test "an option dropped onto another input of a gap-text is wrong" <|
            \_ ->
                [ [ 0, 1 ], [ 1, 1 ] ]
                    |> List.map (Block.Drop False False >> Block.comp (Just 0) (Block.Quiz [] (Block.Drop False False [ 1 ])))
                    |> Expect.equal [ True, False ]
        , test "enter in a text input checks the quiz" <|
            \_ ->
                case parseQuiz "[[x]]\n" of
                    Just ( quiz, e ) ->
                        render config quiz e
                            |> Query.find [ Selector.tag "input" ]
                            |> HtmlEvent.simulate (HtmlEvent.custom "keyup" (JE.object [ ( "keyCode", JE.int 13 ) ]))
                            |> HtmlEvent.toResult
                            |> Result.map isCheck
                            |> Expect.equal (Ok True)

                    Nothing ->
                        Expect.fail "no quiz"
        , test "enter in a text input does nothing while its script runs" <|
            \_ ->
                case parseQuiz "[[x]]\n" of
                    Just ( quiz, e ) ->
                        render config quiz { e | deactivated = True }
                            |> Query.find [ Selector.tag "input" ]
                            |> HtmlEvent.simulate (HtmlEvent.custom "keyup" (JE.object [ ( "keyCode", JE.int 13 ) ]))
                            |> HtmlEvent.toResult
                            |> Expect.equal (Ok (Main.UpdateQuiz (Update.Block_Update 0 BlockMsg.None)))

                    Nothing ->
                        Expect.fail "no quiz"
        ]


options : Quiz.Type x -> Int
options quiz =
    case quiz of
        Block_Type q ->
            List.length q.options

        _ ->
            0


evalResult : String -> Event.Event
evalResult result =
    Event.init "script"
        { cmd = "eval"
        , param = JE.object [ ( "ok", JE.bool True ), ( "result", JE.string result ), ( "details", JE.list identity [] ) ]
        }
        |> Event.pushWithId "eval" 0


isGeneric : Quiz.Type x -> Bool
isGeneric quiz =
    case quiz of
        Generic_Type ->
            True

        _ ->
            False


isCheck : Main.Msg -> Bool
isCheck msg =
    case msg of
        Main.UpdateQuiz (Update.Check 0 _) ->
            True

        _ ->
            False


{-| The first quiz of a course and its initial state.
-}
parseQuiz : String -> Maybe ( Quiz.Quiz Markdown.Block, Element )
parseQuiz code =
    let
        ( blocks, context ) =
            parseWithState code
    in
    Maybe.map2 Tuple.pair
        (blocks
            |> List.filterMap
                (\block ->
                    case block of
                        Markdown.Quiz _ quiz _ ->
                            Just quiz

                        _ ->
                            Nothing
                )
            |> List.head
        )
        (Array.get 0 context.quiz_vector)


render : Config Main.Msg -> Quiz.Quiz Markdown.Block -> Element -> Query.Single Main.Msg
render conf quiz e =
    View.view conf Nothing quiz (Array.fromList [ e ]) [] (List.map (always [ Html.text "hint" ]) quiz.hints)
        |> Tuple.second
        |> Html.div []
        |> Query.fromHtml


config : Config sub
config =
    Config.init
        { mode = Textbook
        , visible = Nothing
        , slide = 0
        , speaking = Nothing
        , paused = Nothing
        , lang = En
        , theme = Nothing
        , light = True
        , tooltips = False
        , hideVideoComments = False
        , media = Dict.empty
        , scripts = Array.empty
        , translations = Nothing
        , formulas = Nothing
        , sync = Nothing
        }


{-| The owner's view of a classroom, in which the peer "p1" answered the first
quiz of section 0 with `answer`.
-}
classroom : JE.Value -> Config sub
classroom answer =
    let
        base =
            Sync.init []

        data =
            base.data
    in
    { config
        | sync =
            Just
                { base
                    | state = Sync.Connected "me"
                    , mode = Sync.Details
                    , owner = True
                    , peersHistory = Dict.singleton "p1" "Bob"
                    , data =
                        { data
                            | quiz =
                                [ JE.object [ ( "p1", answer ) ] ]
                                    |> JE.list identity
                                    |> JD.decodeValue (Container.decoder QuizSync.decoder)
                                    |> Result.map (Dict.singleton 0)
                                    |> Result.withDefault Dict.empty
                        }
                }
    }
