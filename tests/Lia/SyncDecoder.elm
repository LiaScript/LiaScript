module Lia.SyncDecoder exposing (suite)

import Dict
import Expect
import Json.Decode as JD
import Lia.Chat.Sync as Chat
import Lia.Sync.Container as Container
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "classroom decoders skip malformed peer data"
        [ test "chat: a bad entry does not drop the valid ones" <|
            \_ ->
                """
                [ {"id": 1, "color": "red", "message": "hi", "user": "a", "verified": true}
                , {"id": null, "color": "red", "message": "bad id", "user": "b"}
                , {"id": 3, "color": "red", "message": 5, "user": "c"}
                , {"id": 4, "color": "blue", "message": "ok", "user": "d", "verified": false}
                ]
                """
                    |> JD.decodeString Chat.decoder
                    |> Result.map (List.map .id)
                    |> Expect.equal (Ok [ 1, 4 ])
        , test "container: a bad peer value does not block the others" <|
            \_ ->
                """[ {"a": 1, "b": "broken", "c": 3}, {} ]"""
                    |> JD.decodeString (Container.decoder JD.int)
                    |> Result.map (Container.get 0 >> Maybe.map Dict.toList)
                    |> Expect.equal (Ok (Just [ ( "a", 1 ), ( "c", 3 ) ]))
        ]
