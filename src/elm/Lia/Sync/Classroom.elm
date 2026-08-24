module Lia.Sync.Classroom exposing (Entry, decoder, notesRoomName)

import Json.Decode as JD
import Json.Decode.Pipeline as JDP


{-| A saved classroom, as stored in the per-course `classrooms` Dexie table
and returned by the `sync` service's `"classrooms"` reply. `backend` is the
full pipe-encoded string produced by `Lia.Sync.Via.toString True` — decode it
back into a `Via.Backend` with `Via.fromString` when the user picks this
entry to reconnect. `owner` mirrors whether this browser was the CRDT owner
the last time it connected (see the `"ownership"` event in
`Lia.Sync.Update`) — it is only known live, once connected, so it is written
back after the fact rather than at the initial save.
-}
type alias Entry =
    { room : String
    , backend : String
    , password : Maybe String
    , name : Maybe String
    , title : Maybe String
    , notes : Maybe String
    , updated : Int
    , mode : Int
    , owner : Bool
    }


decoder : JD.Decoder (List Entry)
decoder =
    JD.list entryDecoder


entryDecoder : JD.Decoder Entry
entryDecoder =
    JD.succeed Entry
        |> JDP.required "room" JD.string
        |> JDP.required "backend" JD.string
        |> JDP.required "password" (JD.nullable JD.string)
        |> JDP.optional "name" (JD.nullable JD.string) Nothing
        |> JDP.optional "title" (JD.nullable JD.string) Nothing
        |> JDP.optional "notes" (JD.nullable JD.string) Nothing
        |> JDP.required "updated" JD.int
        |> JDP.optional "mode" JD.int 0
        |> JDP.optional "owner" JD.bool False


{-| The fixed room name used for the "Own Notes" shortcut — a purely local,
never-networked classroom that every course gets for free.
-}
notesRoomName : String
notesRoomName =
    "__notes__"
