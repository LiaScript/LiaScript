module Parser.Block.Quiz exposing
    ( block_Suite
    , checkedCase_fuzz_Suite
    , generic_Suite
    , hints_Suite
    , indentedOptions_Suite
    , indentedQuizTypes_Suite
    , itemText_fuzz_Suite
    , matrix_Suite
    , multiGapText_Suite
    , multipleChoice_Suite
    , oneColumnDoesNotSwallowUnrelatedContent_Suite
    , singleChoice_Suite
    )

import Array
import Expect
import Lia.Markdown.Inline.Types as InlineTypes
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Types exposing (Type(..))
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex, words)
import Parser.Block.Fixtures exposing (paragraph, parse)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, fuzz, test)


multipleChoice_Suite : Test
multipleChoice_Suite =
    describe "generating multiple-choice quizzes ([[ ]]/[[X]])"
        [ test "a checked and an unchecked option" <|
            \_ ->
                parse "[[X]] correct\n[[ ]] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three options, two of them checked" <|
            \_ ->
                parse "[[X]] one\n[[X]] two\n[[ ]] three\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "one" ], [ chars "two" ], [ chars "three" ] ]
                                    , solution = MultipleChoice [ True, True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "options prefixed with the optional -/+/* list marker" <|
            \_ ->
                parse "- [[X]] correct\n+ [[ ]] wrong\n* [[X]] also correct\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ], [ chars "also correct" ] ]
                                    , solution = MultipleChoice [ True, False, True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line ends the option list; indented text after it is not absorbed as a continuation" <|
            \_ ->
                parse "[[X]] correct\n\n    continued\n[[ ]] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        , paragraph "continued [[ ]] wrong"
                        ]
        ]


singleChoice_Suite : Test
singleChoice_Suite =
    describe "generating single-choice quizzes ([( )]/[(X)])"
        [ test "a checked and an unchecked option" <|
            \_ ->
                parse "[(X)] correct\n[( )] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ] ]
                                    , solution = SingleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three options, only one checked" <|
            \_ ->
                parse "[( )] one\n[(X)] two\n[( )] three\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "one" ], [ chars "two" ], [ chars "three" ] ]
                                    , solution = SingleChoice [ False, True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "options prefixed with the optional -/+/* list marker" <|
            \_ ->
                parse "- [(X)] correct\n+ [( )] wrong\n* [( )] also wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ], [ chars "also wrong" ] ]
                                    , solution = SingleChoice [ True, False, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line ends the option list; indented text after it is not absorbed as a continuation" <|
            \_ ->
                parse "[(X)] correct\n\n    continued\n[( )] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ] ]
                                    , solution = SingleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        , paragraph "continued [( )] wrong"
                        ]
        ]


{-| The checked-marker is matched case-insensitively (`x` or `X`), exactly as
for task-list items - fuzz both casings via the `[xX]` character class.
-}
checkedCase_fuzz_Suite : Test
checkedCase_fuzz_Suite =
    describe "a checked option is recognized regardless of x/X casing"
        [ fuzz (fuzzRegex "[xX]") "wrapped in [[<x-or-X>]] ...\\n" <|
            \checkedChar ->
                parse ("[[" ++ checkedChar ++ "]] correct\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , fuzz (fuzzRegex "[xX]") "wrapped in [(<x-or-X>)] ...\\n" <|
            \checkedChar ->
                parse ("[(" ++ checkedChar ++ ")] correct\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ] ]
                                    , solution = SingleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| Trailing `[[?]]`-marked blocks attach as hints to the preceding quiz.
-}
hints_Suite : Test
hints_Suite =
    describe "generating quiz hints" <|
        [ test "a single [[?]] block becomes one hint" <|
            \_ ->
                parse "[[X]] correct\n[[ ]] wrong\n[[?]] Here is a hint.\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = [ [ chars "Here is a hint." ] ]
                            }
                            Nothing
                        ]
        , test "multiple stacked [[?]] blocks become multiple hints, in order" <|
            \_ ->
                parse "[[X]] correct\n[[ ]] wrong\n[[?]] First hint.\n[[?]] Second hint.\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "correct" ], [ chars "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = [ [ chars "First hint." ], [ chars "Second hint." ] ]
                            }
                            Nothing
                        ]
        ]


