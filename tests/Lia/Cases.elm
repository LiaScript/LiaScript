module Lia.Cases exposing (suite)

{-| Cases of the Lia root (Script, Model, Section, Json, View) that neither the
corpus golden master nor the differential fuzzer reach. `Lia.Update.update`
needs a `Session` with a `Navigation.Key`, which cannot be created in tests,
everything here works without it.
-}

import Array
import Expect
import Dict
import Html
import Html.Attributes
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types as Definition
import Lia.Json.Decode
import Lia.Json.Encode
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Model
import Lia.Parser.Parser as Parser
import Lia.Script
import Lia.Section as Section
import Lia.Settings.Types exposing (Mode(..), Settings)
import Lia.Sync.Types as Sync
import Lia.Sync.Update as SyncUpdate
import Lia.Sync.Via as Via
import Lia.Update exposing (Msg(..))
import Service.Event as Event exposing (Event)
import Service.Resource
import Test exposing (Test, describe, test)
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Lia root"
        [ describe "Script and Model"
            [ test "add_todos appends the resource events in reverse order" <|
                \_ ->
                    let
                        model =
                            course "# A\n"

                        definition =
                            Definition.default "" ""
                    in
                    { model | to_do = [ Service.Resource.style "x" ] }
                        |> Lia.Script.add_todos { definition | resources = [ Definition.Script "a.js", Definition.Link "b.css" ] }
                        |> .to_do
                        |> events
                        |> Expect.equal
                            (events
                                [ Service.Resource.style "x"
                                , Service.Resource.link "b.css"
                                , Service.Resource.script "a.js"
                                ]
                            )
            , test "loadResource loads JavaScript modules as modules" <|
                \_ ->
                    Lia.Model.loadResource [ Definition.Link "b.css" ] [ Definition.Link "b.css", Definition.Module "m.js" ]
                        |> Tuple.mapSecond events
                        |> Expect.equal ( [ Definition.Link "b.css", Definition.Module "m.js" ], events [ Service.Resource.script_module "m.js" ] )
            , test "loadResource loads a resource listed twice only once" <|
                \_ ->
                    Lia.Model.loadResource [] [ Definition.Script "a.js", Definition.Script "a.js", Definition.Link "b.css" ]
                        |> Tuple.mapSecond events
                        |> Expect.equal ( [ Definition.Script "a.js", Definition.Link "b.css" ], events [ Service.Resource.script "a.js", Service.Resource.link "b.css" ] )
            , test "add_macros merges a definition with itself without duplicates" <|
                \_ ->
                    let
                        def =
                            Definition.default "" ""
                                |> (\d -> { d | resources = [ Definition.Script "a.js" ], attributes = [ [] ] })
                    in
                    Definition.add_macros def def
                        |> (\d -> ( d.resources, d.attributes ))
                        |> Expect.equal ( def.resources, def.attributes )
            , test "Section.sync shares submitted surveys with the own peer id" <|
                \_ ->
                    case parse "[(1)] eins\n[(2)] zwei\n" of
                        Ok sec ->
                            { sec | survey_vector = Array.map (\s -> { s | submitted = True }) sec.survey_vector }
                                |> Section.sync "me"
                                |> JE.encode 0
                                |> String.contains "\"me\""
                                |> Expect.equal True

                        Err e ->
                            Expect.fail e
            ]
        , describe "Json"
            [ test "the repository URL is derived from the readme" <|
                \_ ->
                    decoded "https://raw.githubusercontent.com/user/repo/main/README.md"
                        |> Result.map .repositoryUrl
                        |> Expect.equal (Ok (Just "https://github.com/user/repo/tree/main"))
            , test "the query of the readme is the appendix of the definition" <|
                \_ ->
                    decoded "https://example.com/README.md?a=1"
                        |> Result.map (.definition >> .appendix)
                        |> Expect.equal (Ok "?a=1")
            ]
        , describe "View"
            [ test "link previews in the notes only from the tooltip breakpoint on" <|
                \_ ->
                    let
                        model =
                            course "# A\n\n    --{{0}}--\nSee [x](https://a.example/).\n"
                                |> settings (\s -> { s | mode = Slides, tooltips = True })

                        previews width n =
                            view width model
                                |> Query.find [ Selector.class "lia-notes" ]
                                |> Query.findAll [ Selector.tag "preview-link" ]
                                |> Query.count (Expect.equal n)
                    in
                    Expect.all
                        [ \_ -> previews 1200 1
                        , \_ -> previews 500 0
                        ]
                        ()
            , test "the narrator avatar is shown, but not in Textbook mode" <|
                \_ ->
                    let
                        visible mode n =
                            course "# A\n\n    --{{0}}--\nHello.\n"
                                |> settings
                                    (\s ->
                                        let
                                            tts =
                                                s.tts
                                        in
                                        { s | mode = mode, sound = True, tts = { tts | avatar = Just "lia-avatar" } }
                                    )
                                |> view 1200
                                |> Query.findAll [ Selector.class "fade-in" ]
                                |> Query.count (Expect.equal n)
                    in
                    Expect.all
                        [ \_ -> visible Presentation 1
                        , \_ -> visible Textbook 0
                        ]
                        ()
            , test "video recordings take precedence over the avatar" <|
                \_ ->
                    course "# A\n\n    --{{0}}--\n!?[v](https://v.example/v.mp4) Hello.\n"
                        |> settings
                            (\s ->
                                let
                                    tts =
                                        s.tts
                                in
                                { s | mode = Presentation, sound = True, tts = { tts | avatar = Just "lia-avatar" } }
                            )
                        |> view 1200
                        |> Expect.all
                            [ Query.has [ Selector.id "lia-tts-videos" ]
                            , Query.hasNot [ Selector.id "lia-tts-avatar" ]
                            ]
            , test "the play button starts the narration" <|
                \_ ->
                    course "# A\n\n    --{{0}}--\nHello.\n"
                        |> settings (\s -> { s | mode = Presentation, sound = True })
                        |> view 1200
                        |> Query.find [ Selector.class "lia-responsive-voice__play" ]
                        |> HE.simulate HE.click
                        |> HE.expect (TTSReplay True)
            , test "the progress slider of recordings is hidden without sound" <|
                \_ ->
                    course "# A\n\n    --{{0}}--\n?[a](https://a.example/a.mp3) Hello.\n"
                        |> settings (\s -> { s | mode = Presentation, sound = False })
                        |> view 1200
                        |> Query.find [ Selector.class "lia-tts-progress" ]
                        |> Query.has [ Selector.style "display" "none" ]
            , test "ResponsiveVoice is used, if the browser voice is not preferred" <|
                \_ ->
                    course "# A\n\n    --{{0}}--\nHello.\n"
                        |> settings
                            (\s ->
                                let
                                    tts =
                                        s.tts
                                in
                                { s
                                    | mode = Presentation
                                    , sound = True
                                    , tts = { tts | isBrowserSupported = True, isResponsiveVoiceSupported = True, preferBrowser = False }
                                }
                            )
                        |> view 1200
                        |> Query.has [ Selector.text "ResponsiveVoice-NonCommercial" ]
            , test "the information menu links the repository" <|
                \_ ->
                    let
                        model =
                            course "# A\n"
                    in
                    { model | repositoryUrl = Just "https://github.com/user/repo" }
                        |> view 1200
                        |> Query.has [ Selector.attribute (Html.Attributes.href "https://github.com/user/repo") ]
            , test "hidden sections with an error are rendered" <|
                \_ ->
                    let
                        model =
                            course "# A\n\n# B\n"
                    in
                    { model | sections = Array.indexedMap (\i s -> if i == 1 then { s | error = Just "boom-error" } else s) model.sections }
                        |> view 1200
                        |> Query.has [ Selector.text "boom-error" ]
            , test "closing the classroom dialog on the backend page goes back to the overview" <|
                \_ ->
                    let
                        model =
                            course "# A\n"
                                |> settings (\s -> { s | sync = Just True })

                        sync =
                            model.sync

                        inner =
                            sync.sync
                    in
                    { model | sync = { sync | sync = { inner | select = Just ( True, Via.Edrys ) } } }
                        |> view 1200
                        |> Query.find [ Selector.class "lia-modal__close" ]
                        |> Query.find [ Selector.tag "button" ]
                        |> HE.simulate HE.click
                        |> HE.expect (UpdateSync (SyncUpdate.Backend (SyncUpdate.Select Nothing)))
            , test "the owner sees the names of all peers ever seen in the chat" <|
                \_ ->
                    let
                        model =
                            course "# A\n"
                                |> settings
                                    (\s ->
                                        let
                                            chat =
                                                s.chat
                                        in
                                        { s | chat = { chat | show = True } }
                                    )

                        sync =
                            model.sync

                        names owner =
                            case parse "hello" of
                                Ok sec ->
                                    { model
                                        | sync =
                                            { sync
                                                | state = Sync.Connected "me"
                                                , owner = owner
                                                , mode = Sync.Details
                                                , peers = Dict.fromList [ ( "a", "Now" ) ]
                                                , peersHistory = Dict.fromList [ ( "a", "Ever" ) ]
                                            }
                                        , chat = { input = "", messages = Dict.fromList [ ( "0", { section = sec, peer = "a", verified = True } ) ] }
                                    }
                                        |> view 1200
                                        |> Query.find [ Selector.id "lia-chat-messages" ]

                                Err e ->
                                    Query.fromHtml (Html.text e)
                    in
                    Expect.all
                        [ \_ -> names True |> Query.has [ Selector.text "Ever" ]
                        , \_ -> names False |> Query.has [ Selector.text "Now" ]
                        ]
                        ()
            , test "scripts in the notes are tracked with the active section" <|
                \_ ->
                    let
                        model =
                            course "# A\n\n# B\n\n    --{{0}}--\nRun <script>42</script>.\n"

                        loaded =
                            Lia.Update.generate { model | section_active = 1 }

                        -- a script result can be edited by a double click
                        withResult sec =
                            let
                                effect =
                                    sec.effect_model
                            in
                            { sec | effect_model = { effect | javascript = Array.map (\js -> { js | result = Just (Script.Text "42") }) effect.javascript } }
                    in
                    { loaded | sections = Array.indexedMap (\i sec -> if i == 1 then withResult sec else sec) loaded.sections }
                        |> settings (\s -> { s | mode = Slides })
                        |> view 1200
                        |> Query.find [ Selector.class "lia-notes" ]
                        |> Query.find [ Selector.tag "output" ]
                        |> HE.simulate HE.doubleClick
                        |> HE.toResult
                        |> Result.map
                            (\msg ->
                                case msg of
                                    Lia.Update.Script ( 1, _ ) ->
                                        True

                                    _ ->
                                        False
                            )
                        |> Expect.equal (Ok True)
            ]
        ]


