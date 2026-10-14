port module Lia.Update exposing
    ( Msg(..)
    , generate
    , get_active_section
    , subscriptions
    , update
    )

import Array exposing (Array)
import Const
import Dict
import Json.Decode as JD
import Lia.Chat.Update as Chat
import Lia.Index.Update as Index
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (Model, loadResource)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section exposing (Section)
import Lia.Settings.Types exposing (Mode(..), PlaybackState(..), Settings)
import Lia.Settings.Update as Settings
import Lia.Sync.Update as Sync
import Lia.Utils exposing (checkPersistency)
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane
import Return exposing (Return)
import Service.Console
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script
import Service.Slide
import Service.TTS
import Session exposing (Session)


port media : (( String, Maybe Int, Maybe Int ) -> msg) -> Sub msg


{-| If the model has an activated section, then all subscriptions will be passed
to this section, otherwise everything is blocked.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            [ section
                |> Markdown.subscriptions
                |> Sub.map UpdateMarkdown
            , media Media
            , SplitPane.subscriptions model.pane |> Sub.map Pane
            ]
                |> Sub.batch

        Nothing ->
            media Media


{-| Main LiaScript messages:

  - `Load`: load a specific section if it is not loaded yet or force a loading
  - `InitSection`: if the `Load` response is received, this message is called to
    perform parsing, if necessary, and initialize all section base settings
  - `PrevSection`: go to next animation fragment or section, this depends on
    the currently applied presentation mode
  - `NextSection`: like `PrevSection` but go back
  - `UpdateIndex`: encapsulates all searching related issues
  - `UpdateSettings`: encapsulates all settings messages
  - `UpdateMarkdown`: encapsulates all Section related stuff
  - `Handle`: handle all received external events and pass them to the
    appropriate instance
  - `Home`: go to the main index page
  - `KeyPressIgnored`: skip event
  - `Script`: every update function handles a Script message, this is used to
    pass messages that relate to `Lia.Markdown.Effect.Script`, that means
    javascript elements can be everywhere

-}
type Msg
    = Load Bool Int
    | InitSection
    | PrevSection
    | NextSection
    | JumpToFragment Int
    | UpdateIndex Index.Msg
    | UpdateSettings Settings.Msg
    | UpdateMarkdown Markdown.Msg
    | UpdateSync Sync.Msg
    | UpdateChat Chat.Msg
    | UpdateOverlay Overlay.Msg
    | Handle Event
    | Home
    | Script ( Int, Script.Msg Markdown.Msg )
    | TTSReplay Bool
    | TTSPause
    | TTSResume
    | TTSStartSeeking
    | TTSSeek Float
    | Media ( String, Maybe Int, Maybe Int )
    | Pane SplitPane.Msg
    | Focus


{-| Apply the bulk `"quizAll"`/`"surveyAll"` preload reply (see
`Lia.Sync.Update.preloadEvents`) to every affected section at once, via
`Markdown.handleAll`, instead of routing one event per section through the
port bus.
-}
applyLoadAll : Model -> String -> Event -> Return Model Msg Markdown.Msg
applyLoadAll model topic event =
    case
        JD.decodeValue
            (JD.list (JD.map2 Tuple.pair (JD.field "id" JD.int) (JD.field "data" JD.value)))
            event.message.param
    of
        Ok entries ->
            model.sections
                |> Markdown.handleAll model.sync model.definition topic entries
                |> Return.mapValCmd (\sections -> { model | sections = sections }) UpdateMarkdown

        Err _ ->
            Return.val model


update : Session -> Msg -> Model -> Return Model Msg Markdown.Msg
update session msg model =
    case msg of
        Focus ->
            { model | settings = closeTocOnSmallScreens session model.settings }
                |> Return.val
                |> Return.batchEvent (initializeSlide model)

        Load force idx ->
            if -1 < idx && idx < Array.length model.sections then
                let
                    settings =
                        closeTocOnSmallScreens session model.settings

                    loaded =
                        { model | section_active = idx, settings = { settings | playback = Idle } }
                in
                if idx == model.section_active || force then
                    update session InitSection (generate loaded)
                        |> Return.batchEvent
                            (if idx == Array.length model.sections - 1 then
                                Service.Script.exec
                                    5000
                                    False
                                    "console.log(\"__RENDER_DONE__\"); window.dispatchEvent( new CustomEvent(\"puppeteer:ready\", { detail: { status: \"done\", ts: Date.now() }}));"

                             else
                                Event.none
                            )

                else
                    loaded
                        |> Return.val
                        |> Return.cmd (Session.navToSlide session idx)

            else
                Return.val model

        Home ->
            model
                |> Return.val
                |> Return.cmd (Session.navToHome session)

        UpdateIndex childMsg ->
            let
                ( index, sections, cmd ) =
                    Index.update childMsg model.index_model model.sections
            in
            { model | index_model = index, sections = sections }
                |> Return.val
                |> Return.cmd (Cmd.map UpdateIndex cmd)

        UpdateSync childMsg ->
            Sync.update session model childMsg
                |> Return.mapCmd UpdateSync
                |> Return.mapEvents "sync" -1

        UpdateOverlay childMsg ->
            Return.val { model | overlayVideo = Overlay.update childMsg model.overlayVideo }

        Handle event ->
            handle session event model

        Script ( id, sub ) ->
            case Array.get id model.sections of
                Just sec ->
                    sec
                        |> Return.val
                        |> Return.script sub
                        |> Markdown.updateScript
                        |> Return.mapValCmd (setSection model id) UpdateMarkdown

                Nothing ->
                    Return.val model

        Media ( url, width, height ) ->
            Return.val <|
                case ( width, height ) of
                    ( Just w, Just h ) ->
                        { model | media = Dict.insert url ( w, h ) model.media }

                    ( Nothing, Nothing ) ->
                        { model
                            | modal =
                                if url == "" then
                                    Nothing

                                else
                                    Just url
                        }

                    _ ->
                        model

        Pane paneMsg ->
            Return.val { model | pane = SplitPane.update paneMsg model.pane }

        UpdateChat childMsg ->
            { msg = childMsg
            , definition = model.definition
            , model = model.chat
            , sync = model.sync
            }
                |> Chat.update
                |> Return.mapValCmd (\chat -> { model | chat = chat }) UpdateChat

        UpdateMarkdown childMsg ->
            withActiveSection model
                (\sec ->
                    sec
                        |> Markdown.update model.sync model.definition childMsg
                        |> Markdown.revealSolutions
                            { sound = model.settings.sound && model.settings.mode /= Textbook
                            , runAll = model.settings.mode == Textbook
                            }
                            (Markdown.solved sec)
                        |> Return.mapValCmd (setSection model model.section_active) UpdateMarkdown
                )

        NextSection ->
            withActiveSection model
                (\sec ->
                    if model.settings.mode == Textbook || not (Effect.has_next sec.effect_model) then
                        update session (Load False (model.section_active + 1)) model

                    else
                        sec
                            |> Markdown.nextEffect model.sync model.definition model.settings.sound
                            |> Return.mapValCmd (setSection model model.section_active) UpdateMarkdown
                )

        PrevSection ->
            withActiveSection model
                (\sec ->
                    if model.settings.mode == Textbook || not (Effect.has_previous sec.effect_model) then
                        update session (Load False (model.section_active - 1)) model

                    else
                        sec
                            |> Markdown.previousEffect model.sync model.definition model.settings.sound
                            |> Return.mapValCmd (setSection model model.section_active) UpdateMarkdown
                )

        InitSection ->
            withActiveSection model
                (\sec ->
                    let
                        textbook =
                            model.settings.mode == Textbook
                    in
                    sec
                        |> Markdown.initEffect model.sync model.definition textbook (not textbook && model.settings.sound)
                        |> Markdown.revealSolutions { sound = False, runAll = textbook } []
                        |> Return.mapValCmd (setSection { model | to_do = [] } model.section_active) UpdateMarkdown
                        |> Return.batchEvents (initializeSlide model :: model.to_do)
                        |> Return.batchEvent
                            (if model.section_active < Array.length model.sections then
                                Service.Script.exec
                                    (if model.section_active == 0 then
                                        -- Add timeout so that first slide, so that scripts can be loaded
                                        5000

                                     else
                                        1000
                                    )
                                    False
                                <|
                                    "window.LIA.goto("
                                        ++ String.fromInt (model.section_active + 1)
                                        ++ ")"

                             else
                                Event.none
                            )
                )

        JumpToFragment id ->
            withActiveSection model
                (\sec ->
                    if model.settings.mode == Textbook || sec.effect_model.visible == id then
                        Return.val model

                    else
                        let
                            effect =
                                sec.effect_model
                        in
                        { sec | effect_model = { effect | visible = id - 1 } }
                            |> Markdown.nextEffect model.sync model.definition model.settings.sound
                            |> Return.mapValCmd (setSection model model.section_active) UpdateMarkdown
                )

        UpdateSettings childMsg ->
            Settings.update
                (Just
                    { title = model.title
                    , comment = model.definition.comment
                    , effectID = Maybe.map (.effect_model >> .visible) (get_active_section model)
                    , logo =
                        if String.isEmpty model.definition.logo then
                            Nothing

                        else
                            Just model.definition.logo
                    , readme = model.readme
                    }
                )
                childMsg
                model.settings
                |> Return.mapValCmd (\settings -> { model | settings = settings }) UpdateSettings
                |> maybeTextbookChange session model.settings.mode

        TTSReplay replay ->
            case Markdown.ttsReplay model.settings.sound replay (get_active_section model) of
                Just event ->
                    -- todo: important, this might be the reason for failures in tts
                    Return.val model
                        |> Return.batchEvent event

                Nothing ->
                    Return.val model

        TTSPause ->
            sendTTSEvent Service.TTS.pause model

        TTSResume ->
            sendTTSEvent Service.TTS.resume model

        TTSStartSeeking ->
            { model
                | settings =
                    mapPlayback
                        (\playback ->
                            case playback of
                                SpeakingWithProgress p ->
                                    SeekingFromPlaying p

                                PausedWithProgress p ->
                                    SeekingFromPaused p

                                _ ->
                                    playback
                        )
                        model.settings
            }
                |> Return.val

        TTSSeek seconds ->
            case get_active_section model of
                Just _ ->
                    sendTTSEvent (Service.TTS.seek seconds)
                        { model
                            | settings =
                                mapPlayback
                                    (\playback ->
                                        case playback of
                                            SeekingFromPlaying p ->
                                                SpeakingWithProgress { p | current = seconds }

                                            SeekingFromPaused p ->
                                                PausedWithProgress { p | current = seconds }

                                            _ ->
                                                playback
                                    )
                                    model.settings
                        }

                Nothing ->
                    Return.val model


{-| **@private:** Route an external event by the first topic of its track.
-}
handle : Session -> Event -> Model -> Return Model Msg Markdown.Msg
handle session event model =
    case Event.pop event of
        ( Just "settings", e ) ->
            update session (UpdateSettings (Settings.handle e)) model

        ( Just "load", _ ) ->
            update session InitSection (generate model)

        -- external triggers to move to a specific slide
        ( Just "goto", _ ) ->
            case event.message.cmd of
                "goto" ->
                    case JD.decodeValue JD.int event.message.param of
                        Ok id ->
                            update session (Load True id) model

                        Err _ ->
                            Return.val model
                                |> Return.batchEvent (Service.Console.warn "message goto with no id")

                "next" ->
                    update session NextSection model

                "prev" ->
                    update session PrevSection model

                _ ->
                    Return.val model
                        |> Return.batchEvent (Service.Console.warn "message goto unknown")

        ( Just "sync", e ) ->
            case Event.popWithId e of
                Nothing ->
                    e
                        |> Sync.handle session
                            (if e.message.cmd == "connect" then
                                { model | settings = Settings.closeSync model.settings }

                             else
                                model
                            )
                        |> Return.mapCmd UpdateSync
                        |> Return.mapEvents "sync" -1

                Just ( "load", id, _ ) ->
                    update session (Load True id) model

                Just ( "quizAll", _, e_ ) ->
                    applyLoadAll model "quiz" e_

                Just ( "surveyAll", _, e_ ) ->
                    applyLoadAll model "survey" e_

                Just ( topic, id, e_ ) ->
                    -- ids from 10000 on belong to chat messages
                    case ( id < 10000, Array.get id model.sections ) of
                        ( True, Just sec ) ->
                            handleSection model id sec topic e_

                        ( False, Nothing ) ->
                            update session (UpdateChat (Chat.handle e)) model

                        _ ->
                            Return.val model

        ( Just "swipe", e ) ->
            case JD.decodeValue JD.string e.message.param of
                Ok "left" ->
                    update session NextSection model

                Ok "right" ->
                    update session PrevSection model

                _ ->
                    Return.val model

        ( Just topic, e ) ->
            case Event.id event of
                Just id ->
                    case Array.get id model.sections of
                        Just sec ->
                            handleSection model id sec topic e

                        Nothing ->
                            update session (UpdateChat (Chat.handle event)) model

                Nothing ->
                    Return.val model

        ( Nothing, _ ) ->
            Return.val model
                |> Return.batchEvent (Service.Console.warn ("unknown event: " ++ event.service ++ " / " ++ event.message.cmd))


{-| **@private:** Pass an event to section `id` and reveal its newly solved
quizzes and surveys.
-}
handleSection : Model -> Int -> Section -> String -> Event -> Return Model Msg Markdown.Msg
handleSection model id sec topic event =
    sec
        |> Markdown.handle model.sync model.definition topic event
        |> Markdown.revealSolutions { sound = False, runAll = model.settings.mode == Textbook } (Markdown.solved sec)
        |> Return.mapValCmd (setSection model id) UpdateMarkdown


{-| **@private:** Apply `fn` to the active section, do nothing if there is none.
-}
withActiveSection : Model -> (Section -> Return Model Msg Markdown.Msg) -> Return Model Msg Markdown.Msg
withActiveSection model fn =
    case get_active_section model of
        Just sec ->
            fn sec

        Nothing ->
            Return.val model


{-| **@private:** The table of contents covers the whole slide on small screens,
so it gets closed whenever the slide changes or gets the focus.
-}
closeTocOnSmallScreens : Session -> Settings -> Settings
closeTocOnSmallScreens session settings =
    if session.screen.width <= Const.globalBreakpoints.sm then
        { settings | table_of_contents = False }

    else
        settings


mapPlayback : (PlaybackState -> PlaybackState) -> Settings -> Settings
mapPlayback fn settings =
    { settings | playback = fn settings.playback }


{-| **@private:** Send a TTS event (pause, resume, seek) for the active section.
-}
sendTTSEvent : Event -> Model -> Return Model Msg Markdown.Msg
sendTTSEvent ttsEvent model =
    case get_active_section model of
        Just sec ->
            Return.val model
                |> Return.batchEvent (Event.pushWithId "settings" sec.id ttsEvent)

        Nothing ->
            Return.val model


{-| **@private:** The browser tab title, `section title · course title`.
-}
getTitle : Model -> String
getTitle model =
    case get_active_section model of
        Just sec ->
            stringify_
                { scripts = sec.effect_model.javascript
                , visible =
                    if sec.visible then
                        Just sec.effect_model.visible

                    else
                        Nothing
                , input = { options = Array.empty, state = Array.empty }
                }
                sec.title
                ++ " · "
                ++ model.title

        Nothing ->
            model.title


{-| **@private:** Tell JavaScript about the active slide (URL, title, focus).
-}
initializeSlide : Model -> Event
initializeSlide model =
    Service.Slide.initialize model.section_active (getTitle model)


{-| **@private:** This helper is only required if the mode changes to Textbook.
It is required to load the JavaScript effects properly. Otherwise, switching from
to Textbook mode would not trigger the execution of previously not shown effects,
which are defined in an animation step that has not been revealed ...
-}
maybeTextbookChange : Session -> Mode -> Return Model Msg Markdown.Msg -> Return Model Msg Markdown.Msg
maybeTextbookChange session mode ret =
    if ret.value.settings.mode == Textbook && mode /= Textbook then
        ret.value
            |> update session (Load False ret.value.section_active)
            |> Return.batchEvents ret.events

    else
        ret


{-| **@private:** shortcut for creating load events for quz-, survey-, task-,
and code-vectors and adding it to an existing event list. If the vector is empty
no element is added.
-}
add_load : Array a -> Int -> String -> List Event -> List Event
add_load vector sectionID name logs =
    if Array.isEmpty vector then
        logs

    else
        (Service.Database.load name sectionID
            |> Event.pushWithId name sectionID
        )
            :: logs


{-| The currently visible section, `Nothing` if the course has no sections.
-}
get_active_section : Model -> Maybe Section
get_active_section model =
    Array.get model.section_active model.sections


{-| **@private:** Replace section `id` by one, where something has changed
(`effect_model`, `quiz_vector`, etc.).
-}
setSection : Model -> Int -> Section -> Model
setSection model id section =
    { model | sections = Array.set id section model.sections }


{-| Initialize the active section if it has not been parsed so far, which means:

1.  parse the section code

2.  try to load existing vectors/states from the backend

3.  load additional resources or macros that might be defined in the
    section-head:

    ```Markdown
    <!- -
    author: someone

    @some_macro: Hello world

    script: https://...
    - ->
    ```

-}
generate : Model -> Model
generate model =
    case get_active_section model of
        Just sec ->
            let
                section =
                    if sec.parsed then
                        let
                            effects =
                                sec.effect_model
                        in
                        { sec | effect_model = { effects | visible = 0 } }

                    else
                        case parse_section model.search_index model.definition sec of
                            Ok new_sec ->
                                { new_sec | persistent = Maybe.map (.macro >> checkPersistency) new_sec.definition }

                            Err msg ->
                                { sec
                                    | body = []
                                    , error = Just msg
                                }

                ( resource, logs ) =
                    section
                        |> .definition
                        |> Maybe.map .resources
                        |> Maybe.withDefault []
                        |> loadResource model.resource
            in
            setSection
                { model
                    | resource = resource
                    , to_do =
                        model.to_do
                            |> List.append logs
                            |> add_load section.quiz_vector model.section_active "quiz"
                            |> add_load section.code_model.evaluate model.section_active "code"
                            |> add_load section.survey_vector model.section_active "survey"
                            |> add_load section.task_vector model.section_active "task"
                }
                model.section_active
                section

        Nothing ->
            model