{-| `[[!]]` (optionally with a leading `-`) marks a quiz as having no
programmatic solution at all - graded manually / always "open". This used to
be shadowed by `Survey.Parser`'s Vector-survey alternative (which absorbed a
bare `[[!]]` as a one-option survey with id `"!"`, since `Survey` is tried
before `Quiz` in `elements`) - fixed by excluding `"!"`/`"?"` as Survey
option ids in `Survey.Parser.id_str`, since those are reserved for Quiz's
generic-marker and hints syntax respectively.
-}
generic_Suite : Test
generic_Suite =
    describe "generating generic (no-solution) quiz markers" <|
        [ test "[[!]] alone" <|
            \_ ->
                parse "[[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
        , test "- [[!]] with the optional leading dash" <|
            \_ ->
                parse "- [[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
        ]


{-| A single-column `[(ColA)]` header used to be indistinguishable from - and
get shadowed by - `Survey.Parser`'s Vector-survey alternative (`[(id)]
content`), which is tried first in `elements`: with only one option required,
Survey's vector would happily claim just the header line as a one-option
survey, starving `Quiz.Matrix.Parser` of its header. Requiring
`Survey.Parser.vector` to have at least two options (see
`Parser.Block.Quiz.block_Suite` / `Parser.Block.Survey.categoricalVector_Suite`)
fixed that collision - but simply falling through to `Quiz.Matrix.Parser`
turned out to be its own trap: `Quiz.Matrix.Parser.header` used to accept a
single column too, and `rows` tolerates blank lines before each row, so a
completely unrelated single/multiple-choice list appearing _later_ in the
document - even separated by a blank line - could get silently absorbed as
that "matrix"'s rows (see `oneColumnDoesNotSwallowUnrelatedContent_Suite`
below for the concrete case that surfaced this). Fixed the same way as
Survey: `Quiz.Matrix.Parser.header` now also requires at least two columns
(a one-column "matrix" isn't meaningful anyway - it's just a plain choice
list), so a single-column header no longer reaches `Matrix_Type` at all -
the smallest header that does is still two columns, exactly as before.
-}
matrix_Suite : Test
matrix_Suite =
    describe "generating matrix quizzes ([(col)(col)] header + [(X)( )] rows)"
        [ test "two columns, single (radio-button) row" <|
            \_ ->
                parse "[(ColA)(ColB)]\n[(X)( )] Row1\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    , options = [ [ chars "Row1" ] ]
                                    , solution = Array.fromList [ SingleChoice [ True, False ] ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "bracket-style header columns ([col][col]) work the same as parenthesized ones" <|
            \_ ->
                parse "[[ColA][ColB]]\n[(X)( )] Row1\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    , options = [ [ chars "Row1" ] ]
                                    , solution = Array.fromList [ SingleChoice [ True, False ] ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three columns, single (radio-button) row" <|
            \_ ->
                parse "[(ColA)(ColB)(ColC)]\n[(X)( )(X)] Row1\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ], [ chars "ColC" ] ]
                                    , options = [ [ chars "Row1" ] ]
                                    , solution = Array.fromList [ SingleChoice [ True, False, True ] ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "two rows, both single (radio-button) choice" <|
            \_ ->
                parse "[(ColA)(ColB)]\n[(X)( )] Row1\n[( )(X)] Row2\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    , options = [ [ chars "Row1" ], [ chars "Row2" ] ]
                                    , solution =
                                        Array.fromList
                                            [ SingleChoice [ True, False ]
                                            , SingleChoice [ False, True ]
                                            ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "rows can independently mix single- ([( )]) and multiple-choice ([[ ]]) style" <|
            \_ ->
                parse "[(ColA)(ColB)]\n[(X)( )] Row1\n[[ ][X]] Row2\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    , options = [ [ chars "Row1" ], [ chars "Row2" ] ]
                                    , solution =
                                        Array.fromList
                                            [ SingleChoice [ True, False ]
                                            , MultipleChoice [ False, True ]
                                            ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| A `[[...]]` blank with no `|` (a plain fill-in-the-blank, not a
select/drag-and-drop list) embedded _within_ other chars text promotes
the whole paragraph into a `Multi_Type` quiz. Note: this only works because
there's text before the `[[...]]` on the line - a bracket group at the very
_start_ of a line is instead captured by `Survey.Parser`'s Select/Vector
alternatives (tried before Quiz/Paragraph), exactly like the Matrix-header
collision above - all of Survey's bracket-based parsers are anchored to the
_start_ of the line (after optional marker/spaces), so text before `[[...]]`
is what keeps this one out of their reach, not anything about "Paris" itself.
-}
multiGapText_Suite : Test
multiGapText_Suite =
    describe "generating gap-text (fill-in-the-blank) quizzes from inline [[...]] blanks"
        [ test "a blank embedded in a sentence promotes the paragraph to a Multi quiz" <|
            \_ ->
                parse "The capital of France is [[Paris]].\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Multi_Type
                                    { elements =
                                        [ Paragraph []
                                            [ chars "The capital of France is "
                                            , InlineTypes.Quiz ( String.fromFloat (toFloat (String.length "Paris" + 2) * 0.4) ++ "em", 0 ) []
                                            , chars "."
                                            ]
                                        ]
                                    , options = Array.fromList [ [] ]
                                    , solution = Array.fromList [ Block.Text "Paris" ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "two blanks in one sentence become two ordered gaps in a single Multi quiz" <|
            \_ ->
                parse "The capital of [[France]] is [[Paris]].\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Multi_Type
                                    { elements =
                                        [ Paragraph []
                                            [ chars "The capital of "
                                            , InlineTypes.Quiz ( String.fromFloat (toFloat (String.length "France" + 2) * 0.4) ++ "em", 0 ) []
                                            , chars " is "
                                            , InlineTypes.Quiz ( String.fromFloat (toFloat (String.length "Paris" + 2) * 0.4) ++ "em", 1 ) []
                                            , chars "."
                                            ]
                                        ]
                                    , options = Array.fromList [ [], [] ]
                                    , solution = Array.fromList [ Block.Text "France", Block.Text "Paris" ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a [[a|(b)|c]] blank embedded in a sentence becomes a select-dropdown gap" <|
            \_ ->
                parse "Pick one: [[foo|(bar)|baz]].\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Multi_Type
                                    { elements =
                                        [ Paragraph []
                                            [ chars "Pick one: "
                                            , InlineTypes.Quiz ( String.fromFloat (toFloat (String.length "foo|(bar)|baz" + 2) * 0.4) ++ "em", 0 ) []
                                            , chars "."
                                            ]
                                        ]
                                    , options = Array.fromList [ [ [ chars "foo" ], [ chars "bar" ], [ chars "baz" ] ] ]
                                    , solution = Array.fromList [ Block.Select False [ 1 ] ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


itemText_fuzz_Suite : Test
itemText_fuzz_Suite =
    describe "arbitrary option text is preserved as the option's paragraph content"
        [ fuzz words "wrapped in [[X]] ...\\n" <|
            \text ->
                parse ("[[X]] " ++ text ++ "\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars text ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , fuzz words "wrapped in [(X)] ...\\n" <|
            \text ->
                parse ("[(X)] " ++ text ++ "\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars text ] ]
                                    , solution = SingleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| A standalone `[[...]]`/`[->[...]]` line (nothing but optional leading
spaces before it) is a top-level `Block_Type` quiz, rather than the inline
gap-text promotion covered by `multiGapText_Suite` above - it's only reached
once `Vector_Type`'s `[[X]]`/`[[ ]]` checkbox-list parser and `Matrix_Type`'s
header parser both fail to match, since both are tried first in
`Quiz.Parser.parse`.

There's a further collision one level up: `Survey.Parser` is tried before
`Quiz.Parser` in `elements`, and it _also_ runs `Quiz.Block.Parser`
internally - to offer a Select/DragAndDrop _survey_ for the case where none
of the options is marked correct. When there IS a marked-correct option
(`Select`/`Drop` with a non-empty solution list, as in the select/drop tests
below), Survey's own conversion rejects it and backtracks, letting Quiz claim
it. A bare `Text`-solution line used to be a real gap here: Survey's
`Block.parse`-based conversion always rejects plain text (it only ever
produces a Select or DragAndDrop survey), but Survey's _other_ alternative -
a bracket-style categorical Vector-survey option `[[id]]` - used to accept
even a single such line as a one-option survey, silently absorbing it before
Quiz ever got a chance. Fixed by requiring `Survey.Parser.vector` to have at
least two options (a one-option survey is meaningless anyway), so a lone
`[[some answer]]` now correctly falls through to Quiz's `Block_Type` - see
the first test below.

-}
block_Suite : Test
block_Suite =
    describe "generating standalone Block-type quizzes ([[text]] / [[a|(b)|c]] / [->[a|(b)|c]])"
        [ test "a plain [[text]] line becomes a text fill-in-the-blank quiz" <|
            \_ ->
                parse "[[Berlin]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = Block_Type { options = [], solution = Block.Text "Berlin" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a [[a|(b)|c]] line becomes a select-dropdown quiz, correct option in parens" <|
            \_ ->
                parse "[[foo|(bar)|baz]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Block_Type
                                    { options = [ [ chars "foo" ], [ chars "bar" ], [ chars "baz" ] ]
                                    , solution = Block.Select False [ 1 ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a [->[a|(b)|c]] line becomes a drag-and-drop quiz, correct option in parens" <|
            \_ ->
                parse "[->[foo|(bar)|baz]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Block_Type
                                    { options = [ [ chars "foo" ], [ chars "bar" ], [ chars "baz" ] ]
                                    , solution = Block.Drop False False [ 1 ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| A standalone `[[text]]` fill-in-the-blank quiz followed - even across a
blank line - by an unrelated single/multiple-choice list must stay two
separate quizzes. This used to break: before `Quiz.Matrix.Parser.header`
required at least two columns, `[[Berlin]]` alone was _also_ a structurally
valid one-column bracket-style Matrix header, and `Quiz.Matrix.Parser.rows`
tolerates blank lines before each row - so it would greedily absorb the
following, entirely unrelated choice-list as this "matrix"'s rows, merging
two independent quizzes into one nonsensical one. See `matrix_Suite`'s
docstring for the full chain of collisions this sits at the end of.
-}
oneColumnDoesNotSwallowUnrelatedContent_Suite : Test
oneColumnDoesNotSwallowUnrelatedContent_Suite =
    describe "a standalone [[text]] quiz doesn't absorb an unrelated choice-list that happens to follow it"
        [ test "[[Berlin]], a blank line, then an unrelated single-choice list stay two separate quizzes" <|
            \_ ->
                parse "[[Berlin]]\n\n- [( )] test\n- [(X)] richtig\n- [( )] falsch\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = Block_Type { options = [], solution = Block.Text "Berlin" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        , Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "test" ], [ chars "richtig" ], [ chars "falsch" ] ]
                                    , solution = SingleChoice [ False, True, False ]
                                    }
                            , id = 1
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| A quiz's options may all be indented by a shared constant amount (e.g. to
visually nest a `[(X)]`/`[( )]` list under a preceding question paragraph),
same as a plain paragraph or list can be - `Lia.Markdown.Quiz.Vector.Parser`
runs each option through `Indent.check`, which strips exactly this kind of
shared leading indentation before matching the `[(...)]`/`[[...]]` marker.

Note this is a different case from a blank line splitting the list (see the
"a blank line ends the option list ..." cases in `multipleChoice_Suite`/
`singleChoice_Suite` above): each option here is still its own single line,
just uniformly shifted right - `Vector.Parser` only ever parses one `Inlines`
line per option, it doesn't support a multi-paragraph option body.
-}
indentedOptions_Suite : Test
indentedOptions_Suite =
    describe "a quiz's options can all be indented by a shared constant amount, same as a plain list"
        [ test "single-choice options indented under a preceding question, no blank line inside the list" <|
            \_ ->
                parse "What is the correct spelling of H(D)D?\n\n    [(X)] hard disk drive\n    [( )] hard desk drive\n    [(x)] hard disc drive\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What is the correct spelling of H(D)D?" ]
                        , Quiz []
                            { quiz =
                                Vector_Type
                                    { options =
                                        [ [ chars "hard disk drive" ]
                                        , [ chars "hard desk drive" ]
                                        , [ chars "hard disc drive" ]
                                        ]
                                    , solution = SingleChoice [ True, False, True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "multiple-choice options indented, with no preceding paragraph at all" <|
            \_ ->
                parse "    [[X]] one\n    [[ ]] two\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ chars "one" ], [ chars "two" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| Every quiz type - not just the `Vector_Type` covered by
`indentedOptions_Suite` above - accepts being shifted right by a shared
4-space indent, exactly like a plain Markdown list or paragraph would. This
also matters in practice since it's how a quiz gets visually nested under a
preceding question, or under a list item.
-}
indentedQuizTypes_Suite : Test
indentedQuizTypes_Suite =
    describe "quizzes of every type can be indented by 4 spaces"
        [ test "a matrix quiz, header and row both indented" <|
            \_ ->
                parse "    [(ColA)(ColB)]\n    [(X)( )] Row1\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Matrix_Type
                                    { headers = [ [ chars "ColA" ], [ chars "ColB" ] ]
                                    , options = [ [ chars "Row1" ] ]
                                    , solution = Array.fromList [ SingleChoice [ True, False ] ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a standalone [[text]] fill-in-the-blank quiz, indented" <|
            \_ ->
                parse "    [[Berlin]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = Block_Type { options = [], solution = Block.Text "Berlin" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a generic (no-solution) [[!]] marker, indented" <|
            \_ ->
                parse "    [[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
        ]
