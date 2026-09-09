module Parser.Block.QuizTweaks exposing
    ( defaults_Suite
    , randomize_Suite
    , tweaks_Suite
    )

{-| The docs' "Tweaks" section - `data-*` attributes on the HTML comment
attached to a quiz (same `md_annotations` convention as any other block, see
`Parser.Block.Styling`) configure a `Lia.Markdown.Quiz.Types.Options` record.
Unlike the quiz's own `Block`, `Options` isn't part of the returned `Blocks`
tree at all - it's stored per-quiz in the parser state's `quiz_vector`
(`Context.quiz_vector`, indexed in parse order), so these tests go through
`parseWithState` and inspect the resulting `Element.opt`, the same pattern
`Parser.Block.Footnote` uses for `Context.footnotes`.
-}

import Array
import Expect
import Lia.Markdown.Quiz.Types exposing (Options)
import Parser.Block.Fixtures exposing (parseWithState)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, test)


{-| The first (only, in these tests) quiz's `Options`, or `Nothing` if no
quiz was parsed at all.
-}
firstQuizOptions : String -> Maybe Options
firstQuizOptions str =
    parseWithState str
        |> Tuple.second
        |> .quiz_vector
        |> Array.get 0
        |> Maybe.map .opt


defaults_Suite : Test
defaults_Suite =
    describe "a quiz with no data-* attributes gets every Option at its default"
        [ test "[[X]] correct\\n[[ ]] wrong\\n" <|
            \_ ->
                firstQuizOptions "[[X]] correct\n[[ ]] wrong\n"
                    |> Expect.equal
                        (Just
                            { randomize = Nothing
                            , maxTrials = Nothing
                            , score = Nothing
                            , showResolveAt = 0
                            , showHintsAt = 0
                            , showPartialSolution = False
                            , text_solved = Nothing
                            , text_failed = Nothing
                            , text_resolved = Nothing
                            }
                        )
        ]


tweaks_Suite : Test
tweaks_Suite =
    describe "data-* attributes on the comment above a quiz configure its Options"
        [ test "data-max-trials, data-score, data-solution-button, data-hint-button, data-show-partial-solution, data-text-solved together" <|
            \_ ->
                firstQuizOptions
                    ("<!-- data-max-trials=\"3\" data-score=\"0.5\" data-solution-button=\"2\" "
                        ++ "data-hint-button=\"1\" data-show-partial-solution data-text-solved=\"Well done!\" -->\n"
                        ++ "[[X]] correct\n[[ ]] wrong\n"
                    )
                    |> Expect.equal
                        (Just
                            { randomize = Nothing
                            , maxTrials = Just 3
                            , score = Just 0.5
                            , showResolveAt = 2
                            , showHintsAt = 1
                            , showPartialSolution = True
                            , text_solved = Just [ chars "Well done!" ]
                            , text_failed = Nothing
                            , text_resolved = Nothing
                            }
                        )
        ]


{-| Randomization only shuffles the options' index order, so a single-option
quiz is the one case whose shuffled result is fully deterministic regardless
of the RNG seed - there's only one possible permutation of one element.
-}
randomize_Suite : Test
randomize_Suite =
    describe "a data-randomize attribute enables option shuffling"
        [ test "a single-option quiz always shuffles to the same (trivial) order" <|
            \_ ->
                firstQuizOptions "<!-- data-randomize -->\n[[X]] correct\n"
                    |> Maybe.map .randomize
                    |> Expect.equal (Just (Just [ 0 ]))
        , test "without the attribute, randomize stays Nothing" <|
            \_ ->
                firstQuizOptions "[[X]] correct\n"
                    |> Maybe.map .randomize
                    |> Expect.equal (Just Nothing)
        ]
