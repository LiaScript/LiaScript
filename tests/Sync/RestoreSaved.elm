module Sync.RestoreSaved exposing (suite)

import Expect
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Types as Sync exposing (Settings)
import Test exposing (Test, describe, test)


backend : String
backend =
    "Nostr|f|wss://relay.example"


{-| The settings after opening the page with this room in its URL - a reload
of a connected classroom, a bookmark, the browser's history.
-}
fromUrl : Settings
fromUrl =
    Sync.init [ "nostr" ]
        |> Sync.initRoom
            { backend = backend
            , course = "https://example.com/README.md"
            , room = "room-1"
            , mode = 2
            , ownerTokenHash = "hash"
            , pwSalt = ""
            , pwCheck = ""
            , ownerToken = Nothing
            }


saved : Classroom.Entry
saved =
    { room = "room-1"
    , backend = backend
    , password = Just "secret"
    , name = Just "Teacher"
    , title = Just "Monday"
    , notes = Just "Lecture"
    , updated = 0
    , mode = 2
    , owner = True
    , ownerTokenHash = "hash"
    }


restore : List Classroom.Entry -> Settings -> Settings
restore entries settings =
    Sync.restoreSaved { settings | saved = entries }


suite : Test
suite =
    describe "Lia.Sync.Types.restoreSaved"
        [ test "a room from the URL that this browser saved keeps using its local cache" <|
            \_ ->
                fromUrl
                    |> restore [ saved ]
                    |> .persistent
                    |> Expect.equal True
        , test "restores what the saved classroom knows about this browser" <|
            \_ ->
                fromUrl
                    |> restore [ saved ]
                    |> (\s -> ( ( s.name, s.password ), ( s.title, s.notes ), s.owner ))
                    |> Expect.equal ( ( "Teacher", "secret" ), ( "Monday", "Lecture" ), True )
        , test "does not overwrite a name or password that was already typed" <|
            \_ ->
                { fromUrl | name = "Other", password = "typed" }
                    |> restore [ saved ]
                    |> (\s -> ( s.name, s.password ))
                    |> Expect.equal ( "Other", "typed" )
        , test "an unknown room stays without a local cache" <|
            \_ ->
                fromUrl
                    |> restore [ { saved | room = "room-2" } ]
                    |> .persistent
                    |> Expect.equal False
        , test "the same room on another backend is another classroom" <|
            \_ ->
                fromUrl
                    |> restore [ { saved | backend = "Nostr|f|wss://other.example" } ]
                    |> .persistent
                    |> Expect.equal False
        , test "the same room in another mode is another classroom" <|
            \_ ->
                fromUrl
                    |> restore [ { saved | mode = 1 } ]
                    |> .persistent
                    |> Expect.equal False
        , test "a room that was not opened from the URL is left alone" <|
            \_ ->
                { fromUrl | fromUrl = False }
                    |> restore [ saved ]
                    |> .persistent
                    |> Expect.equal False
        , test "an already connected room is left alone" <|
            \_ ->
                { fromUrl | state = Sync.Connected "me" }
                    |> restore [ saved ]
                    |> .persistent
                    |> Expect.equal False
        ]
