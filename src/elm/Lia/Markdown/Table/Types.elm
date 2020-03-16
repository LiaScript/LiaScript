module Lia.Markdown.Table.Types exposing (Table(..), Vector)

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (MultInlines)


type Table
    = Unformatted (List MultInlines) Int
    | Formatted MultInlines (List String) (List MultInlines) Int


type alias Vector =
    Array ( Int, Bool )
