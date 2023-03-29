module Lia.Chat.Sync exposing
    ( Change
    , Changes
    , decoder
    )

import Json.Decode as JD


type alias Change =
    { id : Int
    , color : String
    , message : String
    , user : String
    }


type alias Changes =
    List Change


decoder : JD.Decoder Changes
decoder =
    JD.list changeDecoder


changeDecoder : JD.Decoder Change
changeDecoder =
    JD.map4 Change
        (JD.field "id" JD.int)
        (JD.field "color" JD.string)
        (JD.field "message" JD.string)
        (JD.field "user" JD.string)
