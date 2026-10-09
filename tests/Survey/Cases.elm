module Survey.Cases exposing (suite)

{-| Cases of `Lia.Markdown.Survey` that are rare or missing in the LiaBooks and
LiaTemplates corpora, which are otherwise used as a golden master.
-}

import Array
import Dict
import Expect
import Json.Encode as JE
import Lia.Markdown.Survey.Json as Json
import Lia.Markdown.Survey.Sync as Sync
import Lia.Markdown.Survey.Types exposing (Element, State(..), Vector, toString)
import Lia.Markdown.Survey.Update as Update exposing (DropMsg(..), Msg(..), SelectMsg(..))
import Lia.Sync.Types as Classroom
import Parser.Block.Fixtures exposing (parseWithState)
import Service.Event as Event
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Survey"
        [ inputs
        , submission
        , scripts
        , summaries
        , json
        ]


inputs : Test
inputs =
    describe "inputs"
        [ test "a dragged option is dropped onto the highlighted target" <|
            \_ ->
                states "[->[ a | b | c ]]\n" [ DropUpdate 0 (Enter True), DropUpdate 0 (Drop 1) ]
                    |> Expect.equal [ DragAndDrop_State True False -1, DragAndDrop_State False False 1 ]
        , test "the option on the target is removed by dragging it out or by a click on the target" <|
            \_ ->
                [ [ DropUpdate 0 (Source 2), DropUpdate 0 (Drop 2) ]
                , [ DropUpdate 0 (Source 2), DropUpdate 0 Target ]
                , [ DropUpdate 0 (Source 2), DropUpdate 0 (Drop 0) ]
                , [ DropUpdate 0 Start, DropUpdate 0 (Enter True), DropUpdate 0 Exit ]
                ]
                    |> List.map (states "[->[ a | b | c ]]\n" >> last)
                    |> Expect.equal
                        [ Just (DragAndDrop_State False False -1)
                        , Just (DragAndDrop_State False False -1)
                        , Just (DragAndDrop_State False False 2)
                        , Just (DragAndDrop_State False False -1)
                        ]
        , test "a dropdown is opened and closed by choosing an option" <|
            \_ ->
                states "[[ a | b | c ]]\n" [ SelectUpdate 0 Choose, SelectUpdate 0 Choose, SelectUpdate 0 Choose, SelectUpdate 0 (Update 2) ]
                    |> Expect.equal [ Select_State True -1, Select_State False -1, Select_State True -1, Select_State False 2 ]
        , test "a radio button deselects all others, checkboxes are toggled" <|
            \_ ->
                [ states "[(a)] A\n[(b)] B\n" [ VectorUpdate 0 "a", VectorUpdate 0 "b", VectorUpdate 0 "b" ]
                , states "[[a]] A\n[[b]] B\n" [ VectorUpdate 0 "a", VectorUpdate 0 "b", VectorUpdate 0 "a" ]
                ]
                    |> List.map (List.map vectorState)
                    |> Expect.equal
                        [ [ [ ( "a", True ), ( "b", False ) ], [ ( "a", False ), ( "b", True ) ], [ ( "a", False ), ( "b", False ) ] ]
                        , [ [ ( "a", True ), ( "b", False ) ], [ ( "a", True ), ( "b", True ) ], [ ( "a", False ), ( "b", True ) ] ]
                        ]
        , test "a matrix row behaves like a vector" <|
            \_ ->
                states "[(a)(b)]\n[ ] one\n[ ] two\n" [ MatrixUpdate 0 1 "a", MatrixUpdate 0 1 "b" ]
                    |> last
                    |> Maybe.map toString
                    |> Expect.equal (Just "[{\"a\": 0, \"b\": 0},\n{\"a\": 0, \"b\": 1}]")
        , test "a submitted survey ignores inputs until it is reactivated" <|
            \_ ->
                run "[[___]]\n" [ TextUpdate 0 "x", Submit 0, TextUpdate 0 "y", Reactivate 0, TextUpdate 0 "z" ]
                    |> List.map (\e -> ( e.submitted, e.state ))
                    |> Expect.equal
                        [ ( False, Text_State "x" )
                        , ( True, Text_State "x" )
                        , ( True, Text_State "x" )
                        , ( False, Text_State "x" )
                        , ( False, Text_State "z" )
                        ]
        ]


