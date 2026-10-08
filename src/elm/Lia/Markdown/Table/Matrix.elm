module Lia.Markdown.Table.Matrix exposing
    ( Matrix
    , Row
    , any
    , column
    , map
    , some
    , split
    , tail
    , transpose
    )

{-| Tables as lists of rows. Rows can have different lengths, `column` and
`transpose` only keep the columns that exist in every row.
-}

import Lia.Utils as Util


type alias Matrix cell =
    List (Row cell)


type alias Row cell =
    List cell


map : (a -> b) -> Matrix a -> Matrix b
map fn =
    List.map (List.map fn)


{-| The i-th column, `Nothing` if the matrix is empty or a row is too short.
-}
column : Int -> Matrix cell -> Maybe (Row cell)
column i matrix =
    if List.isEmpty matrix then
        Nothing

    else
        List.foldr (Util.get i >> Maybe.map2 (::)) (Just []) matrix


tail : Matrix cell -> Matrix cell
tail =
    List.tail >> Maybe.withDefault []


{-| The first row and the remaining rows.
-}
split : Matrix cell -> ( Row cell, Matrix cell )
split matrix =
    case matrix of
        [] ->
            ( [], [] )

        r :: rs ->
            ( r, rs )


transpose : Matrix cell -> Matrix cell
transpose matrix =
    List.foldr
        (List.map2 (::))
        (List.repeat
            (matrix
                |> List.head
                |> Maybe.withDefault []
                |> List.length
            )
            []
        )
        matrix


any : (cell -> Bool) -> Matrix cell -> Bool
any fn =
    List.any (List.any fn)


{-| At least `percent` of all cells pass the test, also `True` for no cells.
-}
some : Float -> (cell -> Bool) -> Matrix cell -> Bool
some percent fn matrix =
    let
        cells =
            List.concat matrix
    in
    List.isEmpty cells
        || (toFloat (List.length (List.filter fn cells))
                / toFloat (List.length cells)
                >= percent
           )
