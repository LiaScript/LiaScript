module Code.Cases exposing (suite)

{-| Cases of `Lia.Markdown.Code` beyond parsing (see `Parser.Block.Code`):
versions, logs, the terminal, classroom mode and storage. The LiaBooks and
LiaTemplates corpora are otherwise used as a golden master.
-}

import Accessibility.Key as Key
import Array
import Combine
import Expect
import Html.Attributes as Attr
import I18n.Translations as Translations exposing (Lang(..))
import Json.Encode as JE
import Lia.Definition.Types as Definition
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types as Types exposing (Code(..), Model, Project)
import Lia.Markdown.Code.Update as Update exposing (Msg(..))
import Lia.Markdown.Code.View as View
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Macro.Parser as Macro
import Lia.Markdown.Parser as Parser
import Lia.Parser.Context as Context
import Parser.Block.Fixtures exposing (parseWithState)
import Return exposing (Return)
import Service.Event as Event
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Code"
        [ parsing
        , versions
        , logs
        , terminal
        , classroom
        , storage
        , view
        ]


view : Test
view =
    describe "view"
        [ test "a file in fullscreen offers to minimize" <|
            \_ ->
                render named Array.empty [ FlipFullscreen (Evaluate 0) 0 ]
                    |> Query.has [ Selector.class "icon-chevron-up" ]
        , test "data-rtltext alone only detects the direction of the text" <|
            \_ ->
                parseWithState "<!-- data-rtltext -->\n```js\na\n```\n"
                    |> Tuple.second
                    |> .code_model
                    |> (\m -> View.view { lang = En, theme = "", model = m, code = Highlight 0, sync = Array.empty, cursors = [] })
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "lia-editor" ]
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Editor.rtlText True) ]
                        , Query.has [ Selector.attribute (Editor.rtl False) ]
                        ]
        , test "the terminal keeps the height set by the user" <|
            \_ ->
                render course Array.empty [ result True "x", Resize (Evaluate 0) "99px" ]
                    |> Query.find [ Selector.tag "lia-terminal" ]
                    |> Query.has [ Selector.attribute (Attr.property "height" (JE.string "99px")) ]
        , test "in a classroom the local editor offers to switch to the collaborative one" <|
            \_ ->
                render course shared []
                    |> Query.has [ Selector.attribute (Attr.title "switch to collaborative editor") ]
        , test "the collaborative editor has no versions to switch between" <|
            \_ ->
                render course shared [ Update 0 0 "b", Eval 0, result True "x", First 0, ToggleSync 0 ]
                    |> Query.findAll [ Selector.class "lia-code-control__version", Selector.tag "div" ]
                    |> Query.first
                    |> Expect.all
                        [ Query.findAll [ Selector.tag "button", Selector.attribute (Attr.disabled True) ] >> Query.count (Expect.equal 4)
                        , Query.findAll [ Selector.tag "button", Selector.attribute (Key.tabbable False) ] >> Query.count (Expect.equal 4)
                        ]
        , test "the version controls are disabled while running" <|
            \_ ->
                render course Array.empty [ Update 0 0 "b", Eval 0, result True "x", First 0, Eval 0 ]
                    |> Query.find [ Selector.attribute (Attr.title (Translations.codeNext En)) ]
                    |> Query.has [ Selector.attribute (Attr.disabled True) ]
        , test "the collaborative editor sends its changes to the classroom" <|
            \_ ->
                render course shared [ ToggleSync 0 ]
                    |> Query.find [ Selector.tag "lia-editor" ]
                    |> Event.simulate (Event.custom "editorUpdateEvent" (JE.object [ ( "detail", JE.string "delta" ) ]))
                    |> Event.expect (Synchronize 0 0 (JE.string "delta"))
        , test "without a classroom the local editor is shown, even in sync mode" <|
            \_ ->
                View.view { lang = En, theme = "", model = run [ ToggleSync 0 ], code = Evaluate 0, sync = Array.empty, cursors = [] }
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "lia-editor" ]
                    |> Event.simulate (Event.custom "editorUpdate" (JE.object [ ( "detail", JE.string "x" ) ]))
                    |> Event.expect (Update 0 0 "x")
        , test "the output of a highlighted block keeps the height set by the user" <|
            \_ ->
                parseWithState "```js\na\n```\n```  @output\nout\n```\n"
                    |> Tuple.second
                    |> .code_model
                    |> Update.update Array.empty (Just 0) Array.empty (Resize (Highlight 0) "99px")
                    |> .value
                    |> (\m -> View.view { lang = En, theme = "", model = m, code = Highlight 0, sync = Array.empty, cursors = [] })
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "lia-terminal" ]
                    |> Query.has [ Selector.attribute (Attr.property "height" (JE.string "99px")) ]
        , test "the terminal grows with its input" <|
            \_ ->
                Terminal.init "sh"
                    |> Terminal.update (Terminal.Input "a\nb")
                    |> Tuple.first
                    |> Terminal.view
                    |> Query.fromHtml
                    |> Query.find [ Selector.tag "lia-editor" ]
                    |> Query.has [ Selector.style "min-height" "calc( 2 * var(--global-font-size, 1.5rem) * var(--font-size-multiplier) * 1.3333 + 1.47rem)" ]
        , test "an older version can be left forward" <|
            \_ ->
                render course Array.empty [ Update 0 0 "b", Eval 0, result True "x", First 0 ]
                    |> Expect.all
                        [ Query.find [ Selector.attribute (Attr.title (Translations.codeNext En)) ] >> Event.simulate Event.click >> Event.expect (Load 0 1)
                        , Query.find [ Selector.attribute (Attr.title (Translations.codeLast En)) ] >> Event.simulate Event.click >> Event.expect (Last 0)
                        ]
        ]


