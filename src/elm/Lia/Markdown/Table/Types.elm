module Lia.Markdown.Table.Types exposing
    ( Cell
    , Class(..)
    , Row
    , State
    , Table(..)
    , Vector
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type Table
    = Unformatted Class (List Row) Int
    | Formatted Class MultInlines (List String) (List Row) Int


type Class
    = None
    | BoxPlot
    | Diagram


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
