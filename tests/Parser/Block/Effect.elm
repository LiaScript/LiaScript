module Parser.Block.Effect exposing
    ( multiBlock_Suite
    , range_Suite
    , single_Suite
    )

{-| Block-level animation effects (`{{n}}` / `{{n-m}}` above a block, or
above a fence of `***` for multiple blocks), as described in the docs'
"Animations" section. The narrator-comment (`--{{n}}--`) and malformed-marker
(`Problem`) cases already have coverage in `Parser.Block.Misc`; this module
covers the animation-content case, where the marked block(s) actually become
part of the returned tree (wrapped in `Effect`).
-}

import Expect
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (paragraph, parse)
import Test exposing (Test, describe, test)


defaultVoice : String
defaultVoice =
    "US English Male"


single_Suite : Test
single_Suite =
    describe "a single block preceded by {{n}} appears starting at step n"
        [ test "{{1}}\\nSome text.\\n" <|
            \_ ->
                parse "{{1}}\nSome text.\n"
                    |> Expect.equal
                        [ Effect []
                            { content = [ paragraph "Some text." ]
                            , playback = False
                            , begin = 1
                            , end = Nothing
                            , voice = defaultVoice
                            , id = 0
                            }
                        ]
        ]


range_Suite : Test
range_Suite =
    describe "a {{n-m}} range makes the block disappear again at step m"
        [ test "{{2-3}}\\nOther text.\\n" <|
            \_ ->
                parse "{{2-3}}\nOther text.\n"
                    |> Expect.equal
                        [ Effect []
                            { content = [ paragraph "Other text." ]
                            , playback = False
                            , begin = 2
                            , end = Just 3
                            , voice = defaultVoice
                            , id = 0
                            }
                        ]
        ]


multiBlock_Suite : Test
multiBlock_Suite =
    describe "a {{n}} above a fence of *** groups every block up to the closing fence"
        [ test "{{1-2}}\\n***\\nFirst.\\n\\nSecond.\\n***\\n" <|
            \_ ->
                parse "{{1-2}}\n***\nFirst.\n\nSecond.\n***\n"
                    |> Expect.equal
                        [ Effect []
                            { content = [ paragraph "First.", paragraph "Second." ]
                            , playback = False
                            , begin = 1
                            , end = Just 2
                            , voice = defaultVoice
                            , id = 0
                            }
                        ]
        ]
