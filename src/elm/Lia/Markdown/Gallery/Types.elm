module Lia.Markdown.Gallery.Types exposing
    ( Gallery
    , Vector
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Vector =
    Array Int


type alias Gallery =
    { media : Inlines
    , id : Int
    }
