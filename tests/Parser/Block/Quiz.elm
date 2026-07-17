module Parser.Block.Quiz exposing
    ( block_Suite
    , checkedCase_fuzz_Suite
    , generic_Suite
    , hints_Suite
    , indentedOptions_Suite
    , indentedQuizTypes_Suite
    , itemText_fuzz_Suite
    , matrixIndentation_Suite
    , matrixWithHintsAndSolution_Suite
    , matrixWithHints_Suite
    , matrix_Suite
    , multiGapText_Suite
    , multipleChoice_Suite
    , nestedQuiz_Suite
    , oneColumnDoesNotSwallowUnrelatedContent_Suite
    , optionWithCodeFence_Suite
    , singleChoice_Suite
    )

import Array
import Expect
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Inline.Types as InlineTypes
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Types exposing (Type(..))
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex, words)
import Parser.Block.Fixtures exposing (bulletList, paragraph, parse)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, fuzz, test)


multipleChoice_Suite : Test
multipleChoice_Suite =
    describe "generating multiple-choice quizzes ([[ ]]/[[X]])"
        [ test "a checked and an unchecked option" <|
            \_ ->
                {- [[X]] correct
                   [[ ]] wrong
                -}
                parse "[[X]] correct\n[[ ]] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three options, two of them checked" <|
            \_ ->
                {- [[X]] one
                   [[X]] two
                   [[ ]] three
                -}
                parse "[[X]] one\n[[X]] two\n[[ ]] three\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "one" ], [ paragraph "two" ], [ paragraph "three" ] ]
                                    , solution = MultipleChoice [ True, True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "options prefixed with the optional -/+/* list marker" <|
            \_ ->
                {- - [[X]] correct
                   + [[ ]] wrong
                   * [[X]] also correct
                -}
                parse "- [[X]] correct\n+ [[ ]] wrong\n* [[X]] also correct\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ], [ paragraph "also correct" ] ]
                                    , solution = MultipleChoice [ True, False, True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line followed by matching (4-space) indentation continues the option as a second paragraph" <|
            \_ ->
                {- [[X]] correct

                       continued
                   [[ ]] wrong
                -}
                parse "[[X]] correct\n\n    continued\n[[ ]] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct", paragraph "continued" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line followed by insufficient indentation still ends the option list; indented text after it is not absorbed as a continuation" <|
            \_ ->
                {- [[X]] correct

                     continued
                   [[ ]] wrong
                -}
                parse "[[X]] correct\n\n  continued\n[[ ]] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        , paragraph "continued [[ ]] wrong"
                        ]
        , test "a bare marker with no content on the same line fails as a Vector option, falls through to Block_Type" <|
            \_ ->
                {- [[X]] -}
                parse "[[X]]\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz = Block_Type { options = [], solution = Block.Text "X" }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "an option's content may contain a nested bullet list, as a second block" <|
            \_ ->
                {- [[X]] correct

                   - one
                   - two
                -}
                parse "[[X]] correct\n\n    - one\n    - two\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options =
                                        [ [ paragraph "correct"
                                          , bulletList [ "one", "two" ]
                                          ]
                                        ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


singleChoice_Suite : Test
singleChoice_Suite =
    describe "generating single-choice quizzes ([( )]/[(X)])"
        [ test "a checked and an unchecked option" <|
            \_ ->
                {- [(X)] correct
                   [( )] wrong
                -}
                parse "[(X)] correct\n[( )] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = SingleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three options, only one checked" <|
            \_ ->
                {- [( )] one
                   [(X)] two
                   [( )] three
                -}
                parse "[( )] one\n[(X)] two\n[( )] three\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "one" ], [ paragraph "two" ], [ paragraph "three" ] ]
                                    , solution = SingleChoice [ False, True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "options prefixed with the optional -/+/* list marker" <|
            \_ ->
                {- - [(X)] correct
                   + [( )] wrong
                   * [( )] also wrong
                -}
                parse "- [(X)] correct\n+ [( )] wrong\n* [( )] also wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ], [ paragraph "also wrong" ] ]
                                    , solution = SingleChoice [ True, False, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line followed by matching (4-space) indentation continues the option as a second paragraph" <|
            \_ ->
                {- [(X)] correct

                       continued
                   [( )] wrong
                -}
                parse "[(X)] correct\n\n    continued\n[( )] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct", paragraph "continued" ], [ paragraph "wrong" ] ]
                                    , solution = SingleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "a blank line followed by insufficient indentation still ends the option list; indented text after it is not absorbed as a continuation" <|
            \_ ->
                {- [(X)] correct

                     continued
                   [( )] wrong
                -}
                parse "[(X)] correct\n\n  continued\n[( )] wrong\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ] ]
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
                {- [[x]] correct -}
                parse ("[[" ++ checkedChar ++ "]] correct\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , fuzz (fuzzRegex "[xX]") "wrapped in [(<x-or-X>)] ...\\n" <|
            \checkedChar ->
                {- [(X)] correct -}
                parse ("[(" ++ checkedChar ++ ")] correct\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ] ]
                                    , solution = SingleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| Trailing `[[?]]`-marked blocks attach as hints to the preceding quiz. Like
Vector-options, a hint's content may span multiple blocks (see the
multi-paragraph case below), indented by 4 spaces relative to its `[[?]]`
marker.
-}
hints_Suite : Test
hints_Suite =
    describe "generating quiz hints" <|
        [ test "a single [[?]] block becomes one hint" <|
            \_ ->
                {- [[X]] correct
                   [[ ]] wrong
                   [[?]] Here is a hint.
                -}
                parse "[[X]] correct\n[[ ]] wrong\n[[?]] Here is a hint.\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = [ [ paragraph "Here is a hint." ] ]
                            }
                            Nothing
                        ]
        , test "multiple stacked [[?]] blocks become multiple hints, in order" <|
            \_ ->
                {- [[X]] correct
                   [[ ]] wrong
                   [[?]] First hint.
                   [[?]] Second hint.
                -}
                parse "[[X]] correct\n[[ ]] wrong\n[[?]] First hint.\n[[?]] Second hint.\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = [ [ paragraph "First hint." ], [ paragraph "Second hint." ] ]
                            }
                            Nothing
                        ]
        , test "a hint's content may span multiple paragraphs" <|
            \_ ->
                {- [[X]] correct
                   [[ ]] wrong
                   [[?]] hint one

                       hint continued
                   [[?]] hint two
                -}
                parse "[[X]] correct\n[[ ]] wrong\n[[?]] hint one\n\n    hint continued\n[[?]] hint two\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints =
                                [ [ paragraph "hint one", paragraph "hint continued" ]
                                , [ paragraph "hint two" ]
                                ]
                            }
                            Nothing
                        ]
        , test "a blank line between the last option and the first [[?]] hint is tolerated" <|
            \_ ->
                -- Unlike `Vector.parse` itself (reached through `blocks`'s own
                -- whitespace-eating dispatch), `Quiz.Parser.hints` is called
                -- directly right after the quiz type is parsed - a leading
                -- blank line before the first hint must be skipped explicitly,
                -- see `Vector.Parser.blockGroup`.
                {- [[X]] correct
                   [[ ]] wrong

                   [[?]] Here is a hint.
                -}
                parse "[[X]] correct\n[[ ]] wrong\n\n[[?]] Here is a hint.\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "correct" ], [ paragraph "wrong" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = [ [ paragraph "Here is a hint." ] ]
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
                {- [[!]] -}
                parse "[[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
        , test "- [[!]] with the optional leading dash" <|
            \_ ->
                {- - [[!]] -}
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
                {- [(ColA)(ColB)]
                   [(X)( )] Row1
                -}
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
                {- [[ColA][ColB]]
                   [(X)( )] Row1
                -}
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
                {- [(ColA)(ColB)(ColC)]
                   [(X)( )(X)] Row1
                -}
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
                {- [(ColA)(ColB)]
                   [(X)( )] Row1
                   [( )(X)] Row2
                -}
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
                {- [(ColA)(ColB)]
                   [(X)( )] Row1
                   [[ ][X]] Row2
                -}
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


