module Sync.Types exposing (suite)

import Dict
import Expect
import Lia.Sync.Types as Sync
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Sync.Types.roster"
        [ test "a peer with answers but missing from peersHistory (joined without a name, now offline) still gets a nameless row; known names win" <|
            \_ ->
                let
                    sync =
                        Sync.init []

                    settings =
                        { sync | peersHistory = Dict.fromList [ ( "teacher", "T" ), ( "alice", "Alice" ) ] }
                in
                Dict.fromList [ ( "alice", 1 ), ( "bob", 2 ) ]
                    |> Sync.roster settings
                    |> Expect.equal (Dict.fromList [ ( "teacher", "T" ), ( "alice", "Alice" ), ( "bob", "" ) ])
        ]
