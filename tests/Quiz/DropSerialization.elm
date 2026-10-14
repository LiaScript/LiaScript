module Quiz.DropSerialization exposing (suite)

import Array
import Expect
import Json.Decode as JD
import Lia.Markdown.Quiz.Block.Json as BlockJson
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Lia.Markdown.Quiz.Multi.Json as MultiJson
import Lia.Markdown.Quiz.Multi.Update as Multi
import Test exposing (Test, describe, test)


roundtrip : State -> Result JD.Error State
roundtrip =
    BlockJson.fromState >> JD.decodeValue BlockJson.toState


suite : Test
suite =
    describe "Drop quiz serialization"
        [ test "block drop [i] survives a roundtrip" <|
            \_ -> roundtrip (Drop False False [ 2 ]) |> Expect.equal (Ok (Drop False False [ 2 ]))
        , test "empty block drop survives a roundtrip" <|
            \_ -> roundtrip (Drop False False []) |> Expect.equal (Ok (Drop False False []))
        , test "inline drop [input, option] survives a roundtrip" <|
            \_ -> roundtrip (Drop False False [ 0, 2 ]) |> Expect.equal (Ok (Drop False False [ 0, 2 ]))
        , test "multi state with drop survives a roundtrip" <|
            \_ ->
                let
                    state =
                        Array.fromList [ Drop False False [ 0, 1 ], Text "x", Select False [ 1 ] ]
                in
                state
                    |> MultiJson.fromState
                    |> JD.decodeValue MultiJson.toState
                    |> Expect.equal (Ok state)
        , test "inline drop is passed to scripts as option index" <|
            \_ ->
                Array.fromList [ Drop False False [ 0, 2 ], Drop False False [], Drop False False [ 0, 1 ] ]
                    |> Multi.toString
                    |> Expect.equal "[2,-1,-1]"
        ]
