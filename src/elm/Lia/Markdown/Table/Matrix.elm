module Lia.Markdown.Table.Matrix exposing
    ( Matrix
    , Row
    , all
    , any
    , column
    , head
    , map
    , some
    , split
    , tail
    , transpose
    )

import Lia.Utils as Util


type alias Matrix cell =
    List (Row cell)


type alias Row cell =
    List cell


map : (a -> b) -> Matrix a -> Matrix b
map fn =
    List.map (List.map fn)


column : Int -> Matrix cell -> Maybe (Row cell)
column i =
    transpose >> Util.get i


head : Matrix cell -> Row cell
head =
    List.head >> Maybe.withDefault []


tail : Matrix cell -> Matrix cell
tail =
    List.tail >> Maybe.withDefault []


split : Matrix cell -> ( Row cell, Matrix cell )
split matrix =
    case matrix of
        [] ->
            ( [], [] )

        r :: rs ->
            ( r, rs )


transpose : Matrix cell -> Matrix cell
transpose matrix =
    List.foldl
        (\input output ->
            List.map2
                (\i o -> List.append o [ i ])
                input
                output
        )
        (List.repeat
            (matrix
                |> List.head
                |> Maybe.withDefault []
                |> List.length
            )
            []
        )
        matrix


all : (cell -> Bool) -> Matrix cell -> Bool
all fn =
    List.all (List.all fn)


any : (cell -> Bool) -> Matrix cell -> Bool
any fn =
    List.any (List.any fn)


some : Float -> (cell -> Bool) -> Matrix cell -> Bool
some percent fn =
    map fn
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
