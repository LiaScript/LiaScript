module Parser.Block.HTML exposing (detailsSummary_Suite, htmlNode_Suite, json_Suite)

import Expect
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.HTML.Types exposing (Node(..), decode, encode)
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (paragraph, toTests)
import Parser.Inline.Fixtures exposing (chars, htmlNode)
import Test exposing (Test, describe, test)


htmlNode_Suite : Test
htmlNode_Suite =
    describe "generating block-level HTML nodes" <|
        toTests
            {- <div>
               hello
               </div>
            -}
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
            {- <details>

               <summary>click to expand</summary>

               hidden body

               </details>
            -}
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


json_Suite : Test
json_Suite =
    describe "HTML.Types encode/decode" <|
        List.map
            (\node ->
                test (Debug.toString node) <|
                    \_ ->
                        node
                            |> encode JE.string
                            |> JD.decodeValue (decode JD.string)
                            |> Expect.equal (Ok node)
            )
            [ Node "div" [ ( "class", "a" ) ] [ "x", "y" ]
            , InnerHtml "<b>raw</b>"
            , OuterHtml "lia-x" [ ( "a", "1" ) ] "body"
            , SvgNode [ ( "viewBox", "0 0 1 1" ) ] "<rect/>" [ ( [ ( "x", "1" ) ], [ "content" ] ) ]
            ]
