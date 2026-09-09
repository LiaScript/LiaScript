module Parser.Block.Code exposing
    ( executable_Suite
    , highlight_Suite
    , highlight_lang_fuzz_Suite
    , multiFile_Suite
    , output_Suite
    , project_Suite
    , title_Suite
    )

import Array
import Expect
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Types exposing (Code(..))
import Lia.Markdown.Types exposing (Block(..))
import LiaFuzz exposing (fuzzRegex)
import Parser.Block.Fixtures exposing (parseWithState)
import Test exposing (Test, describe, fuzz, test)


{-| Projects a parsed code model's first stored file down to just the fields
that matter for these tests, so we don't have to hand-construct a full
`Project`/`Version`/`Log`/... record just to compare against.
-}
firstFile :
    Array.Array { a | file : Array.Array { b | lang : String, name : String, code : String, visible : Bool } }
    -> Maybe { lang : String, name : String, code : String, visible : Bool }
firstFile vector =
    vector
        |> Array.get 0
        |> Maybe.andThen (.file >> Array.get 0)
        |> Maybe.map (\f -> { lang = f.lang, name = f.name, code = f.code, visible = f.visible })


highlight_Suite : Test
highlight_Suite =
    describe "generating highlighted (non-executable) code blocks"
        [ test "a fenced code block becomes Highlight 0 and stores its language/code" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState "```elm\nsome code\n```\n"
                in
                Expect.all
                    [ \_ -> blocks |> Expect.equal [ Code (Highlight 0) ]
                    , \_ ->
                        state.code_model.highlight
                            |> firstFile
                            |> Expect.equal (Just { lang = "elm", name = "", code = "some code", visible = True })
                    ]
                    ()
        , test "a second fenced code block becomes Highlight 1" <|
            \_ ->
                parseWithState "```elm\nfirst\n```\n\n```elm\nsecond\n```\n"
                    |> Tuple.first
                    |> Expect.equal [ Code (Highlight 0), Code (Highlight 1) ]
        ]


executable_Suite : Test
executable_Suite =
    describe "generating executable code blocks (a fenced block followed by <script>)"
        [ test "a fenced block with a <script> tag becomes Evaluate 0 and stores its language/code" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState "```js\nconsole.log(1)\n```\n<script>console.log(1)</script>\n"
                in
                Expect.all
                    [ \_ -> blocks |> Expect.equal [ Code (Evaluate 0) ]
                    , \_ ->
                        state.code_model.evaluate
                            |> firstFile
                            |> Expect.equal (Just { lang = "js", name = "", code = "console.log(1)", visible = True })
                    ]
                    ()
        ]


allFiles :
    Array.Array { a | file : Array.Array { b | lang : String, name : String, code : String, visible : Bool } }
    -> Maybe (List { lang : String, name : String, code : String, visible : Bool })
allFiles vector =
    vector
        |> Array.get 0
        |> Maybe.map
            (.file
                >> Array.toList
                >> List.map (\f -> { lang = f.lang, name = f.name, code = f.code, visible = f.visible })
            )


title_Suite : Test
title_Suite =
    describe "generating fenced code blocks with an explicit title/visibility flag"
        [ test "a +title marks the snippet visible with the given name" <|
            \_ ->
                parseWithState "```elm +My Title\nsome code\n```\n"
                    |> Tuple.second
                    |> .code_model
                    |> .highlight
                    |> firstFile
                    |> Expect.equal (Just { lang = "elm", name = "My Title", code = "some code", visible = True })
        , test "a -title marks the snippet hidden with the given name" <|
            \_ ->
                parseWithState "```elm -My Title\nsome code\n```\n"
                    |> Tuple.second
                    |> .code_model
                    |> .highlight
                    |> firstFile
                    |> Expect.equal (Just { lang = "elm", name = "My Title", code = "some code", visible = False })
        ]


