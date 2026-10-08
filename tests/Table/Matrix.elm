module Table.Matrix exposing (suite)

import Expect
import Fuzz
import Lia.Markdown.Table.Matrix as Matrix
import Lia.Utils as Util
import Test exposing (Test, describe, fuzz, fuzz2, test)


{-| The former quadratic implementation, kept as reference.
-}
reference : List (List a) -> List (List a)
reference matrix =
    List.foldl
        (\input output -> List.map2 (\i o -> List.append o [ i ]) input output)
        (List.repeat (matrix |> List.head |> Maybe.withDefault [] |> List.length) [])
        matrix


{-| The former implementation of `some`.
-}
someReference : Float -> (cell -> Bool) -> List (List cell) -> Bool
someReference percent fn =
    Matrix.map fn
        >> List.concat
        >> List.foldl
            (\cell ( true, false ) ->
                if cell then
                    ( true + 1, false )

                else
                    ( true, false + 1 )
            )
            ( 0, 0 )
        >> (\( true, false ) ->
                (true / (true + false)) >= percent
           )


suite : Test
suite =
    describe "Lia.Markdown.Table.Matrix"
        [ transpose
        , fuzz2 (Fuzz.intRange -1 4) (Fuzz.list (Fuzz.list Fuzz.int)) "column equals the former transpose >> get" <|
            \i matrix ->
                Matrix.column i matrix
                    |> Expect.equal (matrix |> Matrix.transpose |> Util.get i)
        , fuzz (Fuzz.list (Fuzz.list Fuzz.bool)) "some equals the former counting fold" <|
            \matrix ->
                Matrix.some 0.3 identity matrix
                    |> Expect.equal (someReference 0.3 identity matrix)
        ]


transpose : Test
transpose =
    describe "transpose"
        [ test "rectangular" <|
            \_ ->
                Matrix.transpose [ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
                    |> Expect.equal [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]
        , fuzz (Fuzz.list (Fuzz.list Fuzz.int)) "equals reference, also for ragged rows" <|
            \matrix ->
                Matrix.transpose matrix
                    |> Expect.equal (reference matrix)
        ]
