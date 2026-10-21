module Utils.Identicon exposing (suite)

import Expect
import Lia.Utils exposing (identicon)
import List.Extra
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Utils.identicon"
        [ test "the same id always yields the same color and symbol" <|
            \_ ->
                identicon "peer-abc-123"
                    |> Expect.equal (identicon "peer-abc-123")
        , test "different ids generally yield a different symbol" <|
            \_ ->
                [ "peer-1", "peer-2", "peer-3", "peer-4", "peer-5" ]
                    |> List.map (identicon >> .symbol)
                    |> List.Extra.unique
                    |> List.length
                    |> Expect.atLeast 2
        ]