parsing : Test
parsing =
    describe "parsing"
        [ test "the closing fence may be indented by tabs" <|
            \_ ->
                parse [] "```js\na\n\t```\n"
                    |> .highlight
                    |> Array.toList
                    |> List.concatMap code
                    |> Expect.equal [ "a" ]
        , test "a macro listing may follow the annotations" <|
            \_ ->
                parse [ ( "wrap", "```py\n@0\n```" ) ] "<!-- data-x=\"1\" -->\n```js @wrap\ncode\n```\n"
                    |> .highlight
                    |> Array.toList
                    |> List.concatMap (\p -> Array.toList p.file |> List.map .lang)
                    |> Expect.equal [ "py" ]
        ]


versions : Test
versions =
    describe "versions"
        [ test "running changed code appends and activates a new version" <|
            \_ ->
                run [ Update 0 0 "b", Eval 0 ]
                    |> project
                    |> Maybe.map (\p -> ( Array.length p.version, p.version_active, p.running ))
                    |> Expect.equal (Just ( 2, 1, True ))
        , test "the results of subscribed scripts are passed to the evaluation" <|
            \_ ->
                parseWithState "```js\na\n```\n<script>@input(`x`)</script>\n"
                    |> Tuple.second
                    |> .code_model
                    |> Update.update Array.empty
                        (Just 0)
                        (Script.push "" 0 [ ( "output", "x" ) ] "" Array.empty
                            |> Array.map (\js -> { js | result = Just (Script.Text "42") })
                        )
                        (Eval 0)
                    |> .events
                    |> List.map (Event.encode >> JE.encode 0)
                    |> List.any (String.contains "\"param\":\"42\"")
                    |> Expect.equal True
        , test "within subsections versions are created without storing them" <|
            \_ ->
                run [ Update 0 0 "b" ]
                    |> Update.update Array.empty Nothing Array.empty (Eval 0)
                    |> (\r -> ( Maybe.map (.version >> Array.length) (project r.value), List.length r.events ))
                    |> Expect.equal ( Just 2, 1 )
        , test "running unchanged code keeps the version" <|
            \_ ->
                run [ Eval 0, result True "ok", Eval 0 ]
                    |> project
                    |> Maybe.map (.version >> Array.length)
                    |> Expect.equal (Just 1)
        , test "a new version is stored with its new code only" <|
            \_ ->
                update [ Update 0 0 "b" ] (Eval 0)
                    |> .events
                    |> List.map (Event.encode >> JE.encode 0)
                    |> List.filter (String.contains "\"append\"")
                    |> List.map (String.contains "\"92eb5ffee6ae2fec3ad71c777531578f\":\"b\"")
                    |> Expect.equal [ True ]
        , test "loading the first version restores its code and log" <|
            \_ ->
                run [ result True "first", Update 0 0 "b", Eval 0, result True "second", First 0 ]
                    |> project
                    |> Maybe.map (\p -> ( code p, messages p.log ))
                    |> Expect.equal (Just ( [ "a" ], [ "first" ] ))
        , test "Last loads the latest version" <|
            \_ ->
                run [ Update 0 0 "b", Eval 0, First 0, Last 0 ]
                    |> project
                    |> Maybe.map (\p -> ( code p, p.version_active ))
                    |> Expect.equal (Just ( [ "b" ], 1 ))
        ]


