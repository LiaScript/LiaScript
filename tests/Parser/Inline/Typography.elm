module Parser.Inline.Typography exposing
    ( dash_Suite
    , ellipsis_Suite
    , quote_Suite
    , quote_fuzz_Suite
    )

import Expect
import Lia.Markdown.Inline.Types exposing (Inline(..))
import LiaFuzz exposing (words)
import Parser.Inline.Fixtures exposing (chars, container, parse, toTests)
import Test exposing (Test, describe, fuzz)


dash_Suite : Test
dash_Suite =
    describe "generating typographic dashes" <|
        toTests
            {- -- -}
            [ ( "--", chars "–" )

            {- --- -}
            , ( "---", chars "—" )
            ]


ellipsis_Suite : Test
ellipsis_Suite =
    describe "generating typographic ellipsis" <|
        toTests
            {- ... -}
            [ ( "...", chars "…" )
            ]


quote_Suite : Test
quote_Suite =
    describe "generating typographic quotes" <|
        toTests
            {- "hello" -}
            [ ( "\"hello\""
              , Container [ chars "“", chars "hello", chars "”" ] []
              )

            {- 'hello' -}
            , ( " 'hello'"
              , Container [ chars " ‘", chars "hello", chars "’" ] []
              )
            ]


quote_fuzz_Suite : Test
quote_fuzz_Suite =
    describe "generating typographic quotes from arbitrary content"
        [ fuzz words "straight double quotes become curly" <|
            \content ->
                {- "example text" -}
                parse ("\"" ++ content ++ "\"")
                    |> Expect.equal [ container [ chars "“", chars content, chars "”" ] ]
        , fuzz words "straight single quotes become curly (with a leading space)" <|
            \content ->
                {- 'example text' -}
                parse (" '" ++ content ++ "'")
                    |> Expect.equal [ container [ chars " ‘", chars content, chars "’" ] ]
        ]
