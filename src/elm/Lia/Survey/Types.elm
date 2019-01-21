module Lia.Survey.Types exposing (Element, State(..), Survey(..), Var, Vector)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)


type alias Var =
    String


type alias Vector =
    Array Element


type alias Element =
    ( Bool, State )


type State
    = TextState String
    | VectorState Bool (Dict Var Bool)
    | MatrixState Bool (Array (Dict Var Bool))


type Survey
    = Text Int Int
    | Vector Bool (List ( Var, Inlines )) Int
    | Matrix Bool (List Var) MultInlines Int
