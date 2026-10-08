module Attributes exposing (filterNames_Suite, get_Suite)

{-| Parameter names are matched case-insensitively, authors may write
`data-tabSize` or `compactDisplay`, while the code asks for lowercase names.
-}

import Expect
import Lia.Markdown.HTML.Attributes exposing (filterNames, get)
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
