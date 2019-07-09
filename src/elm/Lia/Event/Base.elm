module Lia.Event.Base exposing
    ( Event
    , decode
    , encode
    , store
    )

import Json.Decode as JD
import Json.Encode as JE


type alias Event =
    { topic : String
    , section : Int
    , message : JE.Value
    }


encode : Event -> JE.Value
encode { topic, section, message } =
    JE.object
        [ ( "topic", JE.string topic )
        , ( "section", JE.int section )
        , ( "message", message )
        ]


decode : JD.Value -> Result JD.Error Event
decode json =
    JD.decodeValue
        (JD.map3 Event
            (JD.field "topic" JD.string)
            (JD.field "section" JD.int)
            (JD.field "message" JD.value)
        )
        json


store : JE.Value -> Event
store message =
    Event "store" -1 message
