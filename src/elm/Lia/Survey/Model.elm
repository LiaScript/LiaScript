module Lia.Survey.Model exposing
    ( get_matrix_state
    , get_submission_state
    , get_text_state
    , get_vector_state
    , json2vector
    , vector2json
    )

import Array
import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Survey.Types exposing (..)


get_submission_state : Vector -> Int -> Bool
get_submission_state vector idx =
    case Array.get idx vector of
        Just ( True, _ ) ->
            True

        _ ->
            False


get_text_state : Vector -> Int -> String
get_text_state vector idx =
    case Array.get idx vector of
        Just ( _, TextState str ) ->
            str

        _ ->
            ""


get_vector_state : Vector -> Int -> String -> Bool
get_vector_state vector idx var =
    case Array.get idx vector of
        Just ( _, VectorState _ state ) ->
            state
                |> Dict.get var
                |> Maybe.withDefault False

        _ ->
            False


get_matrix_state : Vector -> Int -> Int -> String -> Bool
get_matrix_state vector idx row var =
    case Array.get idx vector of
        Just ( _, MatrixState _ matrix ) ->
            matrix
                |> Array.get row
                |> Maybe.andThen (\d -> Dict.get var d)
                |> Maybe.withDefault False

        _ ->
            False


vector2json : Vector -> JE.Value
vector2json vector =
    JE.array element2json vector


element2json : Element -> JE.Value
element2json ( b, state ) =
    JE.object
        [ ( "submitted", JE.bool b )
        , ( "state", state2json state )
        ]


state2json : State -> JE.Value
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
                , ( "value", JE.array dict2json matrix )
                ]

            MatrixState False matrix ->
                [ ( "type", JE.string "MultipleChoiceBlock" )
                , ( "value", JE.array dict2json matrix )
                ]


json2vector : JD.Value -> Result JD.Error Vector
json2vector json =
    JD.decodeValue (JD.array json2element) json


json2element : JD.Decoder Element
json2element =
    JD.map2 Tuple.pair
        (JD.field "submitted" JD.bool)
        (JD.field "state" json2state)


json2state : JD.Decoder State
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