{-| Consecutive fenced blocks at the same indentation combine into a single
multi-file snippet group (one `Code` value with several `File`s), rather than
becoming separate `Code` blocks.
-}
multiFile_Suite : Test
multiFile_Suite =
    describe "generating multi-file code snippet groups"
        [ test "two adjacent fenced blocks become one Highlight with two files" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState "```elm\nfile1\n```\n```js\nfile2\n```\n"
                in
                Expect.all
                    [ \_ -> blocks |> Expect.equal [ Code (Highlight 0) ]
                    , \_ ->
                        state.code_model.highlight
                            |> allFiles
                            |> Expect.equal
                                (Just
                                    [ { lang = "elm", name = "", code = "file1", visible = True }
                                    , { lang = "js", name = "", code = "file2", visible = True }
                                    ]
                                )
                    ]
                    ()
        ]


{-| A "Project" (docs' term) is just the multi-file grouping from
`multiFile_Suite` made executable by a trailing `<script>` - i.e. it becomes
one `Evaluate`, not `Highlight`, with all of its files preserved (each
keeping its own name/visibility from its `+`/`-title` marker). The `<script>`
body itself (with its `@input`/`@input(n)` markers) isn't stored on the
`Project` record at all - see `Lia.Markdown.Effect.Model`'s `javascript`
array instead, which is out of scope for these parser-focused tests.
-}
project_Suite : Test
project_Suite =
    describe "generating an executable multi-file project"
        [ test "two named files with a trailing <script> become one Evaluate with both files" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState
                            ("``` js -EvalScript.js\n"
                                ++ "let who = data.name;\n"
                                ++ "```\n"
                                ++ "``` json +Data.json\n"
                                ++ "{\"name\": \"Sammy\"}\n"
                                ++ "```\n"
                                ++ "<script>\n"
                                ++ "  let data = @input(1);\n"
                                ++ "  @input\n"
                                ++ "</script>\n"
                            )
                in
                Expect.all
                    [ \_ -> blocks |> Expect.equal [ Code (Evaluate 0) ]
                    , \_ ->
                        state.code_model.evaluate
                            |> allFiles
                            |> Expect.equal
                                (Just
                                    [ { lang = "js", name = "EvalScript.js", code = "let who = data.name;", visible = False }
                                    , { lang = "json", name = "Data.json", code = "{\"name\": \"Sammy\"}", visible = True }
                                    ]
                                )
                    ]
                    ()
        ]


{-| A trailing fenced block whose title is exactly `@output` (case-insensitive,
no `+`/`-` prefix) isn't kept as an ordinary file - it's pulled out of the
project entirely and becomes that project's initial `log`, shown before the
user ever runs the code. This works the same for a plain `Highlight` project
(tested here, no `<script>` needed) as it does for an executable one.
-}
output_Suite : Test
output_Suite =
    describe "a trailing @output-titled block becomes the project's initial log, not a file"
        [ test "two real files plus an @output block: only the two files remain, and the log is non-empty" <|
            \_ ->
                let
                    ( blocks, state ) =
                        parseWithState
                            ("``` js -EvalScript.js\n"
                                ++ "let who = data.name;\n"
                                ++ "```\n"
                                ++ "``` json +Data.json\n"
                                ++ "{\"name\": \"Sammy\"}\n"
                                ++ "```\n"
                                ++ "``` text @output\n"
                                ++ "Sammy\n"
                                ++ "```\n"
                            )
                in
                Expect.all
                    [ \_ -> blocks |> Expect.equal [ Code (Highlight 0) ]
                    , \_ ->
                        state.code_model.highlight
                            |> allFiles
                            |> Maybe.map List.length
                            |> Expect.equal (Just 2)
                    , \_ ->
                        state.code_model.highlight
                            |> Array.get 0
                            |> Maybe.map (.log >> Log.isEmpty)
                            |> Expect.equal (Just False)
                    ]
                    ()
        ]


{-| Any word is accepted as the language identifier (it's just lower-cased,
not checked against a fixed set of known languages) - fuzz it.
-}
highlight_lang_fuzz_Suite : Test
highlight_lang_fuzz_Suite =
    describe "any word works as the fenced code block's language identifier"
        [ fuzz (fuzzRegex "[A-Za-z]{1,10}") "```<lang>\\ncode\\n```" <|
            \lang ->
                parseWithState ("```" ++ lang ++ "\ncode\n```\n")
                    |> Tuple.second
                    |> .code_model
                    |> .highlight
                    |> firstFile
                    |> Expect.equal (Just { lang = String.toLower lang, name = "", code = "code", visible = True })
        ]