logs : Test
logs =
    describe "logs"
        [ test "stream messages are concatenated" <|
            \_ ->
                run [ Eval 0, log "stream" "a", log "stream" "b", log "info" "c", log "stream" "d" ]
                    |> project
                    |> Maybe.map (.log >> messages)
                    |> Expect.equal (Just [ "ab", "c", "d" ])
        , test "unknown levels are ignored" <|
            \_ ->
                run [ Eval 0, log "bogus" "a" ]
                    |> project
                    |> Maybe.map (.log >> messages)
                    |> Expect.equal (Just [])
        , test "only the last 249 messages are kept" <|
            \_ ->
                List.foldl (\i -> Log.add Log.Info (String.fromInt i)) Log.empty (List.range 1 300)
                    |> messages
                    |> (\list -> ( List.length list, List.head list ))
                    |> Expect.equal ( 249, Just "52" )
        , test "LIA: clear empties the log of the active version too" <|
            \_ ->
                run [ result True "x", result True "LIA: clear" ]
                    |> project
                    |> Maybe.map (\p -> ( messages p.log, Array.toList p.version |> List.map (Tuple.second >> messages) ))
                    |> Expect.equal (Just ( [], [ [] ] ))
        , test "a result stops the program and is stored with the version" <|
            \_ ->
                run [ Eval 0, result False "boom" ]
                    |> project
                    |> Maybe.map (\p -> ( p.running, messages p.log, p.log.ok ))
                    |> Expect.equal (Just ( False, [ "boom" ], False ))
        ]


terminal : Test
terminal =
    describe "terminal"
        [ test "LIA: terminal opens a terminal in the language of the first file" <|
            \_ ->
                run [ Eval 0, result True "LIA: terminal" ]
                    |> project
                    |> Maybe.andThen .terminal
                    |> Maybe.map .mode
                    |> Expect.equal (Just "js")
        , test "a terminal without files is a shell" <|
            \_ ->
                parseWithState "``` @output\nx\n```\n<script>@input</script>\n"
                    |> Tuple.second
                    |> .code_model
                    |> Update.update Array.empty (Just 0) Array.empty (result True "LIA: terminal")
                    |> .value
                    |> project
                    |> Maybe.andThen .terminal
                    |> Maybe.map .mode
                    |> Expect.equal (Just "sh")
        , test "Enter sends the input and logs it" <|
            \_ ->
                update [ Eval 0, result True "LIA: terminal", UpdateTerminal 0 (Terminal.Input "ls") ] (UpdateTerminal 0 Terminal.Enter)
                    |> (\r -> ( Maybe.map (.log >> messages) (Array.get 0 r.value.evaluate), List.length r.events ))
                    |> Expect.equal ( Just [ "ls\n" ], 1 )
        , test "down only browses the history from the last line of the input" <|
            \_ ->
                history [ Terminal.Input "a", Terminal.Enter, Terminal.Input "", Terminal.Input "b\nc", Terminal.History False ]
                    |> List.reverse
                    |> List.head
                    |> Expect.equal (Just "b\nc")
        , test "the input event the editor sends right after Enter is ignored" <|
            \_ ->
                history [ Terminal.Input "a", Terminal.Enter, Terminal.Input "a\n" ]
                    |> Expect.equal [ "a", "", "" ]
        , test "the history is browsed with up and down" <|
            \_ ->
                history [ Terminal.Input "a", Terminal.Enter, Terminal.Input "", Terminal.Input "b", Terminal.Enter, Terminal.Input "", Terminal.Input "c", Terminal.History True, Terminal.History True, Terminal.History False, Terminal.History False ]
                    |> List.drop 7
                    |> Expect.equal [ "b", "a", "b", "c" ]
        ]


