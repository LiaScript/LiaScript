module Index.Cases exposing (suite)

{-| Characterization tests of `Lia.Index`: the section search and the table of
contents.
-}

import Array exposing (Array)
import Expect
import Fuzz
import Html
import HtmlSnapshot
import I18n.Translations exposing (Lang(..))
import Index.Snapshots exposing (snapshots)
import Json.Encode as JE
import Lia.Index.Model as IndexModel
import Lia.Index.Update as Index exposing (Msg(..))
import Lia.Index.View as View
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Section as Section exposing (Section)
import Set
import Test exposing (Test, describe, fuzz2, test)
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Lia.Index"
        [ describe "update"
            [ fuzz2 (Fuzz.list (Fuzz.pair word word)) pattern "a section is visible, if its code and title contain all words" <|
                \pages p ->
                    let
                        sections =
                            course pages

                        ( model, result, _ ) =
                            Index.update (ScanIndex p) (search "old") sections
                    in
                    ( model.search, visibility result )
                        |> Expect.equal ( p, List.map (\( code, title ) -> oracle p (code ++ title)) pages )
            , test "words may span code and title" <|
                \_ ->
                    Index.update (ScanIndex "ab") (search "") (course [ ( "xa", "bx" ), ( "a", "x" ) ])
                        |> (\( _, result, _ ) -> visibility result)
                        |> Expect.equal [ True, False ]
            , test "DeleteSearch shows all sections again" <|
                \_ ->
                    let
                        ( _, hidden, _ ) =
                            Index.update (ScanIndex "zzz") (search "") (course [ ( "a", "b" ), ( "c", "d" ) ])

                        ( model, result, _ ) =
                            Index.update DeleteSearch (search "zzz") hidden
                    in
                    ( model.search, visibility hidden, visibility result )
                        |> Expect.equal ( "", [ False, False ], [ True, True ] )
            , test "NoOp changes nothing" <|
                \_ ->
                    let
                        ( _, hidden, _ ) =
                            Index.update (ScanIndex "a") (search "") (course [ ( "a", "b" ), ( "c", "d" ) ])

                        ( model, result, _ ) =
                            Index.update NoOp (search "a") hidden
                    in
                    ( model.search, visibility result )
                        |> Expect.equal ( "a", [ True, False ] )
            , test "tree keys move between the visible entries" <|
                \_ ->
                    [ press (search "") False "ArrowDown" 0
                    , press (search "") False "ArrowUp" 0
                    , press (search "") False "ArrowUp" 3
                    , press (search "") False "Home" 3
                    , press (search "") False "End" 0
                    , press { search = "", collapsed = Set.fromList [ 1 ], focus = Nothing, defaults = True } False "ArrowDown" 1
                    ]
                        |> Expect.equal
                            [ ( Just 1, [] )
                            , ( Nothing, [] )
                            , ( Just 2, [] )
                            , ( Just 0, [] )
                            , ( Just 4, [] )
                            , ( Just 3, [ 1 ] )
                            ]
            , test "Right opens a section or moves to its first subsection, Left closes it or moves to its parent" <|
                \_ ->
                    [ press (search "") False "ArrowRight" 0
                    , press { search = "", collapsed = Set.fromList [ 1 ], focus = Nothing, defaults = True } False "ArrowRight" 1
                    , press (search "") False "ArrowLeft" 1
                    , press (search "") False "ArrowLeft" 2
                    , press (search "") False "ArrowRight" 2
                    , press (search "") True "ArrowLeft" 0
                    , press (search "") True "ArrowRight" 1
                    ]
                        |> Expect.equal
                            [ ( Just 1, [] )
                            , ( Nothing, [] )
                            , ( Nothing, [ 1 ] )
                            , ( Just 1, [] )
                            , ( Nothing, [] )
                            , ( Just 1, [] )
                            , ( Nothing, [ 1 ] )
                            ]
            , test "reveal collapses the sections below the two upper levels once, and opens the branch of the current section" <|
                \_ ->
                    let
                        first =
                            Index.reveal 4 levels { search = "", collapsed = Set.empty, focus = Nothing, defaults = False }

                        deep =
                            Index.reveal 2 levels first

                        closedAgain =
                            Index.reveal 4 levels { deep | collapsed = Set.insert 0 deep.collapsed }
                    in
                    [ Set.toList first.collapsed, Set.toList deep.collapsed, Set.toList closedAgain.collapsed ]
                        |> Expect.equal [ [ 1 ], [], [ 0 ] ]
            , test "Toggle collapses and expands the subsections of a section" <|
                \_ ->
                    let
                        ( once, _, _ ) =
                            Index.update (Toggle 1) (search "") (course [ ( "a", "b" ) ])

                        ( twice, _, _ ) =
                            Index.update (Toggle 1) once (course [ ( "a", "b" ) ])
                    in
                    ( Set.toList once.collapsed, Set.toList twice.collapsed )
                        |> Expect.equal ( [ 1 ], [] )
            ]
        , describe "view"
            (List.map
                (\( name, html ) ->
                    test name <|
                        \_ ->
                            HtmlSnapshot.toString html
                                |> Expect.equal (snapshots |> List.filter (Tuple.first >> (==) name) |> List.head |> Maybe.map Tuple.second |> Maybe.withDefault ("RECORD:" ++ name ++ "\n" ++ HtmlSnapshot.toString html))
                )
                views
                ++ [ test "typing searches" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.input "abc")
                                |> HE.expect (ScanIndex "abc")
                   , test "Enter resets the search" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.custom "keydown" (JE.object [ ( "key", JE.string "Enter" ), ( "keyCode", JE.int 13 ), ( "shiftKey", JE.bool False ) ]))
                                |> HE.expect (ScanIndex "")
                   , test "other keys do not reach the slide navigation" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.custom "keydown" (JE.object [ ( "key", JE.string "ArrowLeft" ), ( "keyCode", JE.int 37 ), ( "shiftKey", JE.bool False ) ]))
                                |> Expect.all [ HE.expect NoOp, HE.expectStopPropagation ]
                   , test "Enter does not reach the slide navigation either" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.custom "keydown" (JE.object [ ( "key", JE.string "Enter" ), ( "keyCode", JE.int 13 ), ( "shiftKey", JE.bool False ) ]))
                                |> HE.expectStopPropagation
                   , test "Shift+Enter keeps the search" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.custom "keydown" (JE.object [ ( "key", JE.string "Enter" ), ( "keyCode", JE.int 13 ), ( "shiftKey", JE.bool True ) ]))
                                |> HE.expect NoOp
                   , test "the clear button deletes the search" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "button" ]
                                |> HE.simulate HE.click
                                |> HE.expect DeleteSearch
                   , test "the home button sends its message" <|
                        \_ ->
                            View.bottom En True "home"
                                |> Query.fromHtml
                                |> HE.simulate HE.click
                                |> HE.expect "home"
                   ]
            )
        ]


