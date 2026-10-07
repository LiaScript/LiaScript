module Parser.SetextSnapshots exposing (snapshots)

{-| Generated from the implementation before the refactoring, do not edit.
-}

import Dict exposing (Dict)


snapshots : Dict String String
snapshots =
    Dict.fromList
        [ ( "plain"
          , "[Header [] (1,[Chars \"Title\" []])]"
          )
        , ( "plain dashes"
          , "[Header [] (2,[Chars \"Title\" []])]"
          )
        , ( "no underline"
          , "[Paragraph [] [Chars \"Title text\" []]]"
          )
        , ( "underline after blank line"
          , "[Paragraph [] [Chars \"Title\" []],Paragraph [] [Chars \"===\" []]]"
          )
        , ( "html"
          , "[Header [] (1,[Chars \"a \" [],IHTML (Node \"b\" [] [Chars \"b\" [],Chars \"c\" []]) []])]"
          )
        , ( "comment"
          , "[Header [] (1,[Chars \"a\" [(\"c\",\"\"),(\"d\",\"\")],Chars \" e\" []])]"
          )
        , ( "block formula"
          , "[Header [] (1,[Chars \"a \" [],Formula \"true\" \"b\\nc\" []])]"
          )
        , ( "quiz input"
          , "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Chars \"a \" [],Quiz (\"2em\",0) []])], options = Array.fromList [[]], solution = Array.fromList [Text \"b\\nc\"] } } Nothing]"
          )
        , ( "footnote"
          , "[Header [] (1,[Chars \"a \" [],FootnoteMark \"1\" []])]"
          )
        , ( "effect"
          , "[Paragraph [] [Chars \"a {1}{b c} ===\" []]]"
          )
        , ( "effect definition"
          , "[Header [] (1,[Chars \"a \" [],EInline { begin = 1, content = [Chars \"b\" []], end = Nothing, id = 0, playback = False, voice = \"US English Male\" } []])]"
          )
        , ( "line break"
          , "[Header [] (1,[Chars \"a\" [],IHTML (InnerHtml \"<br>\") [],Chars \"b\" []])]"
          )
        , ( "macro"
          , "[Header [] (1,[Chars \"Title \" []])]"
          )
        , ( "last line"
          , "[]"
          )
        , ( "macro listing", "[Header [] (1,[Chars \"Title x\" []])]" )
        , ( "quiz inputs", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Quiz (\"2em\",0) [],Chars \" + \" [],Quiz (\"2em\",1) [],Chars \" = \" [],Quiz (\"2em\",2) []])], options = Array.fromList [[],[],[]], solution = Array.fromList [Text \"2\",Text \"5\",Text \"7\"] } } Nothing]" )
        , ( "quiz inputs, last open", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Quiz (\"2em\",0) [],Chars \" + \" [],Quiz (\"2em\",1) []])], options = Array.fromList [[],[]], solution = Array.fromList [Text \"2\",Text \"5\"] } } Nothing]" )
        , ( "quiz inputs, first open", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Quiz (\"4.800000000000001em\",0) []])], options = Array.fromList [[]], solution = Array.fromList [Text \"2 + [[ 5\"] } } Nothing]" )
        , ( "quiz inputs, closed before", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Chars \"]] \" [],Quiz (\"2em\",0) []])], options = Array.fromList [[]], solution = Array.fromList [Text \"2\"] } } Nothing]" )
        , ( "quiz inputs, nested", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Paragraph [] [Quiz (\"4em\",0) [],Chars \" 7 ]] ===\" []]], options = Array.fromList [[]], solution = Array.fromList [Text \"2 [[ 5\"] } } Nothing]" )
        , ( "drop input", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Quiz (\"2em\",0) []])], options = Array.fromList [[[Chars \"2\" []]]], solution = Array.fromList [Drop False False [0]] } } Nothing]" )
        , ( "drop input closed", "[Quiz [] { hints = [], id = 0, quiz = Multi_Type { elements = [Header [] (1,[Quiz (\"2em\",0) [],Chars \" \" [],Quiz (\"2em\",1) []])], options = Array.fromList [[[Chars \"2\" []]],[]], solution = Array.fromList [Drop False False [0],Text \"3\"] } } Nothing]" )
        ]
