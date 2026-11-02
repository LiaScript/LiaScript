module IndexVersion exposing (suite)

import Expect
import Index.Version as Version
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Index.Version"
        [ test "max compares numerically, not as text (9 < 10, #326)" <|
            \_ ->
                Version.max [ "9", "10" ]
                    |> Expect.equal (Just "10")
        , test "max of full versions" <|
            \_ ->
                Version.max [ "1.3.2", "33.1.1", "1.3.1", "4.0.0" ]
                    |> Expect.equal (Just "33.1.1")
        ]
