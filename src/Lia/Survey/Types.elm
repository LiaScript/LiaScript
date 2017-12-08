module Lia.Survey.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Helper exposing (ID)
import Lia.Inline.Types exposing (Inlines, MultInlines)


type alias Var =
    String


type alias SurveyVector =
    Array SurveyElement


type alias SurveyElement =
    ( Bool, SurveyState )


type SurveyState
    = TextState String
    | VectorState Bool (Dict Var Bool)
    | MatrixState Bool (Array (Dict Var Bool))


type Survey
    = Text Int ID
    | Vector Bool (List ( Var, Inlines )) ID
    | Matrix Bool (List Var) MultInlines ID
