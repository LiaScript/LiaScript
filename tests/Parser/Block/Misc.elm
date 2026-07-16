module Parser.Block.Misc exposing
    ( citation_Suite
    , comment_Suite
    , htmlComment_Suite
    , problem_Suite
    )

import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (toTests)
import Parser.Inline.Fixtures exposing (chars)
import Test exposing (Test, describe)


citation_Suite : Test
citation_Suite =
    describe "generating citations (a paragraph starting with \u{2013})" <|
        toTests
            [ ( "\u{2013} Some quote\n", Citation [] [ chars " Some quote" ] )
            ]


comment_Suite : Test
comment_Suite =
    describe "generating narrator comments (--{{n}}--)" <|
        toTests
            [ ( "--{{1}}--\nSome comment text.\n", Comment ( 1, 0 ) )
            ]


htmlComment_Suite : Test
htmlComment_Suite =
    describe "consuming standalone HTML comments as blocks" <|
        toTests
            [ ( "<!-- just an html comment -->\n", HtmlComment )
            ]


{-| A malformed effect/comment marker (`{{1}}` with no matching content or
closing) can't be parsed as any known block - `checkParagraph` deliberately
refuses to swallow it as plain paragraph text either (to leave room for the
Effect/Comment parsers) - so it falls all the way through to the `problem`
fallback, which just captures the raw line as-is.
-}
problem_Suite : Test
problem_Suite =
    describe "an unparsable line falls back to Problem" <|
        toTests
            [ ( "{{1}}\n", Problem [ chars "{{1}}" ] )
            ]
