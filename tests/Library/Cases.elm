module Library.Cases exposing (suite)

import Expect
import Html
import Html.Attributes as Attr
import Json.Encode as JE
import Library.Group as Group
import Library.IPFS as IPFS
import Library.Masonry as Masonry
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Sel


suite : Test
suite =
    describe "Library"
        [ test "IPFS" <|
            \_ ->
                [ IPFS.toHTTPS "x" "ipfs://Qm/a", IPFS.toHTTPS "x" "https://a", Maybe.withDefault "-" (IPFS.origin "https://ipfs.io/ipfs/Qm"), Maybe.withDefault "-" (IPFS.origin "https://a") ]
                    |> Expect.equal [ "https://ipfs.io/ipfs/Qm/a", "x", "ipfs://Qm", "-" ]
        , describe "Group.blur"
            [ test "focus moves into a child of the same group" <|
                \_ -> blur (JE.object [ ( "parentElement", JE.object [ ( "dataset", JE.object [ ( "groupId", JE.string "g" ) ] ) ] ) ]) |> Expect.equal (Err ())
            , test "focus leaves the group" <|
                \_ -> blur JE.null |> Expect.equal (Ok "g")
            ]
        , test "Masonry: unmeasured items go into the shortest column, the first on ties" <|
            \_ ->
                Masonry.init (Just "c") [ 1, 2, 3, 4, 5 ]
                    |> Tuple.first
                    |> Masonry.map ((*) 10)
                    |> Masonry.view { toView = \_ i -> Html.text (String.fromInt i), columns = 2, attributes = [] }
                    |> Query.fromHtml
                    |> Query.findAll [ Sel.class "elm-masonry-column" ]
                    |> Query.first
                    |> Query.children []
                    |> Expect.all
                        [ Query.count (Expect.equal 3)
                        , Query.index 2 >> Query.has [ Sel.text "50", Sel.id "elm-masonry-item-4-c", Sel.class "elm-masonry-item-height-unknown" ]
                        ]
        , test "SplitPane: dragging by 25 of 100 pixels" <|
            \_ -> drag JE.int 0 75 100
        , test "SplitPane: fractional coordinates" <|
            \_ -> drag JE.float 0.4 75.4 100.4
        , test "Overlay: drag, arrow keys and follow mode" <|
            \_ ->
                Overlay.init
                    |> overlay [ ( 1, Event.custom "mousedown" (page 100 100) ), ( 0, Event.custom "mousemove" (page 90 130) ), ( 0, Event.custom "mouseup" (page 0 0) ) ]
                    |> overlay [ ( 2, Event.custom "keydown" (JE.object [ ( "keyCode", JE.int 37 ) ]) ), ( 1, Event.custom "dblclick" (page 0 0) ) ]
                    |> (\m -> Overlay.view False [] m (Html.text ""))
                    |> Query.fromHtml
                    |> Query.find [ Sel.attribute (Attr.attribute "role" "region") ]
                    |> Query.has [ Sel.style "right" "40px", Sel.style "top" "130px", Sel.style "border" "5px solid #ff5722", Sel.attribute (Attr.attribute "aria-label" "Video playback controls - Current mode: Follow Mouse Movement") ]
        ]


drag : (a -> JE.Value) -> a -> a -> a -> Expect.Expectation
drag encode start to after =
    let
        splitter state =
            SplitPane.view SplitPane.Both identity (Html.text "a") (Html.text "b") state
                |> Query.fromHtml
                |> Query.children []
                |> Query.index 1

        fire name x state =
            Event.simulate (Event.custom name (JE.object [ ( "touches", JE.list JE.object [ [ ( "clientX", encode x ), ( "clientY", JE.int 0 ) ] ] ), parent ])) (splitter state)
                |> Event.toResult
                |> Result.map (\msg -> SplitPane.update msg state)
                |> Result.withDefault state
    in
    SplitPane.init
        |> fire "touchstart" start
        |> fire "touchmove" to
        |> fire "touchend" start
        |> fire "touchmove" after
        |> SplitPane.view SplitPane.Both identity (Html.text "a") (Html.text "b")
        |> Query.fromHtml
        |> Query.find [ Sel.class "pane-first-view" ]
        |> Query.has [ Sel.style "flex" "0.75" ]


parent : ( String, JE.Value )
parent =
    ( "currentTarget", JE.object [ ( "parentElement", JE.object [ ( "clientWidth", JE.int 100 ), ( "clientHeight", JE.int 100 ) ] ) ] )


page : Int -> Int -> JE.Value
page x y =
    JE.object [ ( "pageX", JE.int x ), ( "pageY", JE.int y ) ]


blur : JE.Value -> Result () String
blur related =
    Html.div [ Group.id "g", Group.blur identity ] []
        |> Query.fromHtml
        |> Event.simulate (Event.custom "blur" (JE.object [ ( "target", JE.object [ ( "dataset", JE.object [ ( "groupId", JE.string "g" ) ] ) ] ), ( "relatedTarget", related ) ]))
        |> Event.toResult
        |> Result.mapError (always ())


{-| Fire events on the background (0), the drag handle (1) or the overlay itself (2).
-}
overlay : List ( Int, ( String, JE.Value ) ) -> Overlay.Model -> Overlay.Model
overlay events model =
    List.foldl
        (\( target, event ) m ->
            Overlay.view False [] m (Html.text "")
                |> Query.fromHtml
                |> (case target of
                        0 ->
                            Query.find [ Sel.style "z-index" "40" ]

                        1 ->
                            Query.find [ Sel.attribute (Attr.attribute "role" "region") ] >> Query.children [] >> Query.index 1

                        _ ->
                            Query.find [ Sel.attribute (Attr.attribute "role" "region") ]
                   )
                |> Event.simulate event
                |> Event.toResult
                |> Result.map (\msg -> Overlay.update msg m)
                |> Result.withDefault m
        )
        model
        events
