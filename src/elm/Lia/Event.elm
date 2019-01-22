module Lia.Event exposing (Eval(..), Event, decodeEval, evalEvent, eventToJson, jsonToEvent)

import Json.Decode as JD
import Json.Encode as JE
import Lia.Utils exposing (string_replace)


type alias Event =
    { topic : String
    , section : Int
    , message : JE.Value
    }


type Eval
    = Eval String (List JE.Value)


eventToJson : Event -> JE.Value
eventToJson { topic, section, message } =
    JE.object
        [ ( "topic", JE.string topic )
        , ( "section", JE.int section )
        , ( "message", message )
        ]


jsonToEvent : JD.Value -> Result JD.Error Event
jsonToEvent json =
    JD.decodeValue
        (JD.map3 Event
            (JD.field "topic" JD.string)
            (JD.field "section" JD.int)
            (JD.field "message" JD.value)
        )
        json


evalEvent : Int -> String -> String -> Event
evalEvent idx code replacement =
    code
        |> string_replace ( "@input", replacement )
        |> JE.string
        |> Event "eval" idx


decodeEval : JD.Value -> Result Eval Eval
decodeEval message =
    case
        JD.decodeValue
            (JD.map3 toEval
                (JD.field "ok" JD.bool)
                (JD.field "result" JD.string)
                (JD.field "details" (JD.list JD.value))
            )
            message
    of
        Ok eval ->
            eval

        Err info ->
            Err (Eval (JD.errorToString info) [])


toEval : Bool -> String -> List JD.Value -> Result Eval Eval
toEval ok result details =
    if ok then
        Ok (Eval result details)

    else
        Err (Eval result details)
