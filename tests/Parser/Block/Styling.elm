module Parser.Block.Styling exposing
    ( multipleAttributes_Suite
    , singleAttribute_Suite
    )

{-| Block-level custom-styling annotations, as described in the docs'
"Block-Styling" section - a `<!-- key="value" ... -->` HTML comment placed
immediately before any block attaches those key/value pairs as that block's
`Parameters`. This is the same `Parameters` list every other block-level
fixture always passes as `[]` - these tests are the only ones in the suite
that exercise it as actually populated.
-}

import Expect
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (parse)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe, test)


singleAttribute_Suite : Test
singleAttribute_Suite =
    describe "a single key=\"value\" HTML comment attaches as that block's Parameters" <|
        [ test "a style attribute before a paragraph" <|
            \_ ->
                {- <!-- style="color: red" -->
                   Hello world
                -}
                parse "<!-- style=\"color: red\" -->\nHello world\n"
                    |> Expect.equal
                        [ Paragraph [ ( "style", "color: red" ) ] [ chars "Hello world" ] ]
        , test "a style attribute before a header" <|
            \_ ->
                {- <!-- style="color: red" -->
                   # Title
                -}
                parse "<!-- style=\"color: red\" -->\n# Title\n"
                    |> Expect.equal
                        [ Header [ ( "style", "color: red" ) ] ( 1, [ chars "Title" ] ) ]
        , test "a style attribute before a blockquote" <|
            \_ ->
                {- <!-- style="background-color: tomato;"-->
                   > Warning
                -}
                parse "<!-- style=\"background-color: tomato;\"-->\n> Warning\n"
                    |> Expect.equal
                        [ Quote [ ( "style", "background-color: tomato;" ) ]
                            Nothing
                            [ Paragraph [] [ chars "Warning" ] ]
                        ]
        , test "a style attribute before a bullet list" <|
            \_ ->
                {- <!-- style="color: red" -->
                   * item one
                   * item two
                -}
                parse "<!-- style=\"color: red\" -->\n* item one\n* item two\n"
                    |> Expect.equal
                        [ BulletList [ ( "style", "color: red" ) ]
                            [ [ Paragraph [] [ chars "item one" ] ]
                            , [ Paragraph [] [ chars "item two" ] ]
                            ]
                        ]
        ]


multipleAttributes_Suite : Test
multipleAttributes_Suite =
    describe "several key=\"value\" pairs in one comment all attach, in order" <|
        [ test "class and style together, exactly as in the docs' example" <|
            \_ ->
                {- <!-- class = "animated rollIn" style = "animation-delay: 3s; color: purple" -->
                   Hello world
                -}
                parse "<!-- class = \"animated rollIn\" style = \"animation-delay: 3s; color: purple\" -->\nHello world\n"
                    |> Expect.equal
                        [ Paragraph
                            [ ( "class", "animated rollIn" )
                            , ( "style", "animation-delay: 3s; color: purple" )
                            ]
                            [ chars "Hello world" ]
                        ]
        ]
