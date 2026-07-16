module Parser.Block.Survey exposing
    ( categoricalVector_Suite
    , dragAndDrop_Suite
    , indentedTypes_Suite
    , matrix_Suite
    , reservedIds_Suite
    , select_Suite
    , textInput_Suite
    , textInput_length_fuzz_Suite
    , vector_Suite
    )

import Expect
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Types as QuizTypes
import Lia.Markdown.Survey.Types exposing (Analysis(..), Type(..))
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex)
import Parser.Block.Fixtures exposing (parse)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, fuzz, test)


textInput_Suite : Test
textInput_Suite =
    describe "generating free-text survey inputs"
        [ test "a single underscore-run [[___]] becomes one text field" <|
            \_ ->
                parse "[[___]]\n"
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        , test "several space-separated underscore-runs become that many text fields" <|
            \_ ->
                parse "[[___ ____ _____]]\n"
                    |> Expect.equal [ Survey [] { survey = Text 3, id = 0 } ]
        ]


{-| `[[opt1|opt2]]` (no parens marking any option as "correct") at the start
of a line becomes a single-select survey question. This is the same
underlying syntax as a Quiz's `[[X]]`/select list, but a Survey has no
correct answer to mark, and `Survey.Parser.toSelect` only succeeds when
nothing is marked.
-}
select_Suite : Test
select_Suite =
    describe "generating single-select survey questions"
        [ test "two unmarked options" <|
            \_ ->
                parse "[[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = Select [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        ]


{-| `[->[opt1|opt2]]` is the drag-and-drop counterpart of `select_Suite`.
-}
dragAndDrop_Suite : Test
dragAndDrop_Suite =
    describe "generating drag-and-drop survey questions"
        [ test "two unmarked options" <|
            \_ ->
                parse "[->[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = DragAndDrop [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        ]


{-| A matrix survey header lists its columns, each wrapped in `(...)` (bool
`False`) or `[...]` (bool `True`), inside one more outer bracket pair; each
row is a fixed `[ ]` marker followed by its label. Using two columns avoids
the same single-id ambiguity with the plain Vector-survey parser as the Quiz
matrix header (see `Parser.Block.Quiz.matrix_Suite`).
-}
matrix_Suite : Test
matrix_Suite =
    describe "generating matrix survey questions ([(col)(col)] header + [ ] rows)"
        [ test "two columns, two rows" <|
            \_ ->
                parse "[(ColA)(ColB)]\n[ ] Row1\n[ ] Row2\n"
                    |> Expect.equal
                        [ Survey []
                            { survey =
                                Matrix False
                                    [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    [ "ColA", "ColB" ]
                                    [ [ chars " Row1" ], [ chars " Row2" ] ]
                            , id = 0
                            }
                        ]
        ]


{-| `"!"` and `"?"` are excluded from `Survey.Parser.id_str` (alongside the
existing `"X"`/`"x"` exclusion) because they're reserved elsewhere: `"!"` for
Quiz's generic (no-solution) marker, `"?"` for Quiz's hints marker. A bare
single `[[!]]`/`[[?]]` line can no longer be absorbed by the _one_-option
case anyway - see `categoricalVector_Suite` below, `vector` now requires at
least two options - but the `id_str` exclusion still matters once there are
two or more options, e.g. `[[!]]\n[[foo]]\n` would otherwise become a
two-option categorical survey with `"!"` as a reserved id instead of two
separate Quiz blocks.
-}
reservedIds_Suite : Test
reservedIds_Suite =
    describe "\"!\" and \"?\" are rejected as Survey option ids"
        [ test "[[!]] is the Quiz generic marker, not a Survey" <|
            \_ ->
                parse "[[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = QuizTypes.Generic_Type, id = 0, hints = [] } Nothing ]
        , test "[[?]] alone matches no special syntax and falls back to Problem" <|
            \_ ->
                -- `[[?]]` is explicitly excluded from ordinary paragraph text
                -- too (see `allowedLine` in Lia.Markdown.Parser), since it's
                -- reserved for Quiz's hints marker - so on its own, with no
                -- preceding quiz to attach to, it can't be parsed as
                -- anything and falls back to the `Problem` catch-all.
                parse "[[?]]\n"
                    |> Expect.equal [ Problem [ chars "[[?]]" ] ]
        ]


{-| A categorical Vector-survey (each option is its own `[[id]] label`/
`[(id)] label` line, as opposed to the single-line `[[opt1|opt2]]` form
covered by `select_Suite`) requires **at least two** options - a one-option
"survey" isn't meaningful, and allowing it used to swallow content that
should belong to something else entirely: a standalone Quiz fill-in-the-blank
(`[[some answer]]`, see `Parser.Block.Quiz.block_Suite`) in the
bracket-style case, or a single-column Matrix-quiz header (`[(ColA)]`, see
`Parser.Block.Quiz.matrix_Suite`) in the paren-style case.

This suite only pins down the _rejection_ side (fewer than two options
doesn't count as a survey any more); see `vector_Suite` for the working,
two-or-more-options shape. Both cases below use a bare `[[id]]`/`[(id)]`
with no trailing label text - which, as `vector_Suite`'s docs explain, is
*itself* enough to fall through regardless of option count, so these
particular examples would fail the same way even with a second option
added (real courses always give each option a label anyway, per the docs'
own examples - a labelless option isn't a meaningful survey question).
-}
categoricalVector_Suite : Test
categoricalVector_Suite =
    describe "categorical Vector-survey needs at least two [[id]]/[(id)] options"
        [ test "a single [[id]] line is not enough for a survey - it falls through to Quiz's Block_Type" <|
            \_ ->
                parse "[[Berlin]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = QuizTypes.Block_Type { options = [], solution = Block.Text "Berlin" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a single [(id)] line, with no quiz-matrix row following it, falls back to a plain paragraph" <|
            \_ ->
                parse "[(Berlin)]\n"
                    |> Expect.equal [ Paragraph [] [ chars "[(Berlin)]" ] ]
        ]


{-| The working, positive shape of a categorical Vector-survey - taken
directly from the docs' "Single-Choice Vector"/"Multi-Choice Vector"
examples. Each option is `[[id]] label` (multi-choice) or `[(id)] label`
(single-choice); the `Bool` in `Vector` marks multi- vs single-choice, and
the trailing `Analysis` (`Categorical`/`Quantitative`) is picked based on
whether every id parses as a number - this is what lets a classroom
presentation plot numeric-id surveys as a continuous distribution instead of
discrete categories.

The label text is what disambiguates this from Quiz's fill-in-the-blank
marker: a bare `[[id]]`/`[(id)]` with nothing after it is indistinguishable
from `[[answer]]`, so it always falls through to Quiz's `Block_Type` instead
(see `categoricalVector_Suite` above) - no matter how many such bare lines
follow one another.
-}
vector_Suite : Test
vector_Suite =
    describe "generating categorical Vector-survey questions ([[id]] label / [(id)] label)"
        [ test "multi-choice, non-numeric ids -> Categorical analysis" <|
            \_ ->
                parse "What are your favorite colors?\n\n[[red]] is it red\n[[green]] green\n[[blue]] or blue\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What are your favorite colors?" ]
                        , Survey []
                            { survey =
                                Vector True
                                    [ ( "red", [ chars "is it red" ] )
                                    , ( "green", [ chars "green" ] )
                                    , ( "blue", [ chars "or blue" ] )
                                    ]
                                    Categorical
                            , id = 0
                            }
                        ]
        , test "single-choice, numeric ids -> Quantitative analysis" <|
            \_ ->
                parse "Select one option:\n\n[(1)] option 1\n[(2)] option 2\n[(3)] option 3\n[(0)] option 0\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "Select one option:" ]
                        , Survey []
                            { survey =
                                Vector False
                                    [ ( "1", [ chars "option 1" ] )
                                    , ( "2", [ chars "option 2" ] )
                                    , ( "3", [ chars "option 3" ] )
                                    , ( "0", [ chars "option 0" ] )
                                    ]
                                    Quantitative
                            , id = 0
                            }
                        ]
        , test "single-choice, non-numeric ids -> Categorical analysis" <|
            \_ ->
                parse "- [(very good)] I like it very much\n- [(bad)] I don't like it\n"
                    |> Expect.equal
                        [ Survey []
                            { survey =
                                Vector False
                                    [ ( "very good", [ chars "I like it very much" ] )
                                    , ( "bad", [ chars "I don't like it" ] )
                                    ]
                                    Categorical
                            , id = 0
                            }
                        ]
        ]


{-| The underscore-run just needs to be at least 3 characters long - fuzz its
length to confirm any run length beyond the minimum still counts as exactly
one text field.
-}
textInput_length_fuzz_Suite : Test
textInput_length_fuzz_Suite =
    describe "any underscore-run of length >= 3 becomes a single text field"
        [ fuzz (fuzzRegex "_{3,30}") "wrapped in [[...]]" <|
            \underscores ->
                parse ("[[" ++ underscores ++ "]]\n")
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        ]


{-| Like a Quiz (see `Parser.Block.Quiz.indentedQuizTypes_Suite`), a Survey
accepts being shifted right by a shared 4-space indent, same as a plain
Markdown list or paragraph would - this is in fact how the docs themselves
present a Vector-survey, indented under its question paragraph (see
`vector_Suite`'s docs and the last two cases below, lifted straight from the
docs' "Multi-Choice Vector"/"Single-Choice Vector" examples).

The one thing indentation does *not* fix is a categorical Vector-survey
whose options have no label text at all (`categoricalVector_Suite` above) -
`[[optA]]\n    [[optB]]\n` still falls through to two separate standalone
Quiz `Block_Type` fill-in-the-blanks, indented or not, for the same reason
given there: a bare `[[id]]` is indistinguishable from Quiz's fill-in-the-blank
marker regardless of indentation.
-}
indentedTypes_Suite : Test
indentedTypes_Suite =
    describe "surveys of every type can be indented by 4 spaces"
        [ test "a free-text input, indented" <|
            \_ ->
                parse "    [[___]]\n"
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        , test "a single-select question, indented" <|
            \_ ->
                parse "    [[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = Select [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        , test "a drag-and-drop question, indented" <|
            \_ ->
                parse "    [->[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = DragAndDrop [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        , test "a matrix question, header and rows all indented" <|
            \_ ->
                parse "    [(ColA)(ColB)]\n    [ ] Row1\n    [ ] Row2\n"
                    |> Expect.equal
                        [ Survey []
                            { survey =
                                Matrix False
                                    [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    [ "ColA", "ColB" ]
                                    [ [ chars " Row1" ], [ chars " Row2" ] ]
                            , id = 0
                            }
                        ]
        , test "a categorical Vector-survey, labeled options, indented under its question paragraph - the docs' own presentation style" <|
            \_ ->
                parse "What are your favorite colors?\n\n    [[red]] is it red\n    [[green]] green\n    [[blue]] or blue\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What are your favorite colors?" ]
                        , Survey []
                            { survey =
                                Vector True
                                    [ ( "red", [ chars "is it red" ] )
                                    , ( "green", [ chars "green" ] )
                                    , ( "blue", [ chars "or blue" ] )
                                    ]
                                    Categorical
                            , id = 0
                            }
                        ]
        , test "a categorical Vector-survey with bare, label-less ids does NOT merge when indented - it falls back to two standalone Quiz fill-in-the-blanks" <|
            \_ ->
                parse "    [[optA]]\n    [[optB]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = QuizTypes.Block_Type { options = [], solution = Block.Text "optA" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        , Quiz []
                            { quiz = QuizTypes.Block_Type { options = [], solution = Block.Text "optB" }
                            , id = 1
                            , hints = []
                            }
                            Nothing
                        ]
        ]
