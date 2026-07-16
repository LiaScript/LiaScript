module Parser.Block.Task exposing
    ( checkedCase_fuzz_Suite
    , marker_fuzz_Suite
    , nested_Suite
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


{-| A task item's content is `Blocks`, exactly like a bullet/ordered-list
item (see `Parser.Block.Lists.nested_Suite`) - it can contain a whole nested
task list, indented one level (4 spaces, matching `Task.Parser.item`'s own
`Indent.push "    "`).

Each task list - nested or not - gets its own entry in `task_vector`, pushed
at the point its own `Task.Parser.parse` finishes. Since the nested list is
parsed as part of building its parent item's content, it finishes *first*,
so the nested list ends up at `id = 0` and the outer one at `id = 1` - the
`task_vector` index reflects parse-completion order, not source order.
-}
nested_Suite : Test
nested_Suite =
    describe "a task item can contain a nested task list, indented one level"
        [ test "a nested task list under the first item" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState "- [ ] item one\n    - [ ] nested one\n    - [x] nested two\n- [x] item two\n"
                in
                Expect.all
                    [ \_ ->
                        blocks
                            |> Expect.equal
                                [ Task []
                                    { task =
                                        [ [ paragraph "item one"
                                          , Task []
                                                { task =
                                                    [ [ paragraph "nested one" ]
                                                    , [ paragraph "nested two" ]
                                                    ]
                                                , id = 0
                                                }
                                          ]
                                        , [ paragraph "item two" ]
                                        ]
                                    , id = 1
                                    }
                                ]
                    , \_ ->
                        state.task_vector
                            |> Array.toList
                            |> List.map .state
                            |> Expect.equal
                                [ Array.fromList [ False, True ] -- nested list (id 0)
                                , Array.fromList [ False, True ] -- outer list (id 1)
                                ]
                    ]
                    ()
        ]
