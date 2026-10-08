module Attributes exposing (filterNames_Suite, get_Suite, parse_Suite)

{-| Parameter names are matched case-insensitively, authors may write
`data-tabSize` or `compactDisplay`, while the code asks for lowercase names.
-}

import Combine
import Expect
import Lia.Markdown.HTML.Attributes exposing (filterNames, get, parse)
import Test exposing (Test, describe, test)


get_Suite : Test
get_Suite =
    describe "Attributes.get"
        [ test "finds a key regardless of how the author wrote it" <|
            \_ ->
                get "data-tabsize" [ ( "width", "100%" ), ( "data-tabSize", "4" ) ]
                    |> Expect.equal (Just "4")
        , test "returns the first match" <|
            \_ ->
                get "height" [ ( "HEIGHT", "1px" ), ( "height", "2px" ) ]
                    |> Expect.equal (Just "1px")
        , test "returns Nothing for a missing key" <|
            \_ ->
                get "height" [ ( "width", "100%" ) ]
                    |> Expect.equal Nothing
        ]


filterNames_Suite : Test
filterNames_Suite =
    describe "Attributes.filterNames"
        [ test "keeps matching keys regardless of case and keeps their spelling" <|
            \_ ->
                filterNames [ "compactdisplay" ] [ ( "compactDisplay", "short" ), ( "style", "x" ) ]
                    |> Expect.equal [ ( "compactDisplay", "short" ) ]
        ]


parseAttr : String -> Maybe ( String, String )
parseAttr =
    Combine.parse (parse ( "http://base.url/", "" ))
        >> Result.toMaybe
        >> Maybe.map (\( _, _, attr ) -> attr)


parse_Suite : Test
parse_Suite =
    describe "Attributes.parse"
        [ test "relative URLs get the base, also if the name is upper case" <|
            \_ ->
                [ parseAttr "src='img.jpg'", parseAttr "SRC = 'img.jpg'", parseAttr "title='img.jpg'" ]
                    |> Expect.equal
                        [ Just ( "src", "http://base.url/img.jpg" )
                        , Just ( "SRC", "http://base.url/img.jpg" )
                        , Just ( "title", "img.jpg" )
                        ]
        , test "absolute URLs and anchors are kept" <|
            \_ ->
                [ parseAttr "href=\"mailto:a@b.c\"", parseAttr "href=#top", parseAttr "src=HTTPS://x.de/a.png" ]
                    |> Expect.equal
                        [ Just ( "href", "mailto:a@b.c" )
                        , Just ( "href", "#top" )
                        , Just ( "src", "HTTPS://x.de/a.png" )
                        ]
        , test "character references are decoded in unquoted values only" <|
            \_ ->
                [ parseAttr "title=a&amp;b&#x41;&#66;&unknown;&", parseAttr "title=\"a&amp;b\"" ]
                    |> Expect.equal
                        [ Just ( "title", "a&bAB&unknown;&" )
                        , Just ( "title", "a&amp;b" )
                        ]
        , test "values without quotes, with single quotes or empty" <|
            \_ ->
                [ parseAttr "width=100%", parseAttr "alt='say \"hi\"'", parseAttr "hidden" ]
                    |> Expect.equal
                        [ Just ( "width", "100%" )
                        , Just ( "alt", "say \"hi\"" )
                        , Just ( "hidden", "" )
                        ]
        ]
