module Settings.Cases exposing (suite)

{-| Characterization tests of `Lia.Settings`: every message on several
settings, the JSON round trip and all menus. The expected strings were
recorded from the previous version (`Settings.Snapshots`).
-}

import Dict
import Expect
import Html exposing (Html)
import Html.Attributes
import HtmlSnapshot
import I18n.Translations exposing (Lang(..))
import Json.Encode as JE
import Lia.Definition.Types as Definition
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Settings.Json as Json
import Lia.Settings.Types as Types exposing (Action(..), Audio(..), Mode(..), PlaybackState(..), Settings)
import Lia.Settings.Update as Update exposing (Msg(..), Toggle(..))
import Lia.Settings.View as View
import Lia.Sync.Types as Sync
import Return exposing (Return)
import Service.Event as Event exposing (Event)
import Test exposing (Test, describe, test)
import Test.Html.Event as HE
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Lia.Settings"
        [ describe "update"
            [ test "Toggle Sound turns off and cancels, or turns on and reads from the current effect" <|
                \_ ->
                    ( run Nothing (Toggle Sound) base, run mainContext (Toggle Sound) { base | sound = False }, run Nothing (Toggle Sound) { base | sound = False } )
                        |> Expect.equal ( ( "sound=False", [ "tts/cancel", "db/settings" ] ), ( "sound=True", [ "tts/read", "db/settings" ] ), ( "sound=True", [ "db/settings" ] ) )
            , test "Toggle Sync opens the classroom and lists the saved classrooms of the course" <|
                \_ ->
                    ( run mainContext (Toggle Sync) base, run (Just { mainRecord | readme = "" }) (Toggle Sync) base, run mainContext (Toggle Sync) { base | sync = Just True } )
                        |> Expect.equal ( ( "sync=Just True", [ "sync/list_classrooms" ] ), ( "sync=Just True", [] ), ( "sync=Just False", [] ) )
            , test "Toggle Chat" <|
                \_ ->
                    ( run Nothing (Toggle Chat) { base | support_menu = True }, run Nothing (Toggle Chat) { base | chat = { show = True, updates = False } } )
                        |> Expect.equal ( ( "chat={ show = True, updates = True } support_menu=False", [ "slide/scroll_down" ] ), ( "chat={ show = False, updates = False }", [] ) )
            , test "Toggle Action opens, switches, and closes a menu" <|
                \_ ->
                    [ run Nothing (Toggle (Action ShowModes)) base
                    , run Nothing (Toggle (Action ShowModes)) { base | action = Just ShowModes }
                    , run Nothing (Toggle (Action ShowShare)) { base | action = Just ShowModes }
                    , run Nothing (Toggle (Action Close)) { base | action = Just ShowModes }
                    , run Nothing (FocusLoss (Just ShowShare)) { base | action = Just ShowModes }
                    ]
                        |> List.map Tuple.first
                        |> Expect.equal [ "action=Just ShowModes", "action=Nothing", "action=Just ShowShare", "action=Nothing", "action=Nothing" ]
            , test "Textbook mode turns off the sound" <|
                \_ ->
                    ( run Nothing (SwitchMode Textbook) base, run Nothing (SwitchMode Slides) base )
                        |> Expect.equal ( ( "mode=Textbook sound=False", [ "tts/cancel", "db/settings" ] ), ( "mode=Slides", [ "db/settings" ] ) )
            , test "Google translate can only be switched on" <|
                \_ ->
                    ( run Nothing (Toggle TranslateWithGoogle) base, run Nothing (Toggle TranslateWithGoogle) { base | translateWithGoogle = Nothing } )
                        |> Expect.equal ( ( "translateWithGoogle=Just True", [ "translate/google" ] ), ( "", [ "translate/google" ] ) )
            , test "only some changes are stored" <|
                \_ ->
                    [ Toggle TableOfContents, Toggle Light, Toggle Tooltips, Toggle VideoComments, ChangeTheme "red", ChangeEditor "x", ChangeLang "de", ChangeFontSize 2, Change (Pitch "2"), Toggle QRCode, Toggle Fullscreen, Toggle SupportMenu, Ignore ]
                        |> List.map (\msg -> run Nothing msg base |> Tuple.second)
                        |> Expect.equal [ [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [ "db/settings" ], [], [ "slide/fullscreen" ], [ "db/settings" ], [] ]
            , test "changed values" <|
                \_ ->
                    [ ChangeTheme "blue", ChangeEditor "monokai", ChangeLang "de", ChangeFontSize 3, Change (Pitch "1.5"), Change (Rate "0.75") ]
                        |> List.foldl (\msg settings -> (Update.update Nothing msg settings).value) base
                        |> (\s -> ( ( s.theme, s.editor, s.lang ), s.font_size, s.audio ))
                        |> Expect.equal ( ( "blue", "monokai", "de" ), 3, { pitch = "1.5", rate = "0.75" } )
            , test "the browser voice is preferred, if it is the only one" <|
                \_ ->
                    let
                        checked tts_ =
                            view (View.menuSettings 1200 En True { base | tts = tts_ })
                                |> Query.findAll [ Selector.class "lia-checkbox" ]
                                |> Query.index 2
                                |> Query.has [ Selector.checked True ]
                    in
                    Expect.all
                        [ \_ -> checked { preferBrowser = False, isBrowserSupported = True, isResponsiveVoiceSupported = False, avatar = Nothing }
                        , \_ -> checked { preferBrowser = True, isBrowserSupported = True, isResponsiveVoiceSupported = True, avatar = Nothing }
                        ]
                        ()
            , test "PreferBrowserTTS is stored and passed on" <|
                \_ ->
                    run Nothing (Toggle PreferBrowserTTS) base
                        |> Tuple.second
                        |> Expect.equal [ "tts/preferBrowserTTS", "db/settings" ]
            , test "sharing a course" <|
                \_ ->
                    Update.update mainContext (ShareCourse "https://url") base
                        |> .events
                        |> List.map (Event.encode >> JE.encode 0)
                        |> Expect.equal [ "{\"reply\":false,\"track\":[],\"service\":\"share\",\"message\":{\"cmd\":\"link\",\"param\":{\"title\":\"T\",\"text\":\"c\",\"url\":\"https://url\",\"files\":[\"l.png\"]}}}" ]
            , test "TTS events" <|
                \_ ->
                    [ ( tts "start" JE.null, base )
                    , ( tts "stop" JE.null, { base | playback = Speaking } )
                    , ( tts "paused" JE.null, base )
                    , ( tts "paused" JE.null, { base | playback = SpeakingWithProgress { current = 1, total = 2 } } )
                    , ( tts "progress" (JE.string "{\"current\":1,\"total\":2}"), base )
                    , ( tts "progress" (JE.string "{\"current\":1,\"total\":2}"), { base | playback = PausedWithProgress { current = 0, total = 2 } } )
                    , ( tts "progress" (JE.string "{\"current\":1,\"total\":2}"), { base | playback = SeekingFromPlaying { current = 0, total = 2 } } )
                    , ( tts "progress" (JE.string "{\"current\":1,\"total\":2}"), { base | playback = SeekingFromPaused { current = 0, total = 2 } } )
                    ]
                        |> List.map (\( event, settings ) -> (Update.update Nothing (Handle event) settings).value.playback)
                        |> Expect.equal
                            [ Speaking
                            , Idle
                            , Paused
                            , PausedWithProgress { current = 1, total = 2 }
                            , SpeakingWithProgress { current = 1, total = 2 }
                            , PausedWithProgress { current = 1, total = 2 }
                            , SeekingFromPlaying { current = 0, total = 2 }
                            , SeekingFromPaused { current = 0, total = 2 }
                            ]
            , test "TTS support and avatar" <|
                \_ ->
                    [ tts "browserTTS" (JE.bool True), tts "responsiveVoiceTTS" (JE.bool True), tts "avatar" (JE.string "lia-avatar") ]
                        |> List.foldl (\event settings -> (Update.update Nothing (Handle event) settings).value) base
                        |> .tts
                        |> Expect.equal { preferBrowser = False, isBrowserSupported = True, isResponsiveVoiceSupported = True, avatar = Just "lia-avatar" }
            , test "init loads the stored settings and passes the TTS preference on" <|
                \_ ->
                    let
                        r =
                            Update.update Nothing (Handle (Event.init "settings" { cmd = "init", param = Json.fromModel { base | mode = Textbook, theme = "blue" } })) base
                    in
                    ( ( r.value.mode, r.value.theme ), List.map (\e -> e.service ++ "/" ++ e.message.cmd) r.events )
                        |> Expect.equal ( ( Textbook, "blue" ), [ "tts/preferBrowserTTS" ] )
            , test "other events store the settings" <|
                \_ ->
                    run Nothing (Handle (Event.init "other" { cmd = "x", param = JE.null })) base
                        |> Tuple.second
                        |> Expect.equal [ "db/settings" ]
            , test "helpers" <|
                \_ ->
                    ( ( (Update.closeSync base).sync, (Update.closeSync { base | sync = Nothing }).sync, (Update.closeSync { base | sync = Just True }).sync )
                    , ( (Update.updatedChatMessages base).chat, (Update.updatedChatMessages { base | chat = { show = True, updates = False } }).chat )
                    , ( Update.customizeEvent { base | theme = "custom", customTheme = Just "x" } |> .message |> .param |> JE.encode 0 |> String.contains "\"custom\":\"x\""
                      , Update.customizeEvent { base | customTheme = Just "x" } |> .message |> .param |> JE.encode 0 |> String.contains "\"custom\":null"
                      )
                    )
                        |> Expect.equal
                            ( ( Just False, Nothing, Just False )
                            , ( { show = False, updates = True }, { show = True, updates = False } )
                            , ( True, True )
                            )
            , test "JSON round trip" <|
                \_ ->
                    let
                        settings =
                            { base | mode = Slides, theme = "t", light = False, editor = "e", font_size = 3, sound = False, lang = "de", tooltips = True, hideVideoComments = True, audio = { pitch = "1.5", rate = "0.75" }, table_of_contents = False }
                    in
                    Json.toModel base (Json.fromModel settings)
                        |> Expect.equal (Ok settings)
            ]
        , describe "events"
            [ test "the TOC button toggles the TOC" <|
                \_ ->
                    View.btnIndex En False
                        |> Query.fromHtml
                        |> HE.simulate HE.click
                        |> HE.expect (Toggle TableOfContents)
            , test "a mode button switches the mode, also with Enter" <|
                \_ ->
                    let
                        button =
                            view (View.menuMode En True base)
                                |> Query.find [ Selector.id "lia-mode-slides" ]
                    in
                    Expect.all
                        [ \_ -> button |> HE.simulate HE.click |> HE.expect (SwitchMode Slides)
                        , \_ -> button |> HE.simulate (keydown 13) |> HE.expect (SwitchMode Slides)
                        ]
                        ()
            , test "the menu button opens its group, Escape closes it" <|
                \_ ->
                    let
                        button =
                            view (View.menuMode En True base)
                                |> Query.find [ Selector.id "lia-mode-menu-button" ]
                    in
                    Expect.all
                        [ \_ -> button |> HE.simulate HE.click |> HE.expect (Toggle (Action ShowModes))
                        , \_ -> button |> HE.simulate (keydown 27) |> HE.expect (Toggle (Action Close))
                        , \_ -> button |> HE.simulate (HE.custom "blur" (JE.object [ ( "target", JE.object [ ( "dataset", JE.object [ ( "groupId", JE.string "mode" ) ] ) ] ), ( "relatedTarget", JE.null ) ])) |> HE.expect (FocusLoss (Just ShowModes))
                        ]
                        ()
            , test "the translation button opens with click and arrow down" <|
                \_ ->
                    let
                        button =
                            view (View.menuTranslations "de" (Definition.default "" "") En True base)
                                |> Query.find [ Selector.tag "button" ]
                    in
                    Expect.all
                        [ \_ -> button |> HE.simulate HE.click |> HE.expect (Toggle (Action ShowTranslations))
                        , \_ -> button |> HE.simulate (keydown 40) |> HE.expect (Toggle (Action ShowTranslations))
                        , \_ -> button |> HE.simulate (keydown 27) |> HE.expect (Toggle (Action Close))
                        ]
                        ()
            , test "settings controls" <|
                \_ ->
                    let
                        menu =
                            view (View.menuSettings 1200 En True { base | customTheme = Just "x" })
                    in
                    Expect.all
                        [ \_ -> menu |> Query.find [ Selector.id "lia-btn-light-mode" ] |> HE.simulate HE.click |> HE.expect (Toggle Light)
                        , \_ -> menu |> Query.find [ Selector.id "lia-btn-fullscreen" ] |> HE.simulate HE.click |> HE.expect (Toggle Fullscreen)
                        , \_ -> menu |> Query.find [ Selector.id "lia-theme-color-red" ] |> HE.simulate HE.click |> HE.expect (ChangeTheme "red")
                        , \_ -> menu |> Query.find [ Selector.id "lia-theme-color-custom" ] |> HE.simulate HE.click |> HE.expect (ChangeTheme "custom")
                        , \_ -> menu |> Query.find [ Selector.id "lia-theme-color-red" ] |> HE.simulate (keydown 37) |> Expect.all [ HE.expect Ignore, HE.expectStopPropagation ]
                        , \_ -> menu |> Query.find [ Selector.tag "select" ] |> HE.simulate (HE.input "monokai") |> HE.expect (ChangeEditor "monokai")
                        , \_ -> menu |> Query.find [ Selector.class "lia-fontscale__lvl-2" ] |> HE.simulate HE.click |> HE.expect (ChangeFontSize 2)
                        , \_ -> menu |> Query.findAll [ Selector.class "lia-checkbox" ] |> Query.index 0 |> HE.simulate HE.click |> HE.expect (Toggle Tooltips)
                        , \_ -> menu |> Query.findAll [ Selector.class "lia-checkbox" ] |> Query.index 1 |> HE.simulate HE.click |> HE.expect (Toggle VideoComments)
                        , \_ -> menu |> Query.findAll [ Selector.class "lia-checkbox" ] |> Query.index 2 |> HE.simulate HE.click |> HE.expect (Toggle PreferBrowserTTS)
                        , \_ -> menu |> Query.findAll [ Selector.attribute (Html.Attributes.type_ "range") ] |> Query.index 0 |> HE.simulate (HE.input "1.25") |> HE.expect (Change (Rate "1.25"))
                        , \_ -> menu |> Query.findAll [ Selector.attribute (Html.Attributes.type_ "range") ] |> Query.index 1 |> HE.simulate (HE.input "0.5") |> HE.expect (Change (Pitch "0.5"))
                        , \_ -> menu |> Query.findAll [ Selector.attribute (Html.Attributes.type_ "range") ] |> Query.index 1 |> HE.simulate (keydown 37) |> Expect.all [ HE.expect Ignore, HE.expectStopPropagation ]
                        ]
                        ()
            , test "share menu" <|
                \_ ->
                    let
                        menu =
                            view (View.menuShare "https://x" syncSupported En True { base | hasShareApi = Just True, action = Just ShowShare })
                    in
                    Expect.all
                        [ \_ -> menu |> Query.find [ Selector.id "lia-button-qr-code" ] |> HE.simulate HE.click |> HE.expect (Toggle QRCode)
                        , \_ -> menu |> Query.find [ Selector.attribute (Html.Attributes.title "Classroom") ] |> HE.simulate HE.click |> HE.expect (Toggle Sync)
                        , \_ -> menu |> Query.findAll [ Selector.tag "button" ] |> Query.index 2 |> HE.simulate HE.click |> HE.expect (ShareCourse "https://x")
                        ]
                        ()
            , test "the chat button shows new messages" <|
                \_ ->
                    [ { show = False, updates = False }, { show = False, updates = True }, { show = True, updates = True } ]
                        |> List.map
                            (\chat ->
                                view (View.menuChat En True { base | chat = chat })
                                    |> Query.find [ Selector.tag "i" ]
                                    |> Query.has [ Selector.class "icon-chat-new" ]
                                    |> (\e -> e == Expect.pass)
                            )
                        |> Expect.equal [ False, True, False ]
            , test "the share icon for small screens is labeled share" <|
                \_ ->
                    view (View.menuShare "https://x" syncSupported En True base)
                        |> Query.find [ Selector.class "hide-md-up" ]
                        |> Query.has [ Selector.attribute (Html.Attributes.title "Share") ]
            , test "translate with Google" <|
                \_ ->
                    view (View.menuTranslations "de" (Definition.default "" "") En True base)
                        |> Query.find [ Selector.id "lia-checkbox-google_translate" ]
                        |> HE.simulate HE.click
                        |> HE.expect (Toggle TranslateWithGoogle)
            , test "chat and support buttons in the header" <|
                \_ ->
                    let
                        h =
                            header True True base
                    in
                    Expect.all
                        [ \_ -> h |> Query.find [ Selector.id "lia-btn-chat" ] |> HE.simulate HE.click |> HE.expect (Toggle Chat)
                        , \_ -> h |> Query.find [ Selector.id "lia-btn-chat-toggler" ] |> HE.simulate HE.click |> HE.expect (Toggle Chat)
                        , \_ -> h |> Query.find [ Selector.id "lia-btn-support" ] |> HE.simulate HE.click |> HE.expect (Toggle SupportMenu)
                        ]
                        ()
            ]
        ]


base : Settings
base =
    Types.init (Just False) False Presentation


mainRecord : { title : String, comment : List Inline, effectID : Maybe Int, logo : Maybe String, readme : String }
mainRecord =
    { title = "T", comment = [ Chars "c" [] ], effectID = Just 3, logo = Just "l.png", readme = "https://r/README.md" }


mainContext : Maybe { title : String, comment : List Inline, effectID : Maybe Int, logo : Maybe String, readme : String }
mainContext =
    Just mainRecord


tts : String -> JE.Value -> Event
tts cmd param =
    Event.init "tts" { cmd = cmd, param = param }


syncSupported : Sync.Settings
syncSupported =
    Sync.init [ "gun" ]


{-| The changed fields (as `field=value`) and the events (`service/cmd`).
-}
run : Maybe { title : String, comment : List Inline, effectID : Maybe Int, logo : Maybe String, readme : String } -> Msg -> Settings -> ( String, List String )
run main_ msg settings =
    let
        r =
            Update.update main_ msg settings

        fields s =
            [ ( "action", Debug.toString s.action ), ( "chat", Debug.toString s.chat ), ( "mode", Debug.toString s.mode ), ( "sound", Debug.toString s.sound ), ( "support_menu", Debug.toString s.support_menu ), ( "sync", Debug.toString s.sync ), ( "translateWithGoogle", Debug.toString s.translateWithGoogle ) ]
    in
    ( List.map2
        (\( name, before ) ( _, after ) ->
            if before == after then
                Nothing

            else
                Just (name ++ "=" ++ after)
        )
        (fields settings)
        (fields r.value)
        |> List.filterMap identity
        |> String.join " "
    , List.map (\e -> e.service ++ "/" ++ e.message.cmd) r.events
    )


keydown : Int -> ( String, JE.Value )
keydown code =
    HE.custom "keydown" (JE.object [ ( "keyCode", JE.int code ), ( "shiftKey", JE.bool False ) ])


view : List (Html Msg) -> Query.Single Msg
view =
    Html.div [] >> Query.fromHtml


header : Bool -> Bool -> Settings -> Query.Single Msg
header online active settings =
    View.header
        { online = online
        , active = active
        , lang = En
        , screen = { width = 1200, height = 800 }
        , settings = settings
        , logo = "logo.png"
        , progress = "50%"
        , buttons = [ View.menu "chat" View.menuChat, View.menu "mode" View.menuMode ]
        }
        |> Query.fromHtml
