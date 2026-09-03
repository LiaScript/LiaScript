module Sync.Classroom exposing (suite)

import Expect
import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Via as Via
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Sync.Classroom"
        [ test "decodes a list of saved classrooms" <|
            \_ ->
                let
                    json =
                        JE.list identity
                            [ JE.object
                                [ ( "room", JE.string "my-room" )
                                , ( "backend", JE.string (Via.toString True (Via.WebSocket { url = "wss://example.com" })) )
                                , ( "password", JE.string "secret" )
                                , ( "name", JE.string "Alice" )
                                , ( "updated", JE.int 1234 )
                                ]
                            , JE.object
                                [ ( "room", JE.string "__notes__" )
                                , ( "backend", JE.string (Via.toString True Via.Local) )
                                , ( "password", JE.null )
                                , ( "updated", JE.int 5678 )

                                -- no "name" field: records saved before this
                                -- field existed must still decode
                                ]
                            ]
                in
                json
                    |> JD.decodeValue Classroom.decoder
                    |> Expect.equal
                        (Ok
                            [ { room = "my-room"
                              , backend = "WebSocket|wss://example.com"
                              , password = Just "secret"
                              , name = Just "Alice"
                              , title = Nothing
                              , notes = Nothing
                              , updated = 1234
                              , mode = 0
                              , owner = False
                              , ownerTokenHash = ""
                              }
                            , { room = "__notes__"
                              , backend = "Local"
                              , password = Nothing
                              , name = Nothing
                              , title = Nothing
                              , notes = Nothing
                              , updated = 5678
                              , mode = 0
                              , owner = False
                              , ownerTokenHash = ""
                              }
                            ]
                        )
        , test "the stored backend string round-trips through Via.fromString" <|
            \_ ->
                Via.toString True (Via.WebSocket { url = "wss://example.com" })
                    |> Via.fromString
                    |> Expect.equal (Just (Via.WebSocket { url = "wss://example.com" }))
        , test "Local round-trips through Via.fromString" <|
            \_ ->
                Via.toString True Via.Local
                    |> Via.fromString
                    |> Expect.equal (Just Via.Local)
        ]
