module Sync.View exposing (suite)

import Expect
import Html
import Html.Attributes
import Json.Encode as JE
import Lia.Sync.Types as Sync
import Lia.Sync.Update exposing (Msg(..), SyncMsg(..))
import Lia.Sync.Via as Via exposing (Backend(..))
import Lia.Sync.View as View
import Test exposing (Test, describe, test)
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Lia.Sync.View"
        [ describe "backend dropdown"
            [ test "opens by click while it can be changed, keys are handled by combobox.ts" <|
                \_ ->
                    View.view selected
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "lia-dropdown" ]
                        |> HE.simulate HE.click
                        |> HE.expect (Backend (Open True))
            , test "cannot be opened, neither by click nor by keyboard, while connected or locked" <|
                \_ ->
                    [ { selected | state = Sync.Connected "me" }
                    , { selected | state = Sync.Pending }
                    , { selected | locked = True }
                    ]
                        |> List.concatMap
                            (\settings ->
                                [ HE.click, key 13, key 32 ]
                                    |> List.map
                                        (\event ->
                                            View.view settings
                                                |> Query.fromHtml
                                                |> Query.find [ Selector.class "lia-dropdown" ]
                                                |> HE.simulate event
                                                |> HE.toResult
                                                |> Result.toMaybe
                                        )
                            )
                        |> List.filterMap identity
                        |> Expect.equal []
            , test "an open dropdown hides its options, as soon as it is locked" <|
                \_ ->
                    let
                        options settings check =
                            View.view settings
                                |> Query.fromHtml
                                |> Query.find [ Selector.class "lia-dropdown__options" ]
                                |> Query.children []
                                |> Query.count check
                    in
                    Expect.all
                        [ \_ -> options (withOpen selected) (Expect.greaterThan 0)
                        , \_ -> options (withOpen { selected | state = Sync.Connected "me" }) (Expect.equal 0)
                        , \_ -> options (withOpen { selected | locked = True }) (Expect.equal 0)
                        ]
                        ()
            ]
        , describe "links"
            [ test "all links open in a new tab and have a real target" <|
                \_ ->
                    [ Via.info, Via.infoOn (GUN { urls = "", persistent = False }), Via.infoOn (Nostr { relayUrls = "", persistent = False }), Via.infoOn Edrys ]
                        |> Html.div []
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Expect.all
                            [ Query.each (Query.has [ Selector.attribute (Html.Attributes.target "_blank") ])
                            , Query.each (Query.hasNot [ Selector.attribute (Html.Attributes.href "") ])
                            , Query.each (Query.hasNot [ Selector.containing [ Selector.text ", " ] ])
                            ]
            , test "the default relay lists are shown as text" <|
                \_ ->
                    [ Via.infoOn (GUN { urls = "", persistent = False }), Via.infoOn (Nostr { relayUrls = "", persistent = False }) ]
                        |> Html.div []
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "code" ]
                        |> Query.count (Expect.equal 2)
            ]
        ]


selected : Sync.Settings
selected =
    let
        base =
            Sync.init [ "gun" ]

        sync =
            base.sync
    in
    { base | room = "room", sync = { sync | select = Just ( True, GUN { urls = "a", persistent = False } ) } }


withOpen : Sync.Settings -> Sync.Settings
withOpen settings =
    let
        sync =
            settings.sync
    in
    { settings | sync = { sync | open = True } }


key : Int -> ( String, JE.Value )
key code =
    HE.custom "keydown" (JE.object [ ( "keyCode", JE.int code ), ( "shiftKey", JE.bool False ) ])