submission : Test
submission =
    describe "submission"
        [ test "an incomplete matrix shows the default error" <|
            \_ ->
                run "[(a)(b)]\n[ ] one\n[ ] two\n" [ MatrixUpdate 0 0 "a", Submit 0, MatrixUpdate 0 1 "b", Submit 0 ]
                    |> List.map (\e -> ( e.submitted, e.errorMsg ))
                    |> Expect.equal [ ( False, Nothing ), ( False, Just "" ), ( False, Just "" ), ( True, Nothing ) ]
        , test "data-incomplete allows to submit an empty answer" <|
            \_ ->
                run "<!-- data-incomplete -->\n[[ a | b ]]\n" [ Submit 0 ]
                    |> List.map .submitted
                    |> Expect.equal [ True ]
        , test "submitting a section stores and reveals, sharing requires a classroom" <|
            \_ ->
                [ Classroom.disconnected, { state = Classroom.Connected "me", data = Classroom.disconnected.data } ]
                    |> List.map
                        (\classroom ->
                            Update.update classroom (Just 3) Array.empty (Submit 0) (vector "[[___]]\n" [ TextUpdate 0 "x" ])
                                |> .events
                                |> List.map (\e -> ( e.service, e.message.cmd ))
                        )
                    |> Expect.equal
                        [ [ ( "db", "store" ), ( "slide", "scroll_into_view" ), ( "slide", "scroll_into_view" ) ]
                        , [ ( "db", "store" ), ( "sync", "survey" ), ( "slide", "scroll_into_view" ), ( "slide", "scroll_into_view" ) ]
                        ]
        ]


scripts : Test
scripts =
    describe "scripts"
        [ test "an error of the script is shown, until the survey is submitted again" <|
            \_ ->
                run "[[___]]\n<script>@input</script>\n"
                    [ TextUpdate 0 "x"
                    , Handle (eval 0 False "wrong")
                    , Submit 0
                    , Handle (eval 0 True "maybe")
                    , Handle (eval 0 True "true")
                    ]
                    |> List.map (\e -> ( e.submitted, e.errorMsg ))
                    |> Expect.equal
                        [ ( False, Nothing )
                        , ( False, Just "wrong" )
                        , ( False, Nothing )
                        , ( False, Nothing )
                        , ( True, Nothing )
                        ]
        , test "the script is not evaluated for a missing script" <|
            \_ ->
                Update.update Classroom.disconnected Nothing Array.empty (Submit 0) (vector "[[___]]\n<script>@input</script>\n" [])
                    |> .events
                    |> Expect.equal []
        ]