course : String -> Lia.Script.Model
course code =
    let
        r =
            Lia.Script.init
                { seed = 7
                , hasShareApi = Nothing
                , openTOC = False
                , isFullscreen = False
                , settings = JE.null
                , backends = { support = [], enabled = False }
                , url = "https://lia.example/?https://example.com/README.md"
                , readme = "https://example.com/README.md"
                , origin = "https://example.com/"
                , anchor = Nothing
                }
                |> (\m -> Lia.Script.init_script m code)

        loop model rest =
            case Lia.Script.parse_section model rest of
                ( m, Just more ) ->
                    loop m more

                ( m, Nothing ) ->
                    m
    in
    loop r.model (Maybe.withDefault "" r.code)
        |> Lia.Update.generate


settings : (Settings -> Settings) -> Lia.Script.Model -> Lia.Script.Model
settings fn model =
    { model | settings = fn model.settings }


view : Int -> Lia.Script.Model -> Query.Single Msg
view width =
    Lia.Script.view { width = width, height = 800 } True >> Query.fromHtml


parse : String -> Result String Section.Section
parse code =
    Section.init 99 0 { indentation = 1, title = [], code = code }
        |> Parser.parse_section identity (Definition.default "" "")


decoded : String -> Result JD.Error Lia.Script.Model
decoded readme =
    let
        model =
            course "# A\n"
    in
    { model | readme = readme }
        |> Lia.Json.Encode.encode
        |> Lia.Json.Decode.decode 1 model.pane model.sync


events : List Event -> List String
events =
    List.map (Event.encode >> JE.encode 0)

