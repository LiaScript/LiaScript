module Parser.Inline.Basic exposing
    ( chars_Suite
    , escape_Suite
    , footnoteDefinition_Suite
    , footnote_Suite
    , footnote_fuzz_Suite
    , lineBreak_Suite
    , smiley_Suite
    , symbol_Suite
    )

import Dict
import Expect
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Markdown.Types as Markdown
import LiaFuzz exposing (slug)
import Parser.Inline.Fixtures
    exposing
        ( chars
        , footnoteMark
        , parse
        , parseFootnotes
        , parseRaw
        , symbol
        , toTests
        )
import Test exposing (Test, describe, fuzz, test)


chars_Suite : Test
chars_Suite =
    describe "generating plain text" <|
        toTests
            [ ( "hello world", chars "hello world" )
            ]


symbol_Suite : Test
symbol_Suite =
    describe "generating arrow symbols" <|
        toTests
            [ ( "<-->", symbol "⟷" )
            , ( "<--", symbol "⟵" )
            , ( "-->", symbol "⟶" )
            , ( "<<-", symbol "↞" )
            , ( "->>", symbol "↠" )
            , ( "<->", symbol "↔" )
            , ( ">->", symbol "↣" )
            , ( "<-<", symbol "↢" )
            , ( "->", symbol "→" )
            , ( "<-", symbol "←" )
            , ( "<~", symbol "↜" )
            , ( "~>", symbol "↝" )
            , ( "<==>", symbol "⟺" )
            , ( "==>", symbol "⟹" )
            , ( "<==", symbol "⟸" )
            , ( "<=>", symbol "⇔" )
            , ( "=>", symbol "⇒" )
            , ( "<=", symbol "⇐" )
            ]


smiley_Suite : Test
smiley_Suite =
    describe "generating smiley symbols" <|
        toTests
            [ ( ":-)", symbol "🙂" )
            , ( ";-)", symbol "😉" )
            , ( ":-D", symbol "😀" )
            , ( ":-O", symbol "😮" )
            , ( ":-(", symbol "🙁" )
            , ( ":-|", symbol "😐" )
            , ( ":-/", symbol "😕" )
            , ( ":-\\", symbol "😕" )
            , ( ":-P", symbol "😛" )
            , ( ":-p", symbol "😛" )
            , ( ";-P", symbol "😜" )
            , ( ";-p", symbol "😜" )
            , ( ":-*", symbol "😗" )
            , ( ";-*", symbol "😘" )
            , ( ":')", symbol "😂" )
            , ( ":'(", symbol "😢" )
            , ( ":'[", symbol "😭" )
            , ( ":-[", symbol "😠" )
            , ( ":-#", symbol "😷" )
            , ( ":-X", symbol "😷" )
            , ( ":-§", symbol "😖" )
            ]


escape_Suite : Test
escape_Suite =
    describe "escaping special characters" <|
        toTests
            [ ( "\\*", chars "*" )
            , ( "\\_", chars "_" )
            , ( "\\~", chars "~" )
            , ( "\\`", chars "`" )
            , ( "\\$", chars "$" )
            , ( "\\\\", chars "\\" )
            , ( "\\{", chars "{" )
            , ( "\\}", chars "}" )
            , ( "\\[", chars "[" )
            , ( "\\]", chars "]" )
            , ( "\\#", chars "#" )
            , ( "\\-", chars "-" )
            , ( "\\^", chars "^" )
            , ( "\\@", chars "@" )
            , ( "\\+", chars "+" )
            , ( "\\|", chars "|" )
            , ( "\\<", chars "<" )
            , ( "\\>", chars ">" )
            , ( "\\'", chars "'" )
            , ( "\\\"", chars "\"" )
            , ( "\\.", chars "." )
            ]


footnote_Suite : Test
footnote_Suite =
    describe "generating footnote marks" <|
        toTests
            [ ( "[^1]", footnoteMark "1" )
            , ( "[^note]", footnoteMark "note" )
            , ( "[^some-longer-key]", footnoteMark "some-longer-key" )
            ]


footnote_fuzz_Suite : Test
footnote_fuzz_Suite =
    describe "generating footnote marks from arbitrary keys"
        [ fuzz slug "wrapped in [^...]" <|
            \key -> parse ("[^" ++ key ++ "]") |> Expect.equal [ footnoteMark key ]
        ]


footnoteDefinition_Suite : Test
footnoteDefinition_Suite =
    describe "generating inline footnote definitions"
        [ test "an inline definition renders like a bare mark and stores its text" <|
            \_ ->
                Expect.all
                    [ parse >> Expect.equal [ footnoteMark "1" ]
                    , parseFootnotes
                        >> Dict.get "1"
                        >> Expect.equal (Just [ Markdown.Paragraph [] [ chars "some text" ] ])
                    ]
                    "[^1](some text)"
        ]


lineBreak_Suite : Test
lineBreak_Suite =
    describe "generating inline line breaks"
        [ test "a backslash immediately before a newline becomes <br>" <|
            \_ ->
                parseRaw "hello\\\nworld"
                    |> Expect.equal
                        [ chars "hello", IHTML (InnerHtml "<br>") [], chars "world" ]
        ]
