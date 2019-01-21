module Lia.Event exposing (Event, eventToJson, jsonToEvent)

import Json.Decode as JD
import Json.Encode as JE


type alias Event =
    { topic : String
    , section : Int
    , message : JE.Value
    }


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
