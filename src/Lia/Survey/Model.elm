module Lia.Survey.Model
    exposing
        ( Model
        , get_matrix_state
        , get_submission_state
        , get_text_state
        , get_vector_state
        , json2model
        , model2json
        )

import Array
import Dict
import Json.Decode as JD
import Json.Encode as JE
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


model2json : SurveyVector -> JE.Value
model2json vector =
    vector
        |> Array.map element2json
        |> JE.array


element2json : SurveyElement -> JE.Value
element2json ( b, state ) =
    JE.object
        [ ( "submitted", JE.bool b )
        , ( "state", state2json state )
        ]


state2json : SurveyState -> JE.Value
state2json state =
    let
        dict2json dict =
            dict |> Dict.toList |> List.map (\( s, b ) -> ( s, JE.bool b )) |> JE.object
    in
    JE.object <|
        case state of
            TextState str ->
                [ ( "type", JE.string "Text" )
                , ( "value", JE.string str )
                ]

            VectorState True vector ->
                [ ( "type", JE.string "SingleChoice" )
                , ( "value", dict2json vector )
                ]

            VectorState False vector ->
                [ ( "type", JE.string "MultipleChoice" )
                , ( "value", dict2json vector )
                ]

            MatrixState True matrix ->
                [ ( "type", JE.string "SingleChoiceBlock" )
                , ( "value", matrix |> Array.map dict2json |> JE.array )
                ]

            MatrixState False matrix ->
                [ ( "type", JE.string "MultipleChoiceBlock" )
                , ( "value", matrix |> Array.map dict2json |> JE.array )
                ]


json2model : JD.Value -> Result String Model
json2model json =
    JD.decodeValue (JD.array json2element) json


json2element : JD.Decoder SurveyElement
json2element =
    JD.map2 (,)
        (JD.field "submitted" JD.bool)
        (JD.field "state" json2state)


json2state : JD.Decoder SurveyState
json2state =
    let
        value =
            JD.field "value"

        dict =
            JD.dict JD.bool

        state_decoder type_ =
            case type_ of
                "Text" ->
                    JD.map TextState (value JD.string)

                "SingleChoice" ->
                    JD.map (VectorState True) (value dict)

                "MultipleChoice" ->
                    JD.map (VectorState False) (value dict)

                "SingleChoiceBlock" ->
                    JD.map (MatrixState True) (value (JD.array dict))

                "MultipleChoiceBlock" ->
                    JD.map (MatrixState False) (value (JD.array dict))

                _ ->
                    JD.fail <|
                        "not supported type: "
                            ++ type_
    in
    JD.field "type" JD.string
        |> JD.andThen state_decoder
