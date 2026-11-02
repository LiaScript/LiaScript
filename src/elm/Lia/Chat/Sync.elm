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
    , verified : Bool
    }


type alias Changes =
    List Change


decoder : JD.Decoder Changes
decoder =
    -- one malformed entry (any peer can write one) must not drop the whole history
    JD.list (JD.maybe changeDecoder)
        |> JD.map (List.filterMap identity)


changeDecoder : JD.Decoder Change
changeDecoder =
    JD.map5 Change
        (JD.field "id" JD.int)
        (JD.field "color" JD.string)
        (JD.field "message" JD.string)
        (JD.field "user" JD.string)
        -- Older cached messages (persisted before chat signing existed)
        -- have no `verified` field at all - treat those as verified rather
        -- than flagging pre-existing history as suspicious.
        (JD.oneOf [ JD.field "verified" JD.bool, JD.succeed True ])