{-| A matrix's header and rows independently accept every combination of an
optional `-` marker prefix and an optional shared 4-space indent, in either
header bracket style (`(col)` for single-choice rows, `[col]` for
multiple-choice rows) - all eight combinations below produce the identical
structure. Unlike `Survey.Parser` (see
`Parser.Block.Survey.matrixIndentation_Suite`), `Quiz.Matrix.Parser.header`
already handled indent-then-dash correctly (`maybe Indent.check |> ignore
spaces |> ignore (regex "...")`, spaces consumed _before_ the marker regex
runs), so no fix was needed here - this suite only pins down that already
appropriate behavior.
-}
matrixIndentation_Suite : Test
matrixIndentation_Suite =
    let
        expect solutions =
            [ Quiz []
                { quiz =
                    Matrix_Type
                        { headers = [ [ chars "A" ], [ chars "B" ] ]
                        , options = [ [ chars "Row1" ], [ chars "Row2" ] ]
                        , solution = Array.fromList solutions
                        }
                , id = 0
                , hints = []
                }
                Nothing
            ]
    in
    describe "a matrix's header and rows accept every combination of optional dash marker and shared indent"
        [ test "no indent, no dash, paren-style header (single-choice rows)" <|
            \_ ->
                {- [(A)(B)]
                   [(X)( )] Row1
                   [( )(X)] Row2
                -}
                parse "[(A)(B)]\n[(X)( )] Row1\n[( )(X)] Row2\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "no indent, no dash, bracket-style header (multiple-choice rows)" <|
            \_ ->
                {- [[A][B]]
                   [[X][ ]] Row1
                   [[ ][X]] Row2
                -}
                parse "[[A][B]]\n[[X][ ]] Row1\n[[ ][X]] Row2\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "no indent, dash, paren-style header (single-choice rows)" <|
            \_ ->
                {- - [(A)(B)]
                   - [(X)( )] Row1
                   - [( )(X)] Row2
                -}
                parse "- [(A)(B)]\n- [(X)( )] Row1\n- [( )(X)] Row2\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "no indent, dash, bracket-style header (multiple-choice rows)" <|
            \_ ->
                {- - [[A][B]]
                   - [[X][ ]] Row1
                   - [[ ][X]] Row2
                -}
                parse "- [[A][B]]\n- [[X][ ]] Row1\n- [[ ][X]] Row2\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "indented, no dash, paren-style header (single-choice rows)" <|
            \_ ->
                {- [(A)(B)]
                   [(X)( )] Row1
                   [( )(X)] Row2
                -}
                parse "    [(A)(B)]\n    [(X)( )] Row1\n    [( )(X)] Row2\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "indented, no dash, bracket-style header (multiple-choice rows)" <|
            \_ ->
                {- [[A][B]]
                   [[X][ ]] Row1
                   [[ ][X]] Row2
                -}
                parse "    [[A][B]]\n    [[X][ ]] Row1\n    [[ ][X]] Row2\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "indented, dash, paren-style header (single-choice rows)" <|
            \_ ->
                {- - [(A)(B)]
                   - [(X)( )] Row1
                   - [( )(X)] Row2
                -}
                parse "    - [(A)(B)]\n    - [(X)( )] Row1\n    - [( )(X)] Row2\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "indented, dash, bracket-style header (multiple-choice rows)" <|
            \_ ->
                {- - [[A][B]]
                   - [[X][ ]] Row1
                   - [[ ][X]] Row2
                -}
                parse "    - [[A][B]]\n    - [[X][ ]] Row1\n    - [[ ][X]] Row2\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        ]


{-| A `[[?]]` hint attaches to a matrix quiz exactly the same way it does to a
Vector quiz (see `hints_Suite`) - `Quiz.Parser.hints` runs generically after
whichever quiz type just finished parsing, so it doesn't care whether that
was a `Matrix_Type`, nor which of the eight indent/dash/header-style
combinations from `matrixIndentation_Suite` produced it.
-}
matrixWithHints_Suite : Test
matrixWithHints_Suite =
    let
        expect solutions =
            [ Quiz []
                { quiz =
                    Matrix_Type
                        { headers = [ [ chars "A" ], [ chars "B" ] ]
                        , options = [ [ chars "Row1" ], [ chars "Row2" ] ]
                        , solution = Array.fromList solutions
                        }
                , id = 0
                , hints = [ [ paragraph "Here is a hint." ] ]
                }
                Nothing
            ]
    in
    describe "a [[?]] hint attaches to a matrix quiz, in every indent/dash/header-style combination"
        [ test "no indent, no dash, paren-style header" <|
            \_ ->
                {- [(A)(B)]
                   [(X)( )] Row1
                   [( )(X)] Row2
                   [[?]] Here is a hint.
                -}
                parse "[(A)(B)]\n[(X)( )] Row1\n[( )(X)] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "no indent, no dash, bracket-style header" <|
            \_ ->
                {- [[A][B]]
                   [[X][ ]] Row1
                   [[ ][X]] Row2
                   [[?]] Here is a hint.
                -}
                parse "[[A][B]]\n[[X][ ]] Row1\n[[ ][X]] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "no indent, dash, paren-style header" <|
            \_ ->
                {- - [(A)(B)]
                   - [(X)( )] Row1
                   - [( )(X)] Row2
                   [[?]] Here is a hint.
                -}
                parse "- [(A)(B)]\n- [(X)( )] Row1\n- [( )(X)] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "no indent, dash, bracket-style header" <|
            \_ ->
                {- - [[A][B]]
                   - [[X][ ]] Row1
                   - [[ ][X]] Row2
                   [[?]] Here is a hint.
                -}
                parse "- [[A][B]]\n- [[X][ ]] Row1\n- [[ ][X]] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "indented, no dash, paren-style header" <|
            \_ ->
                {- [(A)(B)]
                       [(X)( )] Row1
                       [( )(X)] Row2
                   [[?]] Here is a hint.
                -}
                parse "    [(A)(B)]\n    [(X)( )] Row1\n    [( )(X)] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "indented, no dash, bracket-style header" <|
            \_ ->
                {- [[A][B]]
                       [[X][ ]] Row1
                       [[ ][X]] Row2
                   [[?]] Here is a hint.
                -}
                parse "    [[A][B]]\n    [[X][ ]] Row1\n    [[ ][X]] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        , test "indented, dash, paren-style header" <|
            \_ ->
                {- - [(A)(B)]
                       - [(X)( )] Row1
                       - [( )(X)] Row2
                   [[?]] Here is a hint.
                -}
                parse "    - [(A)(B)]\n    - [(X)( )] Row1\n    - [( )(X)] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ])
        , test "indented, dash, bracket-style header" <|
            \_ ->
                {- - [[A][B]]
                       - [[X][ ]] Row1
                       - [[ ][X]] Row2
                   [[?]] Here is a hint.
                -}
                parse "    - [[A][B]]\n    - [[X][ ]] Row1\n    - [[ ][X]] Row2\n[[?]] Here is a hint.\n"
                    |> Expect.equal (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ])
        ]


