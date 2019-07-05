module Lia.Markdown.Survey.Types exposing
    ( Element
    , State(..)
    , Survey(..)
    , Vector
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type alias Vector =
    Array Element


type alias Element =
    ( Bool, State )


type State
    = TextState String
    | VectorState Bool (Dict String Bool)
    | MatrixState Bool (Array (Dict String Bool))


type Survey
    = Text Int Int
    | Vector Bool (List ( String, Inlines )) Int
    | Matrix Bool MultInlines (List String) MultInlines Int
