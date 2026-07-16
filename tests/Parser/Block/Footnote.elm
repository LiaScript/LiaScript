module Parser.Block.Footnote exposing
    ( multiParagraph_Suite
    , noBlockEmitted_Suite
    , standard_Suite
    , symbolKey_Suite
    )

{-| Block-level standard footnote definitions (`[^key]: ...`), as described in
the docs' "Standard-Footnotes" section - the marker/inline-definition forms
(`[^1]`, `[^1](text)`) live in `Parser.Inline.Basic` since they're parsed at
the inline layer; this module only covers the block-level `[^key]: ...`
definition list that a footnote mark refers to.
-}

import Dict
import Expect
import Lia.Markdown.Types as Markdown
import Parser.Block.Fixtures exposing (paragraph, parseWithState)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, test)


{-| A footnote definition doesn't itself become part of the returned
`Blocks` - it's consumed as a side effect that only populates the parser
state's `footnotes` dictionary, to be looked up later by whatever
`[^key]` mark referenced it.
-}
noBlockEmitted_Suite : Test
noBlockEmitted_Suite =
    describe "a footnote definition produces no Block of its own"
        [ test "[^1]: text\\n" <|
            \_ ->
                parseWithState "[^1]: text\n"
                    |> Tuple.first
                    |> Expect.equal []
        ]


standard_Suite : Test
standard_Suite =
    describe "generating standard footnote definitions ([^key]: ...)"
        [ test "a single-paragraph footnote is stored under its key" <|
            \_ ->
                parseWithState "[^1]: Some text.\n"
                    |> Tuple.second
                    |> .footnotes
                    |> Dict.get "1"
                    |> Expect.equal (Just [ paragraph "Some text." ])
        , test "several footnote definitions are all collected, keyed separately" <|
            \_ ->
                parseWithState "[^1]: first\n\n[^2]: second\n"
                    |> Tuple.second
                    |> .footnotes
                    |> Expect.equal
                        (Dict.fromList
                            [ ( "1", [ paragraph "first" ] )
                            , ( "2", [ paragraph "second" ] )
                            ]
                        )
        ]


multiParagraph_Suite : Test
multiParagraph_Suite =
    describe "a footnote body can span multiple indented paragraphs"
        [ test "two paragraphs indented by 2 spaces both belong to the same footnote" <|
            \_ ->
                parseWithState "[^1]: first paragraph\n\n  second paragraph\n"
                    |> Tuple.second
                    |> .footnotes
                    |> Dict.get "1"
                    |> Expect.equal
                        (Just
                            [ paragraph "first paragraph"
                            , paragraph "second paragraph"
                            ]
                        )
        ]


symbolKey_Suite : Test
symbolKey_Suite =
    describe "a footnote key isn't limited to numbers - symbols/words/emoji work too"
        [ test "[^note]: ..." <|
            \_ ->
                parseWithState "[^note]: about notes\n"
                    |> Tuple.second
                    |> .footnotes
                    |> Dict.get "note"
                    |> Expect.equal (Just [ paragraph "about notes" ])
        , test "[^🦶]: ..." <|
            \_ ->
                parseWithState "[^🦶]: about feet\n"
                    |> Tuple.second
                    |> .footnotes
                    |> Dict.get "🦶"
                    |> Expect.equal (Just [ paragraph "about feet" ])
        ]
