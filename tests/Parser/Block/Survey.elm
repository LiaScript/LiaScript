module Parser.Block.Survey exposing
    ( categoricalVector_Suite
    , dragAndDrop_Suite
    , indentedTypes_Suite
    , matrixIndentation_Suite
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
import Parser.Block.Fixtures exposing (paragraph, parse)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, fuzz, test)


textInput_Suite : Test
textInput_Suite =
    describe "generating free-text survey inputs"
        [ test "a single underscore-run [[___]] becomes one text field" <|
            \_ ->
                {- [[___]] -}
                parse "[[___]]\n"
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        , test "several space-separated underscore-runs become that many text fields" <|
            \_ ->
                {- [[___ ____ _____]] -}
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
                {- [[opt1|opt2]] -}
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
                {- [->[opt1|opt2]] -}
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
                {- [(ColA)(ColB)]
                   [ ] Row1
                   [ ] Row2
                -}
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


{-| A matrix's header and rows independently accept every combination of: an
optional `-`/`+`/`*` marker prefix, an optional shared 4-space indent, and
either header bracket style (`(col)` for single-choice-per-row columns,
`[col]` for multiple-choice-per-row columns) - all eight combinations below
produce the identical structure. This pins down a real fix in
`Survey.Parser.pattern`/`questions`: their marker-detecting regexes used to
look for the optional dash _before_ any leading whitespace, so an indented,
dash-prefixed line (`- [(A)(B)]`) failed to match at all (the dash comes
_after_ the indent, not before it) - both now allow whitespace before the
optional dash too, matching `Quiz.Matrix.Parser.header`'s already-correct
`maybe Indent.check |> ignore spaces |> ignore (regex "(?:(-|+*)[\\t ]*)?\\[")`
shape.
-}
matrixIndentation_Suite : Test
matrixIndentation_Suite =
    let
        expect bool =
            [ Survey []
                { survey =
                    Matrix bool
                        [ [ chars "A" ], [ chars "B" ] ]
                        [ "A", "B" ]
                        [ [ chars " Row1" ], [ chars " Row2" ] ]
                , id = 0
                }
            ]
    in
    describe "a matrix's header and rows accept every combination of optional dash marker and shared indent"
        [ test "no indent, no dash, paren-style header" <|
            \_ ->
                {- [(A)(B)]
                   [ ] Row1
                   [ ] Row2
                -}
                parse "[(A)(B)]\n[ ] Row1\n[ ] Row2\n"
                    |> Expect.equal (expect False)
        , test "no indent, no dash, bracket-style header" <|
            \_ ->
                {- [[A][B]]
                   [ ] Row1
                   [ ] Row2
                -}
                parse "[[A][B]]\n[ ] Row1\n[ ] Row2\n"
                    |> Expect.equal (expect True)
        , test "no indent, dash, paren-style header" <|
            \_ ->
                {- - [(A)(B)]
                   - [ ] Row1
                   - [ ] Row2
                -}
                parse "- [(A)(B)]\n- [ ] Row1\n- [ ] Row2\n"
                    |> Expect.equal (expect False)
        , test "no indent, dash, bracket-style header" <|
            \_ ->
                {- - [[A][B]]
                   - [ ] Row1
                   - [ ] Row2
                -}
                parse "- [[A][B]]\n- [ ] Row1\n- [ ] Row2\n"
                    |> Expect.equal (expect True)
        , test "indented, no dash, paren-style header" <|
            \_ ->
                {- [(A)(B)]
                   [ ] Row1
                   [ ] Row2
                -}
                parse "    [(A)(B)]\n    [ ] Row1\n    [ ] Row2\n"
                    |> Expect.equal (expect False)
        , test "indented, no dash, bracket-style header" <|
            \_ ->
                {- [[A][B]]
                   [ ] Row1
                   [ ] Row2
                -}
                parse "    [[A][B]]\n    [ ] Row1\n    [ ] Row2\n"
                    |> Expect.equal (expect True)
        , test "indented, dash, paren-style header" <|
            \_ ->
                {- - [(A)(B)]
                   - [ ] Row1
                   - [ ] Row2
                -}
                parse "    - [(A)(B)]\n    - [ ] Row1\n    - [ ] Row2\n"
                    |> Expect.equal (expect False)
        , test "indented, dash, bracket-style header" <|
            \_ ->
                {- - [[A][B]]
                   - [ ] Row1
                   - [ ] Row2
                -}
                parse "    - [[A][B]]\n    - [ ] Row1\n    - [ ] Row2\n"
                    |> Expect.equal (expect True)
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
                {- [[!]] -}
                parse "[[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = QuizTypes.Generic_Type, id = 0, hints = [] } Nothing ]
        , test "[[?]] alone matches no special syntax and falls back to Problem" <|
            \_ ->
                -- "?" is now excluded from `Survey.Parser.id_str` (reserved
                -- for Quiz's hints marker), so this no longer parses as a
                -- one-option categorical Vector-survey either - with no
                -- preceding quiz to attach to as a hint, and no valid inline
                -- construct matching "?" inside double brackets, it falls
                -- back to the `Problem` catch-all.
                {- [[?]] -}
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
_itself_ enough to fall through regardless of option count, so these
particular examples would fail the same way even with a second option
added (real courses always give each option a label anyway, per the docs'
own examples - a labelless option isn't a meaningful survey question).

-}
categoricalVector_Suite : Test
categoricalVector_Suite =
    describe "categorical Vector-survey needs at least two [[id]]/[(id)] options"
        [ test "a single [[id]] line is not enough for a survey - it falls through to Quiz's Block_Type" <|
            \_ ->
                {- [[Berlin]] -}
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
                {- [(Berlin)] -}
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
                {-
                   What are your favorite colors?

                   [[red]] is it red
                   [[green]] green
                   [[blue]] or blue
                -}
                parse "What are your favorite colors?\n\n[[red]] is it red\n[[green]] green\n[[blue]] or blue\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What are your favorite colors?" ]
                        , Survey []
                            { survey =
                                Vector True
                                    [ ( "red", [ paragraph "is it red" ] )
                                    , ( "green", [ paragraph "green" ] )
                                    , ( "blue", [ paragraph "or blue" ] )
                                    ]
                                    Categorical
                            , id = 0
                            }
                        ]
        , test "single-choice, numeric ids -> Quantitative analysis" <|
            \_ ->
                {-
                   Select one option:

                   [(1)] option 1
                   [(2)] option 2
                   [(3)] option 3
                   [(0)] option 0
                -}
                parse "Select one option:\n\n[(1)] option 1\n[(2)] option 2\n[(3)] option 3\n[(0)] option 0\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "Select one option:" ]
                        , Survey []
                            { survey =
                                Vector False
                                    [ ( "1", [ paragraph "option 1" ] )
                                    , ( "2", [ paragraph "option 2" ] )
                                    , ( "3", [ paragraph "option 3" ] )
                                    , ( "0", [ paragraph "option 0" ] )
                                    ]
                                    Quantitative
                            , id = 0
                            }
                        ]
        , test "single-choice, non-numeric ids -> Categorical analysis" <|
            \_ ->
                {- - [(very good)] I like it very much
                   - [(bad)] I don't like it
                -}
                parse "- [(very good)] I like it very much\n- [(bad)] I don't like it\n"
                    |> Expect.equal
                        [ Survey []
                            { survey =
                                Vector False
                                    [ ( "very good", [ paragraph "I like it very much" ] )
                                    , ( "bad", [ paragraph "I don't like it" ] )
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
                {- e.g. [[__________]] -}
                parse ("[[" ++ underscores ++ "]]\n")
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        ]


{-| Like a Quiz (see `Parser.Block.Quiz.indentedQuizTypes_Suite`), a Survey
accepts being shifted right by a shared 4-space indent, same as a plain
Markdown list or paragraph would - this is in fact how the docs themselves
present a Vector-survey, indented under its question paragraph (see
`vector_Suite`'s docs and the last two cases below, lifted straight from the
docs' "Multi-Choice Vector"/"Single-Choice Vector" examples).

The one thing indentation does _not_ fix is a categorical Vector-survey
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
                {- [[___]] -}
                parse "    [[___]]\n"
                    |> Expect.equal [ Survey [] { survey = Text 1, id = 0 } ]
        , test "a single-select question, indented" <|
            \_ ->
                {- [[opt1|opt2]] -}
                parse "    [[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = Select [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        , test "a drag-and-drop question, indented" <|
            \_ ->
                {- [->[opt1|opt2]] -}
                parse "    [->[opt1|opt2]]\n"
                    |> Expect.equal
                        [ Survey [] { survey = DragAndDrop [ [ chars "opt1" ], [ chars "opt2" ] ], id = 0 } ]
        , test "a matrix question, header and rows all indented" <|
            \_ ->
                {- [(ColA)(ColB)]
                   [ ] Row1
                   [ ] Row2
                -}
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
                -- Just like Quiz-Vector (see `Parser.Block.Quiz.indentedOptions_Suite`),
                -- the indent required for an option's nested content is measured
                -- dynamically from that option's own marker column, not a fixed
                -- absolute amount - so a group of sibling options uniformly offset
                -- under a preceding question (all at the same column) stay flat
                -- siblings of each other.
                {-
                   What are your favorite colors?

                       [[red]] is it red
                       [[green]] green
                       [[blue]] or blue
                -}
                parse "What are your favorite colors?\n\n    [[red]] is it red\n    [[green]] green\n    [[blue]] or blue\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What are your favorite colors?" ]
                        , Survey []
                            { survey =
                                Vector True
                                    [ ( "red", [ paragraph "is it red" ] )
                                    , ( "green", [ paragraph "green" ] )
                                    , ( "blue", [ paragraph "or blue" ] )
                                    ]
                                    Categorical
                            , id = 0
                            }
                        ]
        , test "a categorical Vector-survey with bare, label-less ids does NOT merge when indented - it falls back to two standalone Quiz fill-in-the-blanks" <|
            \_ ->
                {- [[optA]]
                   [[optB]]
                -}
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
