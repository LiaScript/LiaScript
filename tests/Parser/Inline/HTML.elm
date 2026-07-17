module Parser.Inline.HTML exposing
    ( comment_Suite
    , tag_Suite
    )

import Expect
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Parser.Inline.Fixtures exposing (chars, htmlNode, htmlVoid, parse, toTests)
import Test exposing (Test, describe, test)


tag_Suite : Test
tag_Suite =
    describe "generating inline HTML tags" <|
        toTests
            [ ( "<br>", htmlVoid "br" )
            , ( "<span>hello</span>", htmlNode "span" [ chars "hello" ] )
            , ( "<span class=\"hi\">hello</span>"
              , IHTML (Node "span" [ ( "class", "hi" ) ] [ chars "hello" ]) []
              )
            ]


comment_Suite : Test
comment_Suite =
    describe "consuming HTML comments"
        [ test "a two-dashed comment after text is parsed as its annotation" <|
            \_ ->
                {- hello<!-- data-x="1" --> -}
                parse "hello<!-- data-x=\"1\" -->"
                    |> Expect.equal [ Chars "hello" [ ( "data-x", "1" ) ] ]
        , test "a triple-dashed comment after text is fully ignored" <|
            \_ ->
                {- hello<!--- anything goes here --> -}
                parse "hello<!--- anything goes here -->"
                    |> Expect.equal [ chars "hello" ]
        ]
