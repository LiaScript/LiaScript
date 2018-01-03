module Lia.Survey.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Helper exposing (ID)
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
    = Text Int ID
    | Vector Bool (List ( Var, Inlines )) ID
    | Matrix Bool (List Var) MultInlines ID
