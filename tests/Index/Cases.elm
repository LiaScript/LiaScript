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
import Lia.Index.Update as Index exposing (Msg(..))
import Lia.Index.View as View
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Section as Section exposing (Section)
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
                            Index.update (ScanIndex p) "old" sections
                    in
                    ( model, visibility result )
                        |> Expect.equal ( p, List.map (\( code, title ) -> oracle p (code ++ title)) pages )
            , test "words may span code and title" <|
                \_ ->
                    Index.update (ScanIndex "ab") "" (course [ ( "xa", "bx" ), ( "a", "x" ) ])
                        |> (\( _, result, _ ) -> visibility result)
                        |> Expect.equal [ True, False ]
            , test "DeleteSearch shows all sections again" <|
                \_ ->
                    let
                        ( _, hidden, _ ) =
                            Index.update (ScanIndex "zzz") "" (course [ ( "a", "b" ), ( "c", "d" ) ])

                        ( model, result, _ ) =
                            Index.update DeleteSearch "zzz" hidden
                    in
                    ( model, visibility hidden, visibility result )
                        |> Expect.equal ( "", [ False, False ], [ True, True ] )
            , test "NoOp changes nothing" <|
                \_ ->
                    let
                        ( _, hidden, _ ) =
                            Index.update (ScanIndex "a") "" (course [ ( "a", "b" ), ( "c", "d" ) ])

                        ( model, result, _ ) =
                            Index.update NoOp "a" hidden
                    in
                    ( model, visibility result )
                        |> Expect.equal ( "a", [ True, False ] )
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
                   , test "other keys are not handled" <|
                        \_ ->
                            searchView True [ True ] "a"
                                |> Query.find [ Selector.tag "input" ]
                                |> HE.simulate (HE.custom "keydown" (JE.object [ ( "key", JE.string "ArrowLeft" ), ( "keyCode", JE.int 37 ), ( "shiftKey", JE.bool False ) ]))
                                |> HE.toResult
                                |> Result.toMaybe
                                |> Expect.equal Nothing
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
                Index.update (ScanIndex "c") "" (course [ ( "a", "b" ), ( "c", "d" ), ( "c", "**e**" ) ])
        in
        Html.div [] (View.content En True 1 identity (Array.map (\s -> { s | indentation = s.id + 1 }) sections))
            |> Html.map (always ())
            |> Html.map (always NoOp)
      )
    , ( "content inactive", Html.div [] (View.content En False 0 identity (course [ ( "a", "b" ) ])) |> Html.map (always NoOp) )
    , ( "bottom", View.bottom En True NoOp )
    , ( "bottom inactive", View.bottom De False NoOp )
    ]


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
