module Lia.Quiz.Model
    exposing
        ( get_state
        , json2vector
        , vector2json
        )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Quiz.Types exposing (..)


get_state : Vector -> Int -> Maybe Element
get_state vector idx =
    vector
        |> Array.get idx


vector2json : Vector -> JE.Value
vector2json vector =
    JE.array <| Array.map element2json vector


element2json : Element -> JE.Value
element2json element =
    JE.object
        [ ( "solved"
          , JE.int
                (case element.solved of
                    Open ->
                        0

                    Solved ->
                        1

                    ReSolved ->
                        -1
                )
          )
        , ( "state", state2json element.state )
        , ( "trial", JE.int element.trial )
        , ( "hint", JE.int element.hint )
        ]


state2json : State -> JE.Value
state2json state =
    JE.object <|
        case state of
            EmptyState ->
                [ ( "type", JE.string "Empty" ) ]

            TextState x ->
                [ ( "type", JE.string "Text" )
                , ( "value", JE.string x )
                ]

            SingleChoiceState x ->
                [ ( "type", JE.string "SingleChoice" )
                , ( "value", JE.int x )
                ]

            MultipleChoiceState m ->
                [ ( "type", JE.string "MultipleChoice" )
                , ( "value", m |> Array.map JE.bool |> JE.array )
                ]


json2vector : JD.Value -> Result String Vector
json2vector json =
    JD.decodeValue (JD.array json2element) json


json2element : JD.Decoder Element
json2element =
    let
        solved_decoder i =
            case i of
                0 ->
                    JD.succeed Open

                1 ->
                    JD.succeed Solved

                _ ->
                    JD.succeed ReSolved
    in
    JD.map4 Element
        (JD.field "solved" JD.int |> JD.andThen solved_decoder)
        (JD.field "state" json2state)
        (JD.field "hints" JD.int)
        (JD.field "trial" JD.int)


json2state : JD.Decoder State
json2state =
    let
        state_decoder type_ =
            case type_ of
                "Text" ->
                    JD.map TextState (JD.field "value" JD.string)

                "SingleChoice" ->
                    JD.map SingleChoiceState (JD.field "value" JD.int)

                "MultipleChoice" ->
                    JD.map MultipleChoiceState (JD.field "value" (JD.array JD.bool))

                _ ->
                    JD.fail <|
                        "not supported type: "
                            ++ type_
    in
    JD.field "type" JD.string
        |> JD.andThen state_decoder
