module Utils.Cases exposing (suite)

{-| Characterization tests of `Lia.Utils`.
-}

import Array
import Dict
import Expect
import Html
import Html.Attributes as Attr
import HtmlSnapshot
import Json.Encode as JE
import Lia.Utils as Utils
import Test exposing (Test, describe, test)
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Lia.Utils"
        [ examples "toEscapeString"
            Utils.toEscapeString
            [ ( "javascript \" \n", "javascript \\\" \\n" )
            , ( "a\\b 'c' `d` \t ${e}", "a\\\\b \\'c\\' \\`d\\` \\t \\${e}" )
            ]
        , examples "get"
            (\( i, list ) -> Utils.get i list)
            [ ( ( 2, [ 1, 2, 3, 4, 5 ] ), Just 3 )
            , ( ( 0, [ 1 ] ), Just 1 )
            , ( ( -3, [ 7, 8 ] ), Just 7 )
            , ( ( 2, [ 7, 8 ] ), Nothing )
            , ( ( 0, [] ), Nothing )
            ]
        , examples "array_getLast / array_setLast"
            (\list -> ( Utils.array_getLast (Array.fromList list), Utils.array_setLast 9 (Array.fromList list) |> Array.toList ))
            [ ( [ 1, 2, 3 ], ( Just 3, [ 1, 2, 9 ] ) )
            , ( [], ( Nothing, [] ) )
            ]
        , examples "string2Color"
            (\( max, str ) -> Utils.string2Color max str)
            [ ( ( 255, "red" ), "rgb(5,200,112)" )
            , ( ( 255, "RED" ), "rgb(228,168,80)" )
            , ( ( 111, "RED" ), "rgb(93,57,80)" )
            , ( ( 255, "" ), "rgb(146,99,12)" )
            , ( ( 180, "abcd" ), "rgb(148,17,111)" )
            , ( ( 180, "abcde" ), "rgb(148,118,111)" )
            ]
        , examples "identicon"
            Utils.identicon
            [ ( "peer-1", { color = "rgb(177,65,162)", symbol = "🐯" } )
            , ( "", { color = "rgb(131,99,12)", symbol = "🐶" } )
            ]
        , test "percentage" <|
            \_ ->
                [ Utils.percentage 3.14159 1, Utils.percentage 3 2, Utils.percentage 8 1, Utils.percentage 3 -1 ]
                    |> List.map2 (\expected value -> \_ -> Expect.within (Expect.Absolute 0.000001) expected value) [ 31.83, 66.67, 12.5, -33.33 ]
                    |> (\checks -> Expect.all checks ())
        , examples "checkFalse"
            Utils.checkFalse
            [ ( "0", False )
            , ( " FALSE ", False )
            , ( "false-ish", False )
            , ( "off", False )
            , ( "Offline", False )
            , ( "disabled", False )
            , ( "disable", False )
            , ( "disab", True )
            , ( "disabl", True )
            , ( "00", True )
            , ( "", True )
            , ( "true", True )
            , ( "fals", True )
            , ( "of", True )
            ]
        , examples "checkPersistency"
            (Dict.fromList >> Utils.checkPersistency)
            [ ( [ ( "persistent", "true" ) ], True )
            , ( [ ( "persistent", "off" ) ], False )
            , ( [], False )
            ]
        , examples "urlBasePath"
            Utils.urlBasePath
            [ ( "http://xy.com/path/file.me", Just "http://xy.com/path/" )
            , ( "somefileonly.md", Just "/" )
            , ( "", Just "/" )
            ]
        , examples "urlQuery"
            Utils.urlQuery
            [ ( "https://a.b/c?x=1", Just "x=1" )
            , ( "a?b?c", Just "c" )
            , ( "no query", Nothing )
            , ( "a?", Just "" )
            ]
        , examples "shuffle"
            (\order -> Utils.shuffle order [ "a", "b", "c" ])
            [ ( Nothing, [ "a", "b", "c" ] )
            , ( Just [ 2, 0, 1 ], [ "b", "c", "a" ] )
            , ( Just [ 1, 0 ], [ "b", "a" ] )
            ]
        , examples "urlDecodeIfEncoded"
            Utils.urlDecodeIfEncoded
            [ ( "https%3A%2F%2Fa.b%2FREADME.md", Just "https://a.b/README.md" )
            , ( "https://a.b/README.md", Just "https://a.b/README.md" )
            , ( "http%zz", Just "http%zz" )
            , ( "https://a.b/README.md?id=1&vscodeBrowserReqId=2", Just "https://a.b/README.md" )
            , ( "https://a.b/R.md?vscodeBrowserReqId=2", Just "https://a.b/R.md" )
            , ( "https://a.b/R.md&x=?id=", Just "https://a.b/R.md&x=?id=" )
            , ( "https://a.b/R.md&vscodeBrowserReqId=1&id=", Just "https://a.b/R.md" )
            , ( "https://a.b/R.md?id=&vscodeBrowserReqId=1", Just "https://a.b/R.md" )
            , ( "https://a.b/R.md?id=1", Just "https://a.b/R.md?id=1" )
            , ( "id=1&vscodeBrowserReqId=2", Nothing )
            , ( "vscodeBrowserReqId=2", Nothing )
            , ( "id=1", Just "id=1" )
            , ( "README%20x.md", Just "README%20x.md" )
            , ( "https://a.b/R.md?vscodeBrowserReqId=2&id=1", Just "https://a.b/R.md" )
            , ( "https://a.b/R.md?a=&vscodeBrowserReqId=1", Just "https://a.b/R.md?a" )
            ]
        , examples "formatDate"
            Utils.formatDate
            [ ( 0, "01.01.1970 00:00" )
            , ( 1760000000000, "09.10.2025 08:53" )
            , ( 951782400000, "29.02.2000 00:00" )
            , ( 1700000000000 + 3600000 * 24 * 30, "14.12.2023 22:13" )
            , ( 1717200000000, "01.06.2024 00:00" )
            , ( 1719792000000, "01.07.2024 00:00" )
            , ( 1722470400000, "01.08.2024 00:00" )
            , ( 1725148800000, "01.09.2024 00:00" )
            , ( 1727740800000, "01.10.2024 00:00" )
            , ( 1730419200000, "01.11.2024 00:00" )
            , ( 1706745600000, "01.02.2024 00:00" )
            , ( 1709251200000, "01.03.2024 00:00" )
            , ( 1711929600000, "01.04.2024 00:00" )
            , ( 1714521600000, "01.05.2024 00:00" )
            ]
        , describe "views"
            [ snapshot "btnIcon"
                (Utils.btnIcon { title = "T", tabbable = True, msg = Just "m", icon = "icon-x" } [ Attr.id "b" ])
                "<button class=\"lia-btn\" aria-hidden=\"false\" id=\"b\" tabIndex=\"0\" title=\"T\">\n    <i class=\"icon icon-x lia-btn__icon\" aria-hidden=\"true\">\n    </i>\n</button>"
            , snapshot "btn without msg and title"
                (Utils.btn { title = "", tabbable = False, msg = Nothing } [] [ Html.text "x" ])
                "<button class=\"lia-btn lia-btn--disabled is-disabled \" aria-disabled=\"true\" aria-hidden=\"true\" tabIndex=\"-1\">\n    x\n</button>"
            , snapshot "modal"
                (Utils.modal True "close" (Just [ Html.text "ctrl" ]) [ Html.text "content" ])
                "<lia-modal class=\"lia-modal\" aria-modal=\"true\" role=\"dialog\">\n    <div class=\"lia-modal__inner\">\n        <div class=\"lia-modal__close\">\n            <button class=\"lia-btn lia-btn--transparent\" aria-hidden=\"false\" id=\"lia-modal__close\" tabIndex=\"0\" title=\"close modal\">\n                <i class=\"icon icon-close lia-btn__icon\" aria-hidden=\"true\">\n                </i>\n            </button>\n        </div>\n        <div class=\"lia-modal__content\">\n            content\n        </div>\n        <div class=\"lia-modal__controls\">\n            ctrl\n        </div>\n    </div>\n    <div class=\"lia-modal__outer\">\n    </div>\n</lia-modal>"
            , snapshot "modal without controls"
                (Utils.modal False "close" Nothing [])
                "<lia-modal class=\"lia-modal\" aria-modal=\"true\" role=\"dialog\">\n    <div class=\"lia-modal__inner\">\n        <div class=\"lia-modal__close\">\n            <button class=\"lia-btn lia-btn--transparent\" aria-hidden=\"false\" id=\"lia-modal__close\" tabIndex=\"0\" title=\"close modal\">\n                <i class=\"icon icon-close lia-btn__icon\" aria-hidden=\"true\">\n                </i>\n            </button>\n        </div>\n        <div class=\"lia-modal__content\">\n        </div>\n        \n    </div>\n    <div class=\"lia-modal__outer \">\n    </div>\n</lia-modal>"
            , snapshot "deactivate"
                (Html.div (Utils.deactivate True [ Attr.id "a" ] ++ Utils.deactivate False [ Attr.id "b" ]) [])
                "<div aria-hidden=\"true\" id=\"b\" inert=\"true\">\n</div>"
            , snapshot "noTranslate"
                (Html.div (Utils.noTranslate [ Attr.id "a" ]) [])
                "<div class=\"notranslate\" id=\"a\" translate=\"no\">\n</div>"
            , snapshot "viewIdenticon"
                (Utils.viewIdenticon "peer-1")
                "<span aria-hidden=\"true\">\n    <span style=\"color:rgb(177,65,162);\">\n         ◆\n    </span>\n    🐯\n</span>"
            , test "btn click" <|
                \_ ->
                    Utils.btn { title = "", tabbable = True, msg = Just "m" } [] []
                        |> Query.fromHtml
                        |> HE.simulate HE.click
                        |> HE.expect "m"
            , test "modal closes by the close button, Escape and the outer area if activeBorder" <|
                \_ ->
                    let
                        modal active =
                            Utils.modal active "close" Nothing [] |> Query.fromHtml
                    in
                    Expect.all
                        [ \_ -> modal True |> Query.find [ Selector.tag "button" ] |> HE.simulate HE.click |> HE.expect "close"
                        , \_ -> modal True |> Query.find [ Selector.class "lia-modal__outer" ] |> HE.simulate HE.click |> HE.expect "close"
                        , \_ -> modal False |> Query.find [ Selector.class "lia-modal__outer" ] |> HE.simulate HE.click |> HE.toResult |> Result.toMaybe |> Expect.equal Nothing
                        , \_ -> modal False |> HE.simulate (keydown 27 "Escape") |> HE.expect "close"
                        ]
                        ()
            , test "onEnter fires on keyup Enter only" <|
                \_ ->
                    let
                        input =
                            Html.input [ Utils.onEnter "enter" ] [] |> Query.fromHtml
                    in
                    Expect.all
                        [ \_ -> input |> HE.simulate (keyup 13) |> HE.expect "enter"
                        , \_ -> input |> HE.simulate (keyup 12) |> HE.toResult |> Result.toMaybe |> Expect.equal Nothing
                        , \_ -> input |> HE.simulate (keydown 13 "Enter") |> HE.toResult |> Result.toMaybe |> Expect.equal Nothing
                        ]
                        ()
            , test "onKeyDown passes the key code and stops propagation" <|
                \_ ->
                    Html.input [ Utils.onKeyDown String.fromInt ] []
                        |> Query.fromHtml
                        |> HE.simulate (keydown 37 "ArrowLeft")
                        |> Expect.all [ HE.expect "37", HE.expectStopPropagation ]
            ]
        ]


examples : String -> (a -> b) -> List ( a, b ) -> Test
examples name fn =
    List.indexedMap (\i ( input, output ) -> test (name ++ " " ++ String.fromInt i) <| \_ -> fn input |> Expect.equal output)
        >> describe name


snapshot : String -> Html.Html msg -> String -> Test
snapshot name html expected =
    test name <|
        \_ ->
            HtmlSnapshot.toString html
                |> Expect.equal
                    (if String.isEmpty expected then
                        "RECORD:" ++ name ++ "\n" ++ HtmlSnapshot.toString html

                     else
                        expected
                    )


keydown : Int -> String -> ( String, JE.Value )
keydown code key =
    HE.custom "keydown" (JE.object [ ( "keyCode", JE.int code ), ( "key", JE.string key ), ( "shiftKey", JE.bool False ) ])


keyup : Int -> ( String, JE.Value )
keyup code =
    HE.custom "keyup" (JE.object [ ( "keyCode", JE.int code ) ])
