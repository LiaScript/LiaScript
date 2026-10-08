module Table.Matrix exposing (suite)

import Expect
import Fuzz
import Lia.Markdown.Table.Matrix as Matrix
import Test exposing (Test, describe, fuzz, test)


{-| The former quadratic implementation, kept as reference.
-}
reference : List (List a) -> List (List a)
reference matrix =
    List.foldl
        (\input output -> List.map2 (\i o -> List.append o [ i ]) input output)
        (List.repeat (matrix |> List.head |> Maybe.withDefault [] |> List.length) [])
        matrix


suite : Test
suite =
    describe "Table.Matrix.transpose"
        [ test "rectangular" <|
            \_ ->
                Matrix.transpose [ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
                    |> Expect.equal [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]
        , fuzz (Fuzz.list (Fuzz.list Fuzz.int)) "equals reference, also for ragged rows" <|
            \matrix ->
                Matrix.transpose matrix
                    |> Expect.equal (reference matrix)
        ]
