module Inline.DataSnapshots exposing (snapshots)

{-| Generated from the implementation before the refactoring, do not edit.
-}

import Dict exposing (Dict)


snapshots : Dict String String
snapshots =
    Dict.fromList
        [ ( "stringify chars"
          , "plain"
          )
        , ( "stringify chars with attr"
          , "plain"
          )
        , ( "stringify bold"
          , "b"
          )
        , ( "stringify bold attr"
          , "b"
          )
        , ( "stringify bold nested"
          , "bi"
          )
        , ( "stringify italic"
          , "i"
          )
        , ( "stringify strike"
          , "s"
          )
        , ( "stringify underline"
          , "u"
          )
        , ( "stringify superscript"
          , "sup"
          )
        , ( "stringify superscript nested"
          , "ab"
          )
        , ( "stringify verbatim"
          , "code"
          )
        , ( "stringify verbatim attr"
          , "code"
          )
        , ( "stringify formula inline"
          , "a^2"
          )
        , ( "stringify formula block"
          , "\\RR"
          )
        , ( "stringify formula attr"
          , "x"
          )
        , ( "stringify symbol"
          , ""
          )
        , ( "stringify symbol attr"
          , ""
          )
        , ( "stringify footnote"
          , ""
          )
        , ( "stringify footnote attr"
          , ""
          )
        , ( "stringify container"
          , "abc"
          )
        , ( "stringify container empty"
          , ""
          )
        , ( "stringify html node"
          , "inb"
          )
        , ( "stringify html node attr"
          , "k"
          )
        , ( "stringify html inner"
          , ""
          )
        , ( "stringify effect"
          , "ef"
          )
        , ( "stringify effect range"
          , "e"
          )
        , ( "stringify script missing"
          , ""
          )
        , ( "stringify link"
          , "alt"
          )
        , ( "stringify link title attr"
          , "alt"
          )
        , ( "stringify link blank title"
          , "alt"
          )
        , ( "stringify link anchor"
          , "sec"
          )
        , ( "stringify mail"
          , "me"
          )
        , ( "stringify image"
          , "alt"
          )
        , ( "stringify image no alt"
          , ""
          )
        , ( "stringify image title attr"
          , "alt"
          )
        , ( "stringify audio"
          , "a"
          )
        , ( "stringify audio tube"
          , "a"
          )
        , ( "stringify movie"
          , "m"
          )
        , ( "stringify movie tube youtube"
          , "m"
          )
        , ( "stringify movie tube youtube query"
          , "m"
          )
        , ( "stringify movie tube other"
          , "m"
          )
        , ( "stringify embed"
          , "e"
          )
        , ( "stringify embed title attr"
          , "e"
          )
        , ( "stringify preview lia"
          , "preview-lia"
          )
        , ( "stringify preview link"
          , "preview-link"
          )
        , ( "stringify qr"
          , "qr-code"
          )
        , ( "stringify qr title attr"
          , "qr-code"
          )
        , ( "stringify script result"
          , ""
          )
        , ( "stringify script no result"
          , ""
          )
        , ( "stringify script out of range"
          , ""
          )
        , ( "stringify quiz 0"
          , ""
          )
        , ( "stringify quiz 1"
          , ""
          )
        , ( "stringify quiz 2"
          , ""
          )
        , ( "stringify quiz 3"
          , ""
          )
        , ( "stringify quiz 4"
          , ""
          )
        , ( "stringify quiz 5"
          , ""
          )
        , ( "stringify_ chars"
          , "plain"
          )
        , ( "stringify_ chars with attr"
          , "plain"
          )
        , ( "stringify_ bold"
          , "b"
          )
        , ( "stringify_ bold attr"
          , "b"
          )
        , ( "stringify_ bold nested"
          , "bi"
          )
        , ( "stringify_ italic"
          , "i"
          )
        , ( "stringify_ strike"
          , "s"
          )
        , ( "stringify_ underline"
          , "u"
          )
        , ( "stringify_ superscript"
          , "sup"
          )
        , ( "stringify_ superscript nested"
          , "ab"
          )
        , ( "stringify_ verbatim"
          , "code"
          )
        , ( "stringify_ verbatim attr"
          , "code"
          )
        , ( "stringify_ formula inline"
          , "a^2"
          )
        , ( "stringify_ formula block"
          , "\\RR"
          )
        , ( "stringify_ formula attr"
          , "x"
          )
        , ( "stringify_ symbol"
          , ""
          )
        , ( "stringify_ symbol attr"
          , ""
          )
        , ( "stringify_ footnote"
          , ""
          )
        , ( "stringify_ footnote attr"
          , ""
          )
        , ( "stringify_ container"
          , "abc"
          )
        , ( "stringify_ container empty"
          , ""
          )
        , ( "stringify_ html node"
          , "inb"
          )
        , ( "stringify_ html node attr"
          , "k"
          )
        , ( "stringify_ html inner"
          , ""
          )
        , ( "stringify_ effect"
          , "ef"
          )
        , ( "stringify_ effect range"
          , "e"
          )
        , ( "stringify_ script missing"
          , "two"
          )
        , ( "stringify_ link"
          , "alt"
          )
        , ( "stringify_ link title attr"
          , "alt"
          )
        , ( "stringify_ link blank title"
          , "alt"
          )
        , ( "stringify_ link anchor"
          , "sec"
          )
        , ( "stringify_ mail"
          , "me"
          )
        , ( "stringify_ image"
          , "alt"
          )
        , ( "stringify_ image no alt"
          , ""
          )
        , ( "stringify_ image title attr"
          , "alt"
          )
        , ( "stringify_ audio"
          , "a"
          )
        , ( "stringify_ audio tube"
          , "a"
          )
        , ( "stringify_ movie"
          , "m"
          )
        , ( "stringify_ movie tube youtube"
          , "m"
          )
        , ( "stringify_ movie tube youtube query"
          , "m"
          )
        , ( "stringify_ movie tube other"
          , "m"
          )
        , ( "stringify_ embed"
          , "e"
          )
        , ( "stringify_ embed title attr"
          , "e"
          )
        , ( "stringify_ preview lia"
          , "preview-lia"
          )
        , ( "stringify_ preview link"
          , "preview-link"
          )
        , ( "stringify_ qr"
          , "qr-code"
          )
        , ( "stringify_ qr title attr"
          , "qr-code"
          )
        , ( "stringify_ script result"
          , "two"
          )
        , ( "stringify_ script no result"
          , ""
          )
        , ( "stringify_ script out of range"
          , ""
          )
        , ( "stringify_ quiz 0"
          , "typed"
          )
        , ( "stringify_ quiz 1"
          , "o1"
          )
        , ( "stringify_ quiz 2"
          , ""
          )
        , ( "stringify_ quiz 3"
          , ""
          )
        , ( "stringify_ quiz 4"
          , ""
          )
        , ( "stringify_ quiz 5"
          , ""
          )
        , ( "stringify_ hidden chars"
          , "plain"
          )
        , ( "stringify_ hidden chars with attr"
          , "plain"
          )
        , ( "stringify_ hidden bold"
          , "b"
          )
        , ( "stringify_ hidden bold attr"
          , "b"
          )
        , ( "stringify_ hidden bold nested"
          , "bi"
          )
        , ( "stringify_ hidden italic"
          , "i"
          )
        , ( "stringify_ hidden strike"
          , "s"
          )
        , ( "stringify_ hidden underline"
          , "u"
          )
        , ( "stringify_ hidden superscript"
          , "sup"
          )
        , ( "stringify_ hidden superscript nested"
          , "ab"
          )
        , ( "stringify_ hidden verbatim"
          , "code"
          )
        , ( "stringify_ hidden verbatim attr"
          , "code"
          )
        , ( "stringify_ hidden formula inline"
          , "a^2"
          )
        , ( "stringify_ hidden formula block"
          , "\\RR"
          )
        , ( "stringify_ hidden formula attr"
          , "x"
          )
        , ( "stringify_ hidden symbol"
          , ""
          )
        , ( "stringify_ hidden symbol attr"
          , ""
          )
        , ( "stringify_ hidden footnote"
          , ""
          )
        , ( "stringify_ hidden footnote attr"
          , ""
          )
        , ( "stringify_ hidden container"
          , "abc"
          )
        , ( "stringify_ hidden container empty"
          , ""
          )
        , ( "stringify_ hidden html node"
          , "inb"
          )
        , ( "stringify_ hidden html node attr"
          , "k"
          )
        , ( "stringify_ hidden html inner"
          , ""
          )
        , ( "stringify_ hidden effect"
          , ""
          )
        , ( "stringify_ hidden effect range"
          , ""
          )
        , ( "stringify_ hidden script missing"
          , "two"
          )
        , ( "stringify_ hidden link"
          , "alt"
          )
        , ( "stringify_ hidden link title attr"
          , "alt"
          )
        , ( "stringify_ hidden link blank title"
          , "alt"
          )
        , ( "stringify_ hidden link anchor"
          , "sec"
          )
        , ( "stringify_ hidden mail"
          , "me"
          )
        , ( "stringify_ hidden image"
          , "alt"
          )
        , ( "stringify_ hidden image no alt"
          , ""
          )
        , ( "stringify_ hidden image title attr"
          , "alt"
          )
        , ( "stringify_ hidden audio"
          , "a"
          )
        , ( "stringify_ hidden audio tube"
          , "a"
          )
        , ( "stringify_ hidden movie"
          , "m"
          )
        , ( "stringify_ hidden movie tube youtube"
          , "m"
          )
        , ( "stringify_ hidden movie tube youtube query"
          , "m"
          )
        , ( "stringify_ hidden movie tube other"
          , "m"
          )
        , ( "stringify_ hidden embed"
          , "e"
          )
        , ( "stringify_ hidden embed title attr"
          , "e"
          )
        , ( "stringify_ hidden preview lia"
          , "preview-lia"
          )
        , ( "stringify_ hidden preview link"
          , "preview-link"
          )
        , ( "stringify_ hidden qr"
          , "qr-code"
          )
        , ( "stringify_ hidden qr title attr"
          , "qr-code"
          )
        , ( "stringify_ hidden script result"
          , "two"
          )
        , ( "stringify_ hidden script no result"
          , ""
          )
        , ( "stringify_ hidden script out of range"
          , ""
          )
        , ( "stringify_ hidden quiz 0"
          , "typed"
          )
        , ( "stringify_ hidden quiz 1"
          , "o1"
          )
        , ( "stringify_ hidden quiz 2"
          , ""
          )
        , ( "stringify_ hidden quiz 3"
          , ""
          )
        , ( "stringify_ hidden quiz 4"
          , ""
          )
        , ( "stringify_ hidden quiz 5"
          , ""
          )
        , ( "encode chars"
          , "[{\"Chars\":\"plain\",\"a\":null}]"
          )
        , ( "encode chars with attr"
          , "[{\"Chars\":\"plain\",\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode bold"
          , "[{\"Bold\":{\"Chars\":\"b\",\"a\":null},\"a\":null}]"
          )
        , ( "encode bold attr"
          , "[{\"Bold\":{\"Chars\":\"b\",\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode bold nested"
          , "[{\"Bold\":{\"Italic\":{\"Chars\":\"bi\",\"a\":null},\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode italic"
          , "[{\"Italic\":{\"Chars\":\"i\",\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode strike"
          , "[{\"Strike\":{\"Chars\":\"s\",\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode underline"
          , "[{\"Underline\":{\"Chars\":\"u\",\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode superscript"
          , "[{\"Superscript\":{\"Chars\":\"sup\",\"a\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode superscript nested"
          , "[{\"Superscript\":{\"Container\":[{\"Chars\":\"a\",\"a\":null},{\"Bold\":{\"Chars\":\"b\",\"a\":null},\"a\":null}],\"a\":null},\"a\":null}]"
          )
        , ( "encode verbatim"
          , "[{\"Verbatim\":\"code\",\"a\":null}]"
          )
        , ( "encode verbatim attr"
          , "[{\"Verbatim\":\"code\",\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode formula inline"
          , "[{\"Formula\":\"false\",\"body\":\"a^2\",\"a\":null}]"
          )
        , ( "encode formula block"
          , "[{\"Formula\":\"true\",\"body\":\"\\\\RR\",\"a\":null}]"
          )
        , ( "encode formula attr"
          , "[{\"Formula\":\"false\",\"body\":\"x\",\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode symbol"
          , "[{\"Symbol\":\"→\",\"a\":null}]"
          )
        , ( "encode symbol attr"
          , "[{\"Symbol\":\"→\",\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode footnote"
          , "[{\"FootnoteMark\":\"1\",\"a\":null}]"
          )
        , ( "encode footnote attr"
          , "[{\"FootnoteMark\":\"note\",\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode container"
          , "[{\"Container\":[{\"Chars\":\"a\",\"a\":null},{\"Italic\":{\"Chars\":\"b\",\"a\":null},\"a\":null},{\"Chars\":\"c\",\"a\":null}],\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode container empty"
          , "[{\"Container\":[],\"a\":null}]"
          )
        , ( "encode html node"
          , "[{\"IHTML\":{\"node\":\"span\",\"attr\":{\"id\":\"n\"},\"children\":[{\"Chars\":\"in\",\"a\":null},{\"Bold\":{\"Chars\":\"b\",\"a\":null},\"a\":null}]},\"a\":null}]"
          )
        , ( "encode html node attr"
          , "[{\"IHTML\":{\"node\":\"kbd\",\"attr\":{},\"children\":[{\"Chars\":\"k\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode html inner"
          , "[{\"IHTML\":{\"node_inline\":\"<br>\"},\"a\":null}]"
          )
        , ( "encode effect"
          , "[{\"EInline\":[{\"Chars\":\"e\",\"a\":null},{\"Bold\":{\"Chars\":\"f\",\"a\":null},\"a\":null}],\"begin\":1,\"end\":null,\"playback\":false,\"voice\":\"\",\"id\":0,\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode effect range"
          , "[{\"EInline\":[{\"Chars\":\"e\",\"a\":null}],\"begin\":2,\"end\":4,\"playback\":true,\"voice\":\"Deutsch Female\",\"id\":3,\"a\":null}]"
          )
        , ( "encode script missing"
          , "[{\"Script\":0,\"a\":null}]"
          )
        , ( "encode link"
          , "[{\"Ref\":{\"Link\":[{\"Chars\":\"alt\",\"a\":null}],\"url\":\"https://a.org\",\"title\":null},\"a\":null}]"
          )
        , ( "encode link title attr"
          , "[{\"Ref\":{\"Link\":[{\"Bold\":{\"Chars\":\"alt\",\"a\":null},\"a\":null}],\"url\":\"https://a.org\",\"title\":[{\"Chars\":\"ti\",\"a\":null},{\"Italic\":{\"Chars\":\"tle\",\"a\":null},\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode link blank title"
          , "[{\"Ref\":{\"Link\":[{\"Chars\":\"alt\",\"a\":null}],\"url\":\"https://a.org\",\"title\":[{\"Chars\":\"  \",\"a\":null}]},\"a\":null}]"
          )
        , ( "encode link anchor"
          , "[{\"Ref\":{\"Link\":[{\"Chars\":\"sec\",\"a\":null}],\"url\":\"#3\",\"title\":null},\"a\":null}]"
          )
        , ( "encode mail"
          , "[{\"Ref\":{\"Mail\":[{\"Chars\":\"me\",\"a\":null}],\"url\":\"mailto:a@b.de\",\"title\":[{\"Chars\":\"t\",\"a\":null}]},\"a\":null}]"
          )
        , ( "encode image"
          , "[{\"Ref\":{\"Image\":[{\"Chars\":\"alt\",\"a\":null}],\"url\":\"img.png\",\"title\":null},\"a\":null}]"
          )
        , ( "encode image no alt"
          , "[{\"Ref\":{\"Image\":[],\"url\":\"other.png\",\"title\":null},\"a\":null}]"
          )
        , ( "encode image title attr"
          , "[{\"Ref\":{\"Image\":[{\"Chars\":\"alt\",\"a\":null}],\"url\":\"other.png\",\"title\":[{\"Chars\":\"cap\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode audio"
          , "[{\"Ref\":{\"Audio\":[{\"Chars\":\"a\",\"a\":null}],\"stream\":false,\"url\":\"a.mp3\",\"title\":[{\"Chars\":\"t\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode audio tube"
          , "[{\"Ref\":{\"Audio\":[{\"Chars\":\"a\",\"a\":null}],\"stream\":true,\"url\":\"https://deezer/x\",\"title\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode movie"
          , "[{\"Ref\":{\"Movie\":[{\"Chars\":\"m\",\"a\":null}],\"stream\":false,\"url\":\"m.mp4\",\"title\":[{\"Chars\":\"t\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode movie tube youtube"
          , "[{\"Ref\":{\"Movie\":[{\"Chars\":\"m\",\"a\":null}],\"stream\":true,\"url\":\"https://www.youtube-nocookie.com/embed/abc\",\"title\":null},\"a\":null}]"
          )
        , ( "encode movie tube youtube query"
          , "[{\"Ref\":{\"Movie\":[{\"Chars\":\"m\",\"a\":null}],\"stream\":true,\"url\":\"https://www.youtube-nocookie.com/embed/abc?start=3\",\"title\":[{\"Chars\":\"t\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode movie tube other"
          , "[{\"Ref\":{\"Movie\":[{\"Chars\":\"m\",\"a\":null}],\"stream\":true,\"url\":\"https://player.vimeo.com/video/1\",\"title\":null},\"a\":null}]"
          )
        , ( "encode embed"
          , "[{\"Ref\":{\"Embed\":[{\"Chars\":\"e\",\"a\":null}],\"url\":\"https://e.org/x\",\"title\":null},\"a\":null}]"
          )
        , ( "encode embed title attr"
          , "[{\"Ref\":{\"Embed\":[{\"Chars\":\"e\",\"a\":null}],\"url\":\"https://e.org/x\",\"title\":[{\"Chars\":\"cap\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode preview lia"
          , "[{\"Ref\":{\"Preview_Lia\":[],\"url\":\"https://c.org/README.md\",\"title\":null},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode preview link"
          , "[{\"Ref\":{\"Preview_Link\":[],\"url\":\"https://c.org\",\"title\":null},\"a\":null}]"
          )
        , ( "encode qr"
          , "[{\"Ref\":{\"QR_Link\":[],\"url\":\"https://q.org\",\"title\":null},\"a\":null}]"
          )
        , ( "encode qr title attr"
          , "[{\"Ref\":{\"QR_Link\":[],\"url\":\"https://q.org\",\"title\":[{\"Chars\":\"scan\",\"a\":null}]},\"a\":[[\"class\",\"x\"],[\"style\",\"color:red\"]]}]"
          )
        , ( "encode script result"
          , "[{\"Script\":0,\"a\":null}]"
          )
        , ( "encode script no result"
          , "[{\"Script\":1,\"a\":null}]"
          )
        , ( "encode script out of range"
          , "[{\"Script\":7,\"a\":null}]"
          )
        , ( "encode quiz 0"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "encode quiz 1"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "encode quiz 2"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "encode quiz 3"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "encode quiz 4"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "encode quiz 5"
          , "[{\"TODO\":null,\"a\":null}]"
          )
        , ( "roundtrip chars"
          , "Ok [Chars \"plain\" []]"
          )
        , ( "roundtrip chars with attr"
          , "Ok [Chars \"plain\" [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip bold"
          , "Ok [Bold (Chars \"b\" []) []]"
          )
        , ( "roundtrip bold attr"
          , "Ok [Bold (Chars \"b\" []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip bold nested"
          , "Ok [Bold (Italic (Chars \"bi\" []) []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip italic"
          , "Ok [Italic (Chars \"i\" []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip strike"
          , "Ok [Strike (Chars \"s\" []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip underline"
          , "Ok [Underline (Chars \"u\" []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip superscript"
          , "Ok [Superscript (Chars \"sup\" []) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip superscript nested"
          , "Ok [Superscript (Container [Chars \"a\" [],Bold (Chars \"b\" []) []] []) []]"
          )
        , ( "roundtrip verbatim"
          , "Ok [Verbatim \"code\" []]"
          )
        , ( "roundtrip verbatim attr"
          , "Ok [Verbatim \"code\" [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip formula inline"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip formula block"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip formula attr"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip symbol"
          , "Ok [Symbol \"→\" []]"
          )
        , ( "roundtrip symbol attr"
          , "Ok [Symbol \"→\" [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip footnote"
          , "Ok [FootnoteMark \"1\" []]"
          )
        , ( "roundtrip footnote attr"
          , "Ok [FootnoteMark \"note\" [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip container"
          , "Ok [Container [Chars \"a\" [],Italic (Chars \"b\" []) [],Chars \"c\" []] [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip container empty"
          , "Ok [Container [] []]"
          )
        , ( "roundtrip html node"
          , "Ok [IHTML (Node \"span\" [(\"id\",\"n\")] [Chars \"in\" [],Bold (Chars \"b\" []) []]) []]"
          )
        , ( "roundtrip html node attr"
          , "Ok [IHTML (Node \"kbd\" [] [Chars \"k\" []]) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip html inner"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Field \"IHTML\" (Failure \"Expecting an OBJECT with a field named `node`\" <internals>),Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip effect"
          , "Ok [EInline { begin = 1, content = [Chars \"e\" [],Bold (Chars \"f\" []) []], end = Nothing, id = 0, playback = False, voice = \"\" } [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip effect range"
          , "Ok [EInline { begin = 2, content = [Chars \"e\" []], end = Just 4, id = 3, playback = True, voice = \"Deutsch Female\" } []]"
          )
        , ( "roundtrip script missing"
          , "Ok [Script 0 []]"
          )
        , ( "roundtrip link"
          , "Ok [Ref (Link [Chars \"alt\" []] \"https://a.org\" Nothing) []]"
          )
        , ( "roundtrip link title attr"
          , "Ok [Ref (Link [Bold (Chars \"alt\" []) []] \"https://a.org\" (Just [Chars \"ti\" [],Italic (Chars \"tle\" []) []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip link blank title"
          , "Ok [Ref (Link [Chars \"alt\" []] \"https://a.org\" (Just [Chars \"  \" []])) []]"
          )
        , ( "roundtrip link anchor"
          , "Ok [Ref (Link [Chars \"sec\" []] \"#3\" Nothing) []]"
          )
        , ( "roundtrip mail"
          , "Ok [Ref (Mail [Chars \"me\" []] \"mailto:a@b.de\" (Just [Chars \"t\" []])) []]"
          )
        , ( "roundtrip image"
          , "Ok [Ref (Image [Chars \"alt\" []] \"img.png\" Nothing) []]"
          )
        , ( "roundtrip image no alt"
          , "Ok [Ref (Image [] \"other.png\" Nothing) []]"
          )
        , ( "roundtrip image title attr"
          , "Ok [Ref (Image [Chars \"alt\" []] \"other.png\" (Just [Chars \"cap\" []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip audio"
          , "Ok [Ref (Audio [Chars \"a\" []] (False,\"a.mp3\") (Just [Chars \"t\" []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip audio tube"
          , "Ok [Ref (Audio [Chars \"a\" []] (True,\"https://deezer/x\") Nothing) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip movie"
          , "Ok [Ref (Movie [Chars \"m\" []] (False,\"m.mp4\") (Just [Chars \"t\" []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip movie tube youtube"
          , "Ok [Ref (Movie [Chars \"m\" []] (True,\"https://www.youtube-nocookie.com/embed/abc\") Nothing) []]"
          )
        , ( "roundtrip movie tube youtube query"
          , "Ok [Ref (Movie [Chars \"m\" []] (True,\"https://www.youtube-nocookie.com/embed/abc?start=3\") (Just [Chars \"t\" []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip movie tube other"
          , "Ok [Ref (Movie [Chars \"m\" []] (True,\"https://player.vimeo.com/video/1\") Nothing) []]"
          )
        , ( "roundtrip embed"
          , "Ok [Ref (Embed [Chars \"e\" []] \"https://e.org/x\" Nothing) []]"
          )
        , ( "roundtrip embed title attr"
          , "Ok [Ref (Embed [Chars \"e\" []] \"https://e.org/x\" (Just [Chars \"cap\" []])) [(\"class\",\"x\"),(\"style\",\"color:red\")]]"
          )
        , ( "roundtrip preview lia"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Field \"Ref\" (OneOf [Failure \"Expecting an OBJECT with a field named `Link`\" <internals>,Failure \"Expecting an OBJECT with a field named `Mail`\" <internals>,Failure \"Expecting an OBJECT with a field named `Image`\" <internals>,Failure \"Expecting an OBJECT with a field named `Embed`\" <internals>,Failure \"Expecting an OBJECT with a field named `Audio`\" <internals>,Failure \"Expecting an OBJECT with a field named `Movie`\" <internals>]),Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip preview link"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Field \"Ref\" (OneOf [Failure \"Expecting an OBJECT with a field named `Link`\" <internals>,Failure \"Expecting an OBJECT with a field named `Mail`\" <internals>,Failure \"Expecting an OBJECT with a field named `Image`\" <internals>,Failure \"Expecting an OBJECT with a field named `Embed`\" <internals>,Failure \"Expecting an OBJECT with a field named `Audio`\" <internals>,Failure \"Expecting an OBJECT with a field named `Movie`\" <internals>]),Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip qr"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Field \"Ref\" (OneOf [Failure \"Expecting an OBJECT with a field named `Link`\" <internals>,Failure \"Expecting an OBJECT with a field named `Mail`\" <internals>,Failure \"Expecting an OBJECT with a field named `Image`\" <internals>,Failure \"Expecting an OBJECT with a field named `Embed`\" <internals>,Failure \"Expecting an OBJECT with a field named `Audio`\" <internals>,Failure \"Expecting an OBJECT with a field named `Movie`\" <internals>]),Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip qr title attr"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Field \"Ref\" (OneOf [Failure \"Expecting an OBJECT with a field named `Link`\" <internals>,Failure \"Expecting an OBJECT with a field named `Mail`\" <internals>,Failure \"Expecting an OBJECT with a field named `Image`\" <internals>,Failure \"Expecting an OBJECT with a field named `Embed`\" <internals>,Failure \"Expecting an OBJECT with a field named `Audio`\" <internals>,Failure \"Expecting an OBJECT with a field named `Movie`\" <internals>]),Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip script result"
          , "Ok [Script 0 []]"
          )
        , ( "roundtrip script no result"
          , "Ok [Script 1 []]"
          )
        , ( "roundtrip script out of range"
          , "Ok [Script 7 []]"
          )
        , ( "roundtrip quiz 0"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip quiz 1"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip quiz 2"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip quiz 3"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip quiz 4"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        , ( "roundtrip quiz 5"
          , "Err (Index 0 (OneOf [Failure \"Expecting an OBJECT with a field named `Chars`\" <internals>,Failure \"Expecting an OBJECT with a field named `FootnoteMark`\" <internals>,Failure \"Expecting an OBJECT with a field named `Symbol`\" <internals>,Failure \"Expecting an OBJECT with a field named `Verbatim`\" <internals>,Failure \"Expecting an OBJECT with a field named `Bold`\" <internals>,Failure \"Expecting an OBJECT with a field named `Italic`\" <internals>,Failure \"Expecting an OBJECT with a field named `Strike`\" <internals>,Failure \"Expecting an OBJECT with a field named `Superscript`\" <internals>,Failure \"Expecting an OBJECT with a field named `Underline`\" <internals>,Failure \"Expecting an OBJECT with a field named `Ref`\" <internals>,Failure \"Expecting an OBJECT with a field named `Container`\" <internals>,Failure \"Expecting an OBJECT with a field named `IHTML`\" <internals>,Failure \"Expecting an OBJECT with a field named `Script`\" <internals>,Failure \"Expecting an OBJECT with a field named `EInline`\" <internals>]))"
          )
        ]