{-| A trailing `***...***` block (see `Lia.Markdown.Parser.solution`) reveals
an "official answer" once the quiz is solved - it may itself span multiple
Markdown blocks. It attaches the same way regardless of the preceding quiz's
indent/dash/header-style (that parser is independent of
`Quiz.Vector.Parser`/`Quiz.Matrix.Parser` entirely, so only two representative
combinations are covered here, not all eight - see `matrixIndentation_Suite`
for proof that the marker styles themselves are already independently
verified). The opening `***` must directly follow the quiz's last line (here:
the hint) - a blank line in between would prevent it from attaching and leave
it as a separate, unrelated `Problem` block instead.
-}
matrixWithHintsAndSolution_Suite : Test
matrixWithHintsAndSolution_Suite =
    let
        expect solutions answer =
            [ Quiz []
                { quiz =
                    Matrix_Type
                        { headers = [ [ chars "A" ], [ chars "B" ] ]
                        , options = [ [ chars "Row1" ], [ chars "Row2" ] ]
                        , solution = Array.fromList solutions
                        }
                , id = 0
                , hints = [ [ paragraph "Here is a hint." ] ]
                }
                (Just ( answer, 0 ))
            ]
    in
    describe "a trailing ***...*** answer block attaches after a matrix quiz's hint"
        [ test "no indent, no dash, paren-style header, single-block answer" <|
            \_ ->
                {- [(A)(B)]
                   [(X)( )] Row1
                   [( )(X)] Row2
                   [[?]] Here is a hint.
                   ***

                   an answer

                   ***
                -}
                parse "[(A)(B)]\n[(X)( )] Row1\n[( )(X)] Row2\n[[?]] Here is a hint.\n***\n\nan answer\n\n***\n"
                    |> Expect.equal
                        (expect [ SingleChoice [ True, False ], SingleChoice [ False, True ] ] [ paragraph "an answer" ])
        , test "indented, dash, bracket-style header, multi-block answer" <|
            \_ ->
                {- - [[A][B]]
                       - [[X][ ]] Row1
                       - [[ ][X]] Row2
                   [[?]] Here is a hint.
                   ***

                   an answer from multiple

                   blocks

                   ***
                -}
                parse "    - [[A][B]]\n    - [[X][ ]] Row1\n    - [[ ][X]] Row2\n[[?]] Here is a hint.\n***\n\nan answer from multiple\n\nblocks\n\n***\n"
                    |> Expect.equal
                        (expect [ MultipleChoice [ True, False ], MultipleChoice [ False, True ] ]
                            [ paragraph "an answer from multiple", paragraph "blocks" ]
                        )
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
                {- The capital of France is [[Paris]]. -}
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
                {- The capital of [[France]] is [[Paris]]. -}
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
                {- Pick one: [[foo|(bar)|baz]]. -}
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
                {- [[X]] example text -}
                parse ("[[X]] " ++ text ++ "\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph text ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , fuzz words "wrapped in [(X)] ...\\n" <|
            \text ->
                {- [(X)] example text -}
                parse ("[(X)] " ++ text ++ "\n")
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph text ] ]
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
                {- [[Berlin]] -}
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
                {- [[foo|(bar)|baz]] -}
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
                {- [->[foo|(bar)|baz]] -}
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
                {- [[Berlin]]

                   - [( )] test
                   - [(X)] richtig
                   - [( )] falsch
                -}
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
                                    { options = [ [ paragraph "test" ], [ paragraph "richtig" ], [ paragraph "falsch" ] ]
                                    , solution = SingleChoice [ False, True, False ]
                                    }
                            , id = 1
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| A quiz option's content is indented relative to its own marker, exactly
like a Task-list item's content (see `Task.Parser`/`Vector.Parser.item`). The
required continuation indent is measured dynamically from each option's own
marker column (not a fixed absolute amount) - so a group of sibling options
that are all uniformly offset under a preceding question (to visually nest
the whole list, with no per-option nesting intended) stay flat siblings of
_each other_, since none of them is indented any further than the others.
Content indented _further than that shared baseline_ still nests as a
sub-quiz of the preceding option instead (see `nestedQuiz_Suite` below) -
this dynamic, per-marker baseline is what distinguishes the two cases,
mirroring CommonMark's own list-item content-indentation rule.
-}
indentedOptions_Suite : Test
indentedOptions_Suite =
    describe "a quiz's options can all be indented by a shared constant amount, same as a plain list"
        [ test "single-choice options indented under a preceding question stay flat siblings of each other" <|
            \_ ->
                {- What is the correct spelling of H(D)D?

                   [(X)] hard disk drive
                   [( )] hard desk drive
                   [(x)] hard disc drive
                -}
                parse "What is the correct spelling of H(D)D?\n\n    [(X)] hard disk drive\n    [( )] hard desk drive\n    [(x)] hard disc drive\n"
                    |> Expect.equal
                        [ Paragraph [] [ chars "What is the correct spelling of H(D)D?" ]
                        , Quiz []
                            { quiz =
                                Vector_Type
                                    { options =
                                        [ [ paragraph "hard disk drive" ]
                                        , [ paragraph "hard desk drive" ]
                                        , [ paragraph "hard disc drive" ]
                                        ]
                                    , solution = SingleChoice [ True, False, True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "multiple-choice options indented, with no preceding paragraph at all, also stay flat siblings" <|
            \_ ->
                {- [[X]] one
                   [[ ]] two
                -}
                parse "    [[X]] one\n    [[ ]] two\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "one" ], [ paragraph "two" ] ]
                                    , solution = MultipleChoice [ True, False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "only the first option's own marker may be indented on its own, staying a single flat option" <|
            \_ ->
                {- [[X]] one -}
                parse "    [[X]] one\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "one" ] ]
                                    , solution = MultipleChoice [ True ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| An option's block content may itself contain a nested Quiz, to build a
sub-question that only makes sense once the outer option is picked. The
nested quiz's marker must be indented _further_ than its enclosing option's
own marker column (here: `- [(X)]` starts at column 0, so 4 spaces is enough)

  - see `indentedOptions_Suite` above for the sibling-vs-nested distinction this
    relies on.

-}
nestedQuiz_Suite : Test
nestedQuiz_Suite =
    describe "an option's content may itself contain a nested Quiz"
        [ test "a single-choice option containing a nested multiple-choice quiz" <|
            \_ ->
                {- [(X)] dies ist ein absatz

                   das ist ein anderer absatz

                   [[X]] eine zeile mit einrückung
                -}
                parse "[(X)] dies ist ein absatz\n\n    das ist ein anderer absatz\n\n    [[X]] eine zeile mit einrückung\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options =
                                        [ [ paragraph "dies ist ein absatz"
                                          , paragraph "das ist ein anderer absatz"
                                          , Quiz []
                                                { quiz =
                                                    Vector_Type
                                                        { options = [ [ paragraph "eine zeile mit einrückung" ] ]
                                                        , solution = MultipleChoice [ True ]
                                                        }
                                                , id = 0
                                                , hints = []
                                                }
                                                Nothing
                                          ]
                                        ]
                                    , solution = SingleChoice [ True ]
                                    }
                            , id = 1
                            , hints = []
                            }
                            Nothing
                        ]
        ]


{-| Regression coverage for an off-by-one in the dynamic per-option indent
measurement (see `Vector.Parser.item`'s `withColumn` usage): `Combine`
columns are 0-indexed, not 1-indexed, so a naive `col - 1 + 4` computed one
space too few, causing an option's fenced code block (which - unlike a plain
paragraph or list - requires its indentation to match _exactly_, with zero
tolerance) to fail to parse as nested content and fall back to garbled inline
text instead.
-}
optionWithCodeFence_Suite : Test
optionWithCodeFence_Suite =
    describe "an option's content may contain a fenced code block"
        [ test "a single-choice option containing a highlighted JS code fence" <|
            \_ ->
                {- [( )] Beispiel 1

                   ``` js
                   console.log("hi")
                   ```
                -}
                parse "[( )] Beispiel 1\n\n    ``` js\n    console.log(\"hi\")\n    ```\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options = [ [ paragraph "Beispiel 1", Code (Code.Highlight 0) ] ]
                                    , solution = SingleChoice [ False ]
                                    }
                            , id = 0
                            , hints = []
                            }
                            Nothing
                        ]
        , test "three single-choice options each containing their own code fence stay flat siblings" <|
            \_ ->
                {- -[( )] Beispiel 1

                       ``` js
                       console.log(1)
                       ```
                   -[(X)] Beispiel 2

                       ``` js
                       console.log(2)
                       ```
                   -[( )] Beispiel 3

                       ``` js
                       console.log(3)
                       ```
                -}
                parse "-[( )] Beispiel 1\n\n    ``` js\n    console.log(1)\n    ```\n-[(X)] Beispiel 2\n\n    ``` js\n    console.log(2)\n    ```\n-[( )] Beispiel 3\n\n    ``` js\n    console.log(3)\n    ```\n"
                    |> Expect.equal
                        [ Quiz []
                            { quiz =
                                Vector_Type
                                    { options =
                                        [ [ paragraph "Beispiel 1", Code (Code.Highlight 0) ]
                                        , [ paragraph "Beispiel 2", Code (Code.Highlight 1) ]
                                        , [ paragraph "Beispiel 3", Code (Code.Highlight 2) ]
                                        ]
                                    , solution = SingleChoice [ False, True, False ]
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
                {- [(ColA)(ColB)]
                   [(X)( )] Row1
                -}
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
                {- [[Berlin]] -}
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
                {- [[!]] -}
                parse "    [[!]]\n"
                    |> Expect.equal
                        [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
        ]
