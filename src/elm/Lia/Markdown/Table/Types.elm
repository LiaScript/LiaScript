module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , Row
    , State
    , Table(..)
    , Vector
    , get
    , getColumn
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type Table
    = Unformatted Class (List Row) Int
    | Formatted Class MultInlines (List String) (List Row) Int


type Class
    = None
    | Lines
    | Scatter
    | BarChart


type alias Vector =
    Array State


type alias State =
    { column : Int
    , dir : Bool
    , diagram : Bool
    }


type alias Row =
    List Cell


type alias Cell =
    { inlines : Inlines
    , string : String
    , float : Maybe Float
    }


getColumn : Int -> List Inlines -> List (List c) -> Maybe ( Maybe String, List c )
getColumn i head rows =
    let
        column =
            List.filterMap (get i) rows
    in
    if column == [] then
        Nothing

    else
        Just
            ( head
                |> get i
                |> Maybe.andThen (stringify >> String.trim >> isEmpty)
            , column
            )


isEmpty : String -> Maybe String
isEmpty str =
    if str == "" then
        Nothing

    else
        Just str


get : Int -> List c -> Maybe c
get id list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if id == 0 then
                Just x

            else
                get (id - 1) xs
