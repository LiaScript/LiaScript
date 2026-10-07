module Gallery.Update exposing (suite)

{-| The gallery update only maintains `gallery_vector`: one slot per gallery,
holding the index of the media shown in the lightbox, or -1 if it is closed.
-}

import Array
import Expect
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Gallery.Types exposing (Vector)
import Lia.Markdown.Gallery.Update exposing (Msg(..), handle, update)
import Service.Event as Event
import Test exposing (Test, describe, test)


{-| Three galleries, all closed.
-}
closed : Vector
closed =
    Array.fromList [ -1, -1, -1 ]


{-| Run `update` and keep only the comparable parts of the `Return` (a `Cmd`
cannot be compared in Elm, so `command` is left out).
-}
run : Msg () -> Vector -> { value : Vector, events : Int, sub : Maybe (Script.Msg ()) }
run msg vector =
    let
        return =
            update msg vector
    in
    { value = return.value
    , events = List.length return.events
    , sub = return.sub
    }


onlyValue : Vector -> { value : Vector, events : Int, sub : Maybe (Script.Msg ()) }
onlyValue vector =
    { value = vector, events = 0, sub = Nothing }


suite : Test
suite =
    describe "Lia.Markdown.Gallery.Update"
        [ describe "Show"
            [ test "opens the lightbox of one gallery at the given media" <|
                \_ ->
                    run (Show 1 2) closed
                        |> Expect.equal (onlyValue (Array.fromList [ -1, 2, -1 ]))
            , test "switches to another media of an open gallery" <|
                \_ ->
                    run (Show 0 3) (Array.fromList [ 1, -1, -1 ])
                        |> Expect.equal (onlyValue (Array.fromList [ 3, -1, -1 ]))
            , test "ignores an unknown gallery id" <|
                \_ ->
                    run (Show 5 0) closed
                        |> Expect.equal (onlyValue closed)
            , test "ignores a negative gallery id" <|
                \_ ->
                    run (Show -1 0) closed
                        |> Expect.equal (onlyValue closed)
            ]
        , describe "Close"
            [ test "closes an open lightbox" <|
                \_ ->
                    run (Close 2) (Array.fromList [ 0, 1, 4 ])
                        |> Expect.equal (onlyValue (Array.fromList [ 0, 1, -1 ]))
            , test "closing an already closed lightbox changes nothing" <|
                \_ ->
                    run (Close 0) closed
                        |> Expect.equal (onlyValue closed)
            , test "ignores an unknown gallery id" <|
                \_ ->
                    run (Close 3) (Array.fromList [ 1 ])
                        |> Expect.equal (onlyValue (Array.fromList [ 1 ]))
            ]
        , describe "Script"
            [ test "passes the script message on without touching the vector" <|
                \_ ->
                    run (Script (Script.Click 7)) (Array.fromList [ 2 ])
                        |> Expect.equal
                            { value = Array.fromList [ 2 ]
                            , events = 0
                            , sub = Just (Script.Click 7)
                            }
            ]
        , describe "Handle"
            [ test "handle wraps an event into Handle" <|
                \_ ->
                    handle Event.none
                        |> Expect.equal (Handle Event.none)
            , test "events are ignored" <|
                \_ ->
                    run (handle (Event.init "gallery" { cmd = "show", param = Event.none.message.param })) (Array.fromList [ 1, -1 ])
                        |> Expect.equal (onlyValue (Array.fromList [ 1, -1 ]))
            ]
        ]