summaries : Test
summaries =
    describe "summaries of the classroom"
        [ test "words are counted case-insensitive and comma-separated" <|
            \_ ->
                [ Text_State "Hello, world", Text_State " hello ,x" ]
                    |> answers
                    |> Sync.wordCount
                    |> Maybe.map (List.map (\d -> ( d.value, d.absolute, d.relative )))
                    |> Expect.equal (Just [ ( "HELLO", 2, 50 ), ( "WORLD", 1, 25 ), ( "X", 1, 25 ) ])
        , test "vectors are counted in the order of the options, unknown ids are ignored" <|
            \_ ->
                [ Vector_State True (Dict.fromList [ ( "a", True ), ( "b", True ) ])
                , Vector_State True (Dict.fromList [ ( "a", True ), ( "z", True ) ])
                , Text_State "x"
                ]
                    |> answers
                    |> Sync.vector [ "b", "a", "c" ]
                    |> Maybe.map (List.map (\d -> ( d.value, d.absolute, d.relative )))
                    |> Expect.equal (Just [ ( "b", 1, 50 ), ( "a", 2, 100 ), ( "c", 0, 0 ) ])
        , test "selections are counted from 1" <|
            \_ ->
                [ Select_State False 0, DragAndDrop_State False False 2, Select_State False 0, Select_State False 7 ]
                    |> answers
                    |> Sync.select 3
                    |> Maybe.map (List.map (\d -> ( d.value, d.absolute )))
                    |> Expect.equal (Just [ ( "1", 2 ), ( "2", 0 ), ( "3", 1 ) ])
        , test "a matrix is counted per option and row, only common rows count" <|
            \_ ->
                [ Matrix_State False (Array.fromList [ Dict.fromList [ ( "a", True ) ], Dict.fromList [ ( "b", True ) ] ])
                , Matrix_State False (Array.fromList [ Dict.fromList [ ( "b", True ) ] ])
                ]
                    |> answers
                    |> Sync.matrix [ "a", "b" ]
                    |> Maybe.map (List.map (List.map .absolute))
                    |> Expect.equal (Just [ [ 1 ], [ 1 ] ])
        , test "the cells of the details table" <|
            \_ ->
                [ Vector_State False (Dict.fromList [ ( "a", True ), ( "b", False ) ])
                , Vector_State True (Dict.fromList [ ( "a", True ), ( "b", False ) ])
                , Matrix_State True (Array.fromList [ Dict.fromList [ ( "a", False ) ] ])
                , Select_State False 1
                , Text_State "x"
                ]
                    |> answers
                    |> List.map (Sync.toString [ "a", "b" ])
                    |> Expect.equal [ [ "🗹", "" ], [ "🗹", "☐" ], [ "☐", "" ], [ "2" ], [ "x" ] ]
        , test "no answers, no summary" <|
            \_ ->
                [ Sync.wordCount [], Sync.vector [ "a" ] [], Sync.select 2 [] ]
                    |> Expect.equal [ Nothing, Nothing, Nothing ]
        ]


json : Test
json =
    describe "json"
        [ test "stored states keep the input and the error, not the dropdown or drag state" <|
            \_ ->
                vector "[[ a | b ]]\n[->[ a | b ]]\n[[a]] A\n[(b)] B\n[[___]]\n" [ SelectUpdate 0 Choose, DropUpdate 1 (Source 1), DropUpdate 1 (Enter True), VectorUpdate 2 "a", VectorUpdate 3 "b", Submit 4 ]
                    |> Json.fromVector
                    |> JE.encode 0
                    |> Expect.equal
                        ("[{\"submitted\":false,\"state\":{\"Select\":-1}}"
                            ++ ",{\"submitted\":false,\"state\":{\"Drop\":1}}"
                            ++ ",{\"submitted\":false,\"state\":{\"SingleChoice\":{\"a\":true}}}"
                            ++ ",{\"submitted\":false,\"state\":{\"MultipleChoice\":{\"b\":true}}}"
                            ++ ",{\"errorMessage\":\"\",\"submitted\":false,\"state\":{\"Text\":\"\"}}]"
                        )
        ]



-- HELPERS


{-| The surveys of a course after applying `msgs` (without a classroom).
-}
vector : String -> List (Msg sub) -> Vector
vector code =
    List.foldl
        (\msg -> Update.update Classroom.disconnected (Just 0) Array.empty msg >> .value)
        (parseWithState code |> Tuple.second |> .survey_vector)


{-| The first survey after every message.
-}
run : String -> List (Msg sub) -> List Element
run code msgs =
    List.range 1 (List.length msgs)
        |> List.filterMap (\n -> vector code (List.take n msgs) |> Array.get 0)


states : String -> List (Msg sub) -> List State
states code =
    run code >> List.map .state


vectorState : State -> List ( String, Bool )
vectorState state =
    case state of
        Vector_State _ dict ->
            Dict.toList dict

        _ ->
            []


last : List a -> Maybe a
last =
    List.reverse >> List.head


{-| The submitted answers of peers.
-}
answers : List State -> List Sync.Sync
answers =
    List.filterMap
        (\state ->
            Sync.sync
                { submitted = True
                , state = state
                , errorMsg = Nothing
                , scriptID = Nothing
                , opt = { randomize = Nothing, score = Nothing, updates_allowed = False, incompleteness_allowed = False }
                }
        )


eval : Int -> Bool -> String -> Event.Event
eval id ok result =
    Event.init "script"
        { cmd = "eval"
        , param = JE.object [ ( "ok", JE.bool ok ), ( "result", JE.string result ), ( "details", JE.list identity [] ) ]
        }
        |> Event.pushWithId "eval" id
