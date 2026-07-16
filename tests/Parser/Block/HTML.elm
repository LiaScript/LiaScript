module Parser.Block.HTML exposing (detailsSummary_Suite, htmlNode_Suite)

import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (paragraph, toTests)
import Parser.Inline.Fixtures exposing (chars, htmlNode)
import Test exposing (Test, describe)


htmlNode_Suite : Test
htmlNode_Suite =
    describe "generating block-level HTML nodes" <|
        toTests
            [ ( "<div>\nhello\n</div>\n"
              , HTML [] (Node "div" [] [ paragraph "hello" ])
              )
            ]


{-| The `<details>`/`<summary>` pair, documented under "Details & Summary" as
a way to build an accordion, is just plain nested block-level HTML - the
`summary` node ends up as a child block alongside the rest of the details
body.
-}
detailsSummary_Suite : Test
detailsSummary_Suite =
    describe "generating a <details>/<summary> accordion" <|
        toTests
            [ ( "<details>\n\n<summary>click to expand</summary>\n\nhidden body\n\n</details>\n"
              , HTML []
                    (Node "details"
                        []
                        [ Paragraph []
                            [ htmlNode "summary"
                                [ chars "click", chars " ", chars "to", chars " ", chars "expand" ]
                            ]
                        , paragraph "hidden body"
                        ]
                    )
              )
            ]
