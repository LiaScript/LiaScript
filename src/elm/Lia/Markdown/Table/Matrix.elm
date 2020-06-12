module Lia.Markdown.Table.Matrix exposing
    ( Matrix
    , Row
    , all
    , any
    , column
    , get
    , head
    , map
    , row
    , some
    , split
    , tail
    , transpose
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Stringify exposing (stringify, stringify_)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type alias Matrix cell =
    List (Row cell)


type alias Row cell =
    List cell


map : (a -> b) -> Matrix a -> Matrix b
map fn =
    List.map (List.map fn)


get : Int -> Int -> Matrix cell -> Maybe cell
get i j =
    row i >> Maybe.andThen (row j)


row : Int -> List row -> Maybe row
row i matrix =
    case matrix of
        [] ->
            Nothing

        r :: rs ->
            if i <= 0 then
                Just r

            else
                row (i - 1) rs


column : Int -> Matrix cell -> Maybe (Row cell)
column i =
    transpose >> row i


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
                Debug.log "sssssssssssssssss" (true / (true + false)) >= percent
           )
