module Lia.Survey.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Inline.Types exposing (ID, Line)


type alias Var =
    String


type alias SurveyVector =
    Array SurveyElement


type alias SurveyElement =
    ( Bool, SurveyState )


type SurveyState
    = TextState String
    | SingleChoiceState (Dict Var Bool)
    | MultiChoiceState (Dict Var Bool)
    | SingleChoiceBlockState (Array (Dict Var Bool))
    | MultiChoiceBlockState (Array (Dict Var Bool))


type Survey
    = Text Int ID
    | SingleChoice (List ( Var, Line )) ID
    | MultiChoice (List ( Var, Line )) ID
    | SingleChoiceBlock (List Var) (List Line) ID
    | MultiChoiceBlock (List Var) (List Line) ID
