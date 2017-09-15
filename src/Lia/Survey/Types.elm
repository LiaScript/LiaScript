module Lia.Survey.Types exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Encode exposing (..)
import Lia.Inline.Types exposing (ID, Line)


type alias Var =
    String


type alias SurveyVector =
    Array SurveyElement


type alias SurveyElement =
    ( Bool, SurveyState )


state2json state =
    let
        dict2json dict =
            dict |> Dict.toList |> List.map (\( s, b ) -> ( s, bool b )) |> object
    in
    object <|
        case state of
            TextState str ->
                [ ( "Text", string str ) ]

            SingleChoiceState vector ->
                [ ( "SingleChoice", dict2json vector ) ]

            MultiChoiceState vector ->
                [ ( "MultiChoice", dict2json vector ) ]

            SingleChoiceBlockState matrix ->
                [ ( "SingleChoiceBlock", matrix |> Array.map dict2json |> array ) ]

            MultiChoiceBlockState matrix ->
                [ ( "MultiChoiceBlock", matrix |> Array.map dict2json |> array ) ]


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
