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
    = Text_State String
    | Vector_State Bool (Dict String Bool)
    | Matrix_State Bool (Array (Dict String Bool))


type Survey
    = Text Int Int
    | Vector Bool (List ( String, Inlines )) Int
    | Matrix Bool MultInlines (List String) MultInlines Int
