module Parser.Block.Task exposing
    ( checkedCase_fuzz_Suite
    , marker_fuzz_Suite
    , task_Suite
    )

import Array
import Expect
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex)
import Parser.Block.Fixtures exposing (paragraph, parseWithState)
import Test exposing (Test, describe, fuzz, test)


task_Suite : Test
task_Suite =
    describe "generating GitHub-flavored task lists"
        [ test "a mix of checked and unchecked items renders its content and stores the checked-state vector" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState "- [ ] item one\n- [X] item two\n"
                in
                Expect.all
                    [ \_ ->
                        blocks
                            |> Expect.equal
                                [ Task []
                                    { task =
                                        [ [ paragraph "item one" ]
                                        , [ paragraph "item two" ]
                                        ]
                                    , id = 0
                                    }
                                ]
                    , \_ ->
                        state.task_vector
                            |> Array.get 0
                            |> Maybe.map .state
                            |> Expect.equal (Just (Array.fromList [ False, True ]))
                    ]
                    ()
        ]


{-| `-`, `+`, and `*` are all valid, interchangeable task-item markers, just
like for a regular bullet list - fuzz across all three via the `[-+*]`
character class.
-}
marker_fuzz_Suite : Test
marker_fuzz_Suite =
    describe "any of -, +, * works as a task-item marker"
        [ fuzz (fuzzRegex "[-+*]") "wrapped in <marker> [ ] ...\\n" <|
            \marker ->
                parseWithState (marker ++ " [ ] some task\n")
                    |> Tuple.first
                    |> Expect.equal
                        [ Task [] { task = [ [ paragraph "some task" ] ], id = 0 } ]
        ]


{-| The checked-marker is matched case-insensitively (`x` or `X`) - fuzz both
casings via the `[xX]` character class to confirm either always registers as
checked.
-}
checkedCase_fuzz_Suite : Test
checkedCase_fuzz_Suite =
    describe "a checked task item is recognized regardless of x/X casing"
        [ fuzz (fuzzRegex "[xX]") "wrapped in - [<x-or-X>] ...\\n" <|
            \checkedChar ->
                parseWithState ("- [" ++ checkedChar ++ "] some task\n")
                    |> Tuple.second
                    |> .task_vector
                    |> Array.get 0
                    |> Maybe.map .state
                    |> Expect.equal (Just (Array.fromList [ True ]))
        ]
