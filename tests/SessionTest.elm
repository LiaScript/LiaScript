module SessionTest exposing (suite)

import Base64
import Expect
import Session exposing (decodeRoom, encodeOwnerLink, encodeRoom)
import Test exposing (Test, describe, test)


room : { ownerTokenHash : String, pwSalt : String, pwCheck : String, ownerToken : Maybe String } -> Session.Room
room extra =
    { backend = "WebSocket|wss://example.com"
    , course = "https://example.com/README.md"
    , room = "my-room"
    , mode = 0
    , ownerTokenHash = extra.ownerTokenHash
    , pwSalt = extra.pwSalt
    , pwCheck = extra.pwCheck
    , ownerToken = extra.ownerToken
    }


suite : Test
suite =
    describe "Session.encodeRoom / decodeRoom"
        [ test "roundtrips ownerTokenHash, pwSalt and pwCheck, but never re-materializes ownerToken" <|
            \_ ->
                let
                    r =
                        room
                            { ownerTokenHash = "hash789"
                            , pwSalt = "salt123"
                            , pwCheck = "hash456"
                            , ownerToken = Just "tok123"
                            }
                in
                r
                    |> encodeRoom
                    |> decodeRoom
                    |> Expect.equal (Just { r | ownerToken = Nothing })
        , test "roundtrips with ownerTokenHash, pwSalt and pwCheck empty" <|
            \_ ->
                let
                    r =
                        room { ownerTokenHash = "", pwSalt = "", pwCheck = "", ownerToken = Nothing }
                in
                r
                    |> encodeRoom
                    |> decodeRoom
                    |> Expect.equal (Just r)
        , test "a pre-existing link without the new keys still decodes, defaulting them" <|
            \_ ->
                -- Simulates a link generated before this feature existed -
                -- the keys are missing entirely, not present as `""`/`null`.
                "{\"backend\":\"WebSocket|wss://example.com\",\"course\":\"https://example.com/README.md\",\"room\":\"my-room\",\"mode\":0}"
                    |> Base64.encode
                    |> decodeRoom
                    |> Expect.equal (Just (room { ownerTokenHash = "", pwSalt = "", pwCheck = "", ownerToken = Nothing }))
        , test "encodeOwnerLink includes the raw ownerToken, unlike encodeRoom" <|
            \_ ->
                let
                    r =
                        room
                            { ownerTokenHash = "hash789"
                            , pwSalt = "salt123"
                            , pwCheck = "hash456"
                            , ownerToken = Just "tok123"
                            }
                in
                Expect.all
                    [ \_ ->
                        r
                            |> encodeOwnerLink
                            |> Base64.decode
                            |> Result.withDefault ""
                            |> String.contains "\"ownerToken\":\"tok123\""
                            |> Expect.equal True
                    , \_ ->
                        r
                            |> encodeRoom
                            |> Base64.decode
                            |> Result.withDefault ""
                            |> String.contains "\"ownerToken\":"
                            |> Expect.equal False
                    ]
                    ()
        ]
