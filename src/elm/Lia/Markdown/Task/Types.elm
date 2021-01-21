module Lia.Markdown.Task.Types exposing
    ( Task
    , Vector
    )

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Vector =
    Array (Array Bool)


type alias Task =
    { task : List Inlines
    , id : Int
    , javascript : Maybe String
    }
