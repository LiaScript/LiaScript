module Parser.Inline.Effects exposing
    ( animation_Suite
    , script_Suite
    )

import Lia.Markdown.Inline.Types exposing (Inline(..))
import Parser.Inline.Fixtures exposing (chars, script, toTests)
import Test exposing (Test, describe)


animation_Suite : Test
animation_Suite =
    describe "generating inline animation effects" <|
        toTests
            {- {1}{hello} -}
            [ ( "{1}{hello}"
              , EInline
                    { content = [ chars "hello" ]
                    , playback = False
                    , begin = 1
                    , end = Nothing
                    , voice = "US English Male"
                    , id = 0
                    }
                    []
              )

            {- {1-3}{hello} -}
            , ( "{1-3}{hello}"
              , EInline
                    { content = [ chars "hello" ]
                    , playback = False
                    , begin = 1
                    , end = Just 3
                    , voice = "US English Male"
                    , id = 0
                    }
                    []
              )
            ]


script_Suite : Test
script_Suite =
    describe "generating inline script effects" <|
        toTests
            {- <script>1 + 1;</script> -}
            [ ( "<script>1 + 1;</script>", script 0 )
            ]
