module Parser.Block.Quote exposing
    ( alert_Suite
    , alert_anyCase_fuzz_Suite
    , quote_Suite
    )

import Expect
import Lia.Markdown.Types exposing (Alert(..))
import LiaFuzz exposing (fuzzRegex)
import Parser.Block.Fixtures exposing (alertQuote, parse, quote, toTests)
import Test exposing (Test, describe, fuzz)


quote_Suite : Test
quote_Suite =
    describe "generating blockquotes" <|
        toTests
            [ ( "> hello\n", quote [ "hello" ] )
            , ( "> hello\n> world\n", quote [ "hello world" ] )
            ]


alert_Suite : Test
alert_Suite =
    describe "generating alert-style blockquotes" <|
        toTests
            [ ( "> [!NOTE]\n> This is a note.\n"
              , alertQuote NOTE Nothing [ "This is a note." ]
              )
            , ( "> [!NOTE] A title\n> This is a note.\n"
              , alertQuote NOTE (Just "A title") [ "This is a note." ]
              )
            , ( "> [!TIP]\n> Some tip.\n", alertQuote TIP Nothing [ "Some tip." ] )
            , ( "> [!IMPORTANT]\n> Pay attention.\n", alertQuote IMPORTANT Nothing [ "Pay attention." ] )
            , ( "> [!WARNING]\n> Be careful.\n", alertQuote WARNING Nothing [ "Be careful." ] )
            , ( "> [!CAUTION]\n> Danger ahead.\n", alertQuote CAUTION Nothing [ "Danger ahead." ] )
            ]


{-| The alert keyword (`NOTE`, `TIP`, ...) is matched case-insensitively.
Rather than hand-writing a couple of differently-cased examples, build a
regex that generates _any_ casing of each keyword - one character class per
letter, e.g. `NOTE` becomes `[Nn][Oo][Tt][Ee]` - and fuzz across every
possible casing to confirm the parser really is indifferent to it.
-}
alert_anyCase_fuzz_Suite : Test
alert_anyCase_fuzz_Suite =
    describe "the alert keyword is matched regardless of letter casing"
        [ fuzz (fuzzRegex (anyCase "NOTE")) "any casing of NOTE" <|
            \keyword ->
                {- > [!NoTe]
                   > body
                -}
                parse ("> [!" ++ keyword ++ "]\n> body\n")
                    |> Expect.equal [ alertQuote NOTE Nothing [ "body" ] ]
        , fuzz (fuzzRegex (anyCase "TIP")) "any casing of TIP" <|
            \keyword ->
                {- > [!TiP]
                   > body
                -}
                parse ("> [!" ++ keyword ++ "]\n> body\n")
                    |> Expect.equal [ alertQuote TIP Nothing [ "body" ] ]
        , fuzz (fuzzRegex (anyCase "IMPORTANT")) "any casing of IMPORTANT" <|
            \keyword ->
                {- > [!ImPoRtAnT]
                   > body
                -}
                parse ("> [!" ++ keyword ++ "]\n> body\n")
                    |> Expect.equal [ alertQuote IMPORTANT Nothing [ "body" ] ]
        , fuzz (fuzzRegex (anyCase "WARNING")) "any casing of WARNING" <|
            \keyword ->
                {- > [!WaRnInG]
                   > body
                -}
                parse ("> [!" ++ keyword ++ "]\n> body\n")
                    |> Expect.equal [ alertQuote WARNING Nothing [ "body" ] ]
        , fuzz (fuzzRegex (anyCase "CAUTION")) "any casing of CAUTION" <|
            \keyword ->
                {- > [!CaUtIoN]
                   > body
                -}
                parse ("> [!" ++ keyword ++ "]\n> body\n")
                    |> Expect.equal [ alertQuote CAUTION Nothing [ "body" ] ]
        ]


{-| Turns a literal word into a regex that matches any per-letter casing of
it, e.g. `anyCase "NOTE" == "[Nn][Oo][Tt][Ee]"`.
-}
anyCase : String -> String
anyCase =
    String.toList
        >> List.map
            (\c ->
                "[" ++ String.fromChar (Char.toUpper c) ++ String.fromChar (Char.toLower c) ++ "]"
            )
        >> String.concat
