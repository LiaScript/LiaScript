module Lia.Survey.Model
    exposing
        ( Model
        , get_matrix_state
        , get_submission_state
        , get_text_state
        , get_vector_state
        , model2json
        )

import Array
import Dict
import Json.Encode exposing (Value, array, bool, object, string)
import Lia.Survey.Types exposing (..)


type alias Model =
    SurveyVector


get_submission_state : Model -> Int -> Bool
get_submission_state model idx =
    case Array.get idx model of
        Just ( True, _ ) ->
            True

        _ ->
            False


get_text_state : Model -> Int -> String
get_text_state model idx =
    case Array.get idx model of
        Just ( _, TextState str ) ->
            str

        _ ->
            ""


get_vector_state : Model -> Int -> String -> Bool
get_vector_state model idx var =
    case Array.get idx model of
        Just ( _, VectorState _ state ) ->
            state
                |> Dict.get var
                |> Maybe.withDefault False

        _ ->
            False


get_matrix_state : Model -> Int -> Int -> String -> Bool
get_matrix_state model idx row var =
    case Array.get idx model of
        Just ( _, MatrixState _ matrix ) ->
            matrix
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False

        _ ->
            False


model2json : SurveyVector -> Value
model2json vector =
    vector
        |> Array.map element2json
        |> array


element2json : SurveyElement -> Value
element2json ( b, state ) =
    object
        [ ( "submitted", bool b )
        , ( "state", state2json state )
        ]


state2json : SurveyState -> Value
state2json state =
    let
        dict2json dict =
            dict |> Dict.toList |> List.map (\( s, b ) -> ( s, bool b )) |> object
    in
    object <|
        case state of
            TextState str ->
                [ ( "Text", string str ) ]

            VectorState True vector ->
                [ ( "SingleChoice", dict2json vector ) ]

            VectorState False vector ->
                [ ( "MultiChoice", dict2json vector ) ]

            MatrixState True matrix ->
                [ ( "SingleChoiceBlock", matrix |> Array.map dict2json |> array ) ]

            MatrixState False matrix ->
                [ ( "MultiChoiceBlock", matrix |> Array.map dict2json |> array ) ]
