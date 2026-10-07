module Sync.DecodeEntries exposing (suite)

import Expect
import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Update exposing (decodeEntries)
import Test exposing (Test, describe, test)


entry : Int -> JE.Value -> JE.Value
entry id data =
    JE.object [ ( "id", JE.int id ), ( "data", data ) ]


suite : Test
suite =
    describe "Lia.Sync.Update.decodeEntries"
        [ test "keeps every decodable entry when one entry is broken" <|
            \_ ->
                [ entry 1 (JE.int 10)
                , entry 2 (JE.string "not an int")
                , entry 3 (JE.int 30)
                ]
                    |> JE.list identity
                    |> decodeEntries JD.int
                    |> Tuple.first
                    |> Expect.equal [ ( 1, 10 ), ( 3, 30 ) ]
        , test "reports the broken entry by its id" <|
            \_ ->
                [ entry 1 (JE.int 10)
                , entry 2 (JE.string "not an int")
                ]
                    |> JE.list identity
                    |> decodeEntries JD.int
                    |> Tuple.second
                    |> List.map (String.contains "id 2")
                    |> Expect.equal [ True ]
        , test "an entry without a usable id is reported, not dropped silently" <|
            \_ ->
                [ JE.object [ ( "data", JE.int 10 ) ] ]
                    |> JE.list identity
                    |> decodeEntries JD.int
                    |> (\( entries, errors ) ->
                            ( entries
                            , List.map (\e -> String.startsWith "entry 0: " e && String.contains "field named `id`" e) errors
                            )
                       )
                    |> Expect.equal ( [], [ True ] )
        , test "a payload that is not a list yields no entries and one error" <|
            \_ ->
                JE.string "nope"
                    |> decodeEntries JD.int
                    |> (\( entries, errors ) -> ( entries, List.length errors ))
                    |> Expect.equal ( [], 1 )
        ]
