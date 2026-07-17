module Parser.Block.SVG exposing
    ( foreignObject_Suite
    , plain_Suite
    )

{-| The docs' "Scaleable Vector Graphics" section - a block-level `<svg>...
</svg>` tag gets special handling in `Lia.Markdown.HTML.Parser`, distinct
from a generic HTML tag like `<div>` (see `Parser.Block.HTML.htmlNode_Suite`,
which produces a `Node` with parsed children):

  - With no `<foreignObject>` inside, the whole `<svg>...</svg>` is captured
    verbatim as `InnerHtml` - none of its content is parsed as Markdown,
    since raw SVG markup isn't Markdown in the first place.
  - With one or more `<foreignObject>`s inside, it becomes a `SvgNode`: the
    outer `<svg>`'s own attributes, the remaining raw SVG source with the
    foreignObject tags stripped out, and a list of `(attributes, content)`
    pairs - one per foreignObject - where `content` _is_ parsed as ordinary
    Markdown/LiaScript `Blocks`. That's the actual point of `foreignObject`
    support: injecting rendered Markdown (including e.g. `$$formulas$$`)
    into an SVG graphic.

-}

import Expect
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (parse)
import Parser.Inline.Fixtures exposing (bold, chars)
import Test exposing (Test, describe, test)


plain_Suite : Test
plain_Suite =
    describe "an <svg> with no <foreignObject> is captured verbatim, unparsed"
        [ test "a circle, untouched" <|
            \_ ->
                {- <svg viewBox="0 0 200 100">
                   <circle cx="50" cy="50" r="40" fill="lightblue"/>
                   </svg>
                -}
                parse "<svg viewBox=\"0 0 200 100\">\n<circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"lightblue\"/>\n</svg>\n"
                    |> Expect.equal
                        [ HTML []
                            (InnerHtml
                                "<svg viewBox=\"0 0 200 100\">\n<circle cx=\"50\" cy=\"50\" r=\"40\" fill=\"lightblue\"/></svg>"
                            )
                        ]
        ]


foreignObject_Suite : Test
foreignObject_Suite =
    describe "an <svg> containing <foreignObject> parses that content as Markdown"
        [ test "a single foreignObject with inline formatting" <|
            \_ ->
                {- <svg viewBox="0 0 200 100">
                   <foreignObject x="0" y="0" width="200" height="100">

                   Hello **world**

                   </foreignObject>
                   </svg>
                -}
                parse "<svg viewBox=\"0 0 200 100\">\n<foreignObject x=\"0\" y=\"0\" width=\"200\" height=\"100\">\n\nHello **world**\n\n</foreignObject>\n</svg>\n"
                    |> Expect.equal
                        [ HTML []
                            (SvgNode [ ( "viewBox", "0 0 200 100" ) ]
                                "\n"
                                [ ( [ ( "x", "0" ), ( "y", "0" ), ( "width", "200" ), ( "height", "100" ) ]
                                  , [ Paragraph [] [ chars "Hello ", bold "world" ] ]
                                  )
                                ]
                            )
                        ]
        , test "two foreignObjects with plain SVG markup around them - collected in reverse source order" <|
            \_ ->
                {- <svg viewBox="0 0 200 100">
                   <foreignObject x="0" y="0" width="100" height="50">

                   first

                   </foreignObject>
                   <circle r="1"/>
                   <foreignObject x="100" y="50" width="100" height="50">

                   second

                   </foreignObject>
                   </svg>
                -}
                parse "<svg viewBox=\"0 0 200 100\">\n<foreignObject x=\"0\" y=\"0\" width=\"100\" height=\"50\">\n\nfirst\n\n</foreignObject>\n<circle r=\"1\"/>\n<foreignObject x=\"100\" y=\"50\" width=\"100\" height=\"50\">\n\nsecond\n\n</foreignObject>\n</svg>\n"
                    |> Expect.equal
                        [ HTML []
                            (SvgNode [ ( "viewBox", "0 0 200 100" ) ]
                                "\n\n<circle r=\"1\"/>\n"
                                [ ( [ ( "x", "100" ), ( "y", "50" ), ( "width", "100" ), ( "height", "50" ) ]
                                  , [ Paragraph [] [ chars "second" ] ]
                                  )
                                , ( [ ( "x", "0" ), ( "y", "0" ), ( "width", "100" ), ( "height", "50" ) ]
                                  , [ Paragraph [] [ chars "first" ] ]
                                  )
                                ]
                            )
                        ]
        ]