classroom : Test
classroom =
    describe "classroom"
        [ test "in sync mode the local code cannot be changed" <|
            \_ ->
                run [ ToggleSync 0 ]
                    |> Update.update shared (Just 0) Array.empty (Update 0 0 "b")
                    |> .value
                    |> project
                    |> Maybe.map code
                    |> Expect.equal (Just [ "a" ])
        , test "in sync mode local changes do not become a version" <|
            \_ ->
                Update.update shared (Just 0) Array.empty (Eval 0) (run [ Update 0 0 "b", ToggleSync 0 ])
                    |> .value
                    |> project
                    |> Maybe.map (.version >> Array.length)
                    |> Expect.equal (Just 1)
        , test "in sync mode the shared code runs and the output goes to the sync log" <|
            \_ ->
                Update.update shared (Just 0) Array.empty (Eval 0) (run [ ToggleSync 0 ])
                    |> (\r ->
                            ( r.events |> List.map (Event.encode >> JE.encode 0) |> List.any (String.contains "shared")
                            , r.value |> Update.update shared (Just 0) Array.empty (result True "x") |> .value |> project |> Maybe.map (\p -> ( messages p.log, messages p.syncLog ))
                            )
                       )
                    |> Expect.equal ( True, Just ( [], [ "x" ] ) )
        ]


storage : Test
storage =
    describe "storage"
        [ test "a restored project keeps the evaluation script of the course" <|
            \_ ->
                let
                    stored =
                        run [ Update 0 0 "b", Eval 0 ]
                            |> .evaluate
                            |> Array.map (\p -> { p | evaluation = "old" })
                            |> Json.fromVector
                in
                update [] (Update.handle (Event.init "x" { cmd = "load", param = stored }))
                    |> .value
                    |> project
                    |> Maybe.map (\p -> ( p.evaluation, code p, Array.length p.version ))
                    |> Expect.equal (Just ( "@input", [ "b" ], 2 ))
        , test "without stored data the course's projects get stored" <|
            \_ ->
                update [] (Update.handle (Event.init "x" { cmd = "load", param = JE.null }))
                    |> .events
                    |> List.map (Event.encode >> JE.encode 0)
                    |> List.filter (String.contains "\"store\"")
                    |> List.length
                    |> Expect.equal 1
        ]



-- HELPERS


{-| The terminal input after every message.
-}
history : List Terminal.Msg -> List String
history =
    List.foldl (\msg ( t, inputs ) -> Terminal.update msg t |> Tuple.first |> (\t2 -> ( t2, inputs ++ [ t2.input ] ))) ( Terminal.init "sh", [] )
        >> Tuple.second


parse : List ( String, String ) -> String -> Model
parse macros code_ =
    List.foldl Macro.add (Definition.default "" "") macros
        |> Context.init Nothing Nothing
        |> (\state -> Combine.runParser Parser.run state code_)
        |> Result.map (\( state, _, _ ) -> state.code_model)
        |> Result.withDefault Types.init


{-| The executable project after `msgs`, rendered.
-}
render : Model -> Array.Array (Array.Array String) -> List Msg -> Query.Single Msg
render model sync msgs =
    View.view
        { lang = En
        , theme = ""
        , model = List.foldl (\msg -> Update.update sync (Just 0) Array.empty msg >> .value) model msgs
        , code = Evaluate 0
        , sync = sync
        , cursors = []
        }
        |> Query.fromHtml


named : Model
named =
    parseWithState "```js +main.js\na\n```\n<script>@input</script>\n"
        |> Tuple.second
        |> .code_model


course : Model
course =
    parseWithState "```js\na\n```\n<script>@input</script>\n"
        |> Tuple.second
        |> .code_model


{-| The classroom's version of the code.
-}
shared : Array.Array (Array.Array String)
shared =
    Array.fromList [ Array.fromList [ "shared" ] ]


update : List Msg -> Msg -> Return Model msg sub
update msgs msg =
    Update.update Array.empty (Just 0) Array.empty msg (run msgs)


run : List Msg -> Model
run =
    List.foldl (\msg -> Update.update Array.empty (Just 0) Array.empty msg >> .value) course


project : Model -> Maybe Project
project =
    .evaluate >> Array.get 0


code : Project -> List String
code =
    .file >> Array.toList >> List.map .code


messages : Log.Log -> List String
messages =
    .messages >> Array.toList >> List.map .text


result : Bool -> String -> Msg
result ok text =
    Event.init "script"
        { cmd = "eval"
        , param = JE.object [ ( "ok", JE.bool ok ), ( "result", JE.string text ), ( "details", JE.list identity [] ) ]
        }
        |> Event.pushWithId "project" 0
        |> Update.handle


log : String -> String -> Msg
log level text =
    Event.init "x" { cmd = "log", param = JE.list JE.string [ level, text ] }
        |> Event.pushWithId "project" 0
        |> Update.handle
