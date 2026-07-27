module Lia.Sync.Classroom exposing (Entry, decoder)

import Json.Decode as JD


{-| A saved classroom, as stored in the per-course `classrooms` Dexie table
and returned by the `sync` service's `"classrooms"` reply. `backend` is the
full pipe-encoded string produced by `Lia.Sync.Via.toString True` — decode it
back into a `Via.Backend` with `Via.fromString` when the user picks this
entry to reconnect.
-}
type alias Entry =
    { room : String
    , backend : String
    , password : Maybe String
    , updated : Int
    }


decoder : JD.Decoder (List Entry)
decoder =
    JD.list entryDecoder


entryDecoder : JD.Decoder Entry
entryDecoder =
    JD.map4 Entry
        (JD.field "room" JD.string)
        (JD.field "backend" JD.string)
        (JD.field "password" (JD.nullable JD.string))
        (JD.field "updated" JD.int)
