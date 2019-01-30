module Lia.Markdown.Survey.Json exposing
    ( fromVector
    , toVector
    )

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Types exposing (Element, State(..), Vector)


fromVector : Vector -> JE.Value
fromVector vector =
    JE.array fromElement vector


fromElement : Element -> JE.Value
fromElement ( b, state ) =
    JE.object
        [ ( "submitted", JE.bool b )
        , ( "state", fromState state )
        ]


fromState : State -> JE.Value
fromState state =
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


toVector : JD.Value -> Result JD.Error Vector
toVector json =
    JD.decodeValue (JD.array toElement) json


toElement : JD.Decoder Element
toElement =
    JD.map2 Tuple.pair
        (JD.field "submitted" JD.bool)
        (JD.field "state" toState)


toState : JD.Decoder State
toState =
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