views : List ( String, Html.Html Msg )
views =
    [ ( "search empty", Html.div [] (View.search En True (Array.fromList [ { visible = True } ]) "") )
    , ( "search inactive", Html.div [] (View.search De False (Array.fromList [ { visible = True } ]) "") )
    , ( "search no result", Html.div [] (View.search En True (Array.fromList [ { visible = False }, { visible = False } ]) "x") )
    , ( "search one result", Html.div [] (View.search En True (Array.fromList [ { visible = False }, { visible = True } ]) "x") )
    , ( "search results", Html.div [] (View.search En False (Array.fromList [ { visible = True }, { visible = True }, { visible = False } ]) "x") )
    , ( "content"
      , let
            ( _, sections, _ ) =
                Index.update (ScanIndex "c") (search "") (course [ ( "a", "b" ), ( "c", "d" ), ( "c", "**e**" ) ])
        in
        Html.div [] (View.content En True 1 (always ()) (always ()) (search "c") (Array.map (\s -> { s | indentation = s.id + 1 }) sections))
            |> Html.map (always NoOp)
      )
    , ( "content inactive", Html.div [] (View.content En False 0 (always ()) (always ()) (search "") (course [ ( "a", "b" ) ])) |> Html.map (always NoOp) )
    , ( "content nested", tree (search "") )
    , ( "content collapsed", tree { search = "", collapsed = Set.fromList [ 0 ], focus = Nothing, defaults = True } )
    , ( "content nested while searching", tree { search = "x", collapsed = Set.fromList [ 0 ], focus = Nothing, defaults = True } )
    , ( "bottom", View.bottom En True NoOp )
    , ( "bottom inactive", View.bottom De False NoOp )
    ]


{-| Sections with the levels 1, 2, 3, 2 and 1.
-}
tree : IndexModel.Model -> Html.Html Msg
tree model =
    levels
        |> View.content En True 4 (always NoOp) identity model
        |> Html.div []


levels : Array Section
levels =
    course [ ( "a", "A" ), ( "b", "B" ), ( "c", "C" ), ( "d", "D" ), ( "e", "E" ) ]
        |> Array.indexedMap (\i s -> { s | indentation = [ 1, 2, 3, 2, 1 ] |> List.drop i |> List.head |> Maybe.withDefault 1 })


{-| The entry with the focus after pressing `key` on entry `id` of `levels`,
or the collapsed sections, if the key opened or closed one.
-}
press : IndexModel.Model -> Bool -> String -> Int -> ( Maybe Int, List Int )
press model rtl key id =
    Index.update (Key { current = 4, key = key, rtl = rtl, id = id }) model levels
        |> (\( m, _, _ ) -> ( Maybe.map Tuple.second m.focus, Set.toList m.collapsed ))


search : String -> IndexModel.Model
search s =
    { search = s, collapsed = Set.empty, focus = Nothing, defaults = True }


searchView : Bool -> List Bool -> String -> Query.Single Msg
searchView active results model =
    View.search En active (Array.fromList (List.map (\v -> { visible = v }) results)) model
        |> Html.div []
        |> Query.fromHtml


course : List ( String, String ) -> Array Section
course pages =
    pages
        |> List.indexedMap (\i ( code, title ) -> Section.init 0 i { indentation = 1, title = [ Chars title [] ], code = code })
        |> Array.fromList


visibility : Array Section -> List Bool
visibility =
    Array.toList >> List.map .visible


oracle : String -> String -> Bool
oracle p text =
    p
        |> String.toLower
        |> String.split " "
        |> List.filter ((/=) "")
        |> List.all (\w -> String.contains w (String.toLower text))


word : Fuzz.Fuzzer String
word =
    Fuzz.oneOfValues [ "", "a", "B", "ab", "a b", "Ä", "x y", " ", "ba", "AB c" ]
        |> Fuzz.listOfLengthBetween 0 3
        |> Fuzz.map String.concat


pattern : Fuzz.Fuzzer String
pattern =
    Fuzz.oneOfValues [ "", " ", "x", "a", "A", "b", "ab", "a b", " b  a ", "ä", "c", "x y", "ba", "b\ta" ]
