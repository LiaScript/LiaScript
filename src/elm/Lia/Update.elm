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
import Lia.Settings.Types exposing (Mode(..))
import Lia.Settings.Update as Settings
import Lia.Sync.Update as Sync
import Lia.Utils exposing (checkPersistency)
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane
import Return exposing (Return)
import Service.Console
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Slide
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

            --, Sub.map UpdateSync Sync.subscriptions
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
    | UpdateOverlay (Overlay.Msg Msg)
    | Handle Event
    | Home
    | Script ( Int, Script.Msg Markdown.Msg )
    | TTSReplay Bool
    | Media ( String, Maybe Int, Maybe Int )
    | Pane SplitPane.Msg
    | Focus


update : Session -> Msg -> Model -> Return Model Msg Markdown.Msg
update session msg model =
    case msg of
        Focus ->
            let
                settings =
                    model.settings
            in
            { model
                | settings =
                    { settings
                        | table_of_contents =
                            if session.screen.width <= Const.globalBreakpoints.sm then
                                False

                            else
                                settings.table_of_contents
                    }
            }
                |> Return.val
                |> Return.batchEvent (initializeSlide model)

        Load force idx ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                let
                    settings =
                        model.settings
                in
                if idx == model.section_active || force then
                    update session
                        InitSection
                        (generate
                            { model
                                | section_active = idx
                                , settings =
                                    { settings
                                        | table_of_contents =
                                            if
                                                session.screen.width
                                                    <= Const.globalBreakpoints.sm
                                            then
                                                False

                                            else
                                                settings.table_of_contents
                                    }
                            }
                        )

                else
                    { model
                        | section_active = idx
                        , settings =
                            { settings
                                | table_of_contents =
                                    if session.screen.width <= Const.globalBreakpoints.sm then
                                        False

                                    else
                                        settings.table_of_contents
                            }
                    }
                        |> Return.val
                        |> Return.cmd (Session.navToSlide session idx)
                --|> Return.sync (Event.initWithId "load" idx JE.null)

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
            let
                ( overlay, cmd, cmdParent ) =
                    Overlay.update childMsg model.overlayVideo
            in
            { model | overlayVideo = overlay }
                |> Return.val
                |> Return.cmd
                    (case cmdParent of
                        Just parent ->
                            Cmd.none

                        Nothing ->
                            Cmd.map UpdateOverlay cmd
                    )

        Handle event ->
            case Event.pop event of
                ( Just "settings", e ) ->
                    update
                        session
                        (e
                            |> Settings.handle
                            |> UpdateSettings
                        )
                        model

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
                                    (case e.message.cmd of
                                        "connect" ->
                                            { model | settings = Settings.closeSync model.settings }

                                        _ ->
                                            model
                                    )
                                |> Return.mapCmd UpdateSync
                                |> Return.mapEvents "sync" -1

                        Just ( "load", id, _ ) ->
                            update session (Load True id) model

                        Just ( topic, id, e_ ) ->
                            case ( id < 10000, Array.get id model.sections ) of
                                ( True, Just sec ) ->
                                    sec
                                        |> Markdown.handle model.sync model.definition topic e_
                                        |> Return.mapValCmd (\v -> { model | sections = Array.set id v model.sections }) UpdateMarkdown

                                ( False, Nothing ) ->
                                    update session (UpdateChat (Chat.handle e)) model

                                _ ->
                                    Return.val model

                ( Just "swipe", e ) ->
                    case
                        e
                            |> Event.message
                            -- TODO
                            |> Tuple.second
                            |> JD.decodeValue JD.string
                    of
                        Ok "left" ->
                            update session NextSection model

                        Ok "right" ->
                            update session PrevSection model

                        _ ->
                            Return.val model

                ( Just topic, e ) ->
                    case
                        -- TODO
                        event
                            |> Event.id
                            |> Maybe.map (\id -> ( id, Array.get id model.sections ))
                    of
                        Just ( id, Just sec ) ->
                            sec
                                |> Markdown.handle model.sync model.definition topic e
                                |> Return.mapValCmd (\v -> { model | sections = Array.set id v model.sections }) UpdateMarkdown

                        Just ( id, Nothing ) ->
                            update session (UpdateChat (Chat.handle event)) model

                        _ ->
                            Return.val model

                ( Nothing, _ ) ->
                    Return.val model
                        |> Return.batchEvent (Service.Console.warn ("unknown event: " ++ event.service ++ " / " ++ event.message.cmd))

        Script ( id, sub ) ->
            case Array.get id model.sections of
                Just sec ->
                    sec
                        |> Return.val
                        |> Return.script sub
                        |> Markdown.updateScript
                        |> Return.mapValCmd (\v -> { model | sections = Array.set id v model.sections }) UpdateMarkdown

                _ ->
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
            { model | pane = SplitPane.update paneMsg model.pane }
                |> Return.val

        UpdateChat childMsg ->
            { msg = childMsg
            , definition = model.definition
            , model = model.chat
            , sync = model.sync
            }
                |> Chat.update
                |> Return.mapValCmd
                    (\chat -> { model | chat = chat })
                    UpdateChat

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    sec
                        |> Markdown.update model.sync model.definition childMsg
                        |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( NextSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update session (Load False (model.section_active + 1)) model

                    else
                        sec
                            |> Markdown.nextEffect model.sync model.definition model.settings.sound
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update session (Load False (model.section_active - 1)) model

                    else
                        sec
                            |> Markdown.previousEffect model.sync model.definition model.settings.sound
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( InitSection, Just sec ) ->
                    let
                        return =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect model.sync model.definition True False sec

                                _ ->
                                    Markdown.initEffect model.sync model.definition False model.settings.sound sec
                    in
                    return
                        |> Return.mapValCmd (set_active_section { model | to_do = [] }) UpdateMarkdown
                        |> Return.batchEvents (initializeSlide model :: model.to_do)

                ( JumpToFragment id, Just sec ) ->
                    if (model.settings.mode == Textbook) || sec.effect_model.visible == id then
                        Return.val model

                    else
                        let
                            effect =
                                sec.effect_model

                            return =
                                Markdown.nextEffect model.sync model.definition model.settings.sound { sec | effect_model = { effect | visible = id - 1 } }
                        in
                        return
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( UpdateSettings childMsg, sec ) ->
                    let
                        mode =
                            model.settings.mode
                    in
                    Settings.update
                        (Just
                            { title = model.title
                            , comment = model.definition.comment
                            , effectID =
                                sec
                                    |> Maybe.map .effect_model
                                    |> Maybe.map .visible
                            , logo =
                                model.definition.logo
                                    |> (\logo ->
                                            if String.isEmpty logo then
                                                Nothing

                                            else
                                                Just logo
                                       )
                            }
                        )
                        childMsg
                        model.settings
                        |> Return.mapValCmd (\v -> { model | settings = v }) UpdateSettings
                        |> maybeTextbookChange session mode

                ( TTSReplay bool, sec ) ->
                    case Markdown.ttsReplay model.settings.sound bool sec of
                        Just event ->
                            Return.val model
                                -- todo: important, this might be the reason for failures in tts
                                |> Return.batchEvent event

                        Nothing ->
                            Return.val model

                _ ->
                    Return.val model


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


{-| **@private:** shortcut for returning the active section in from the model.
-}
get_active_section : Model -> Maybe Section
get_active_section model =
    Array.get model.section_active model.sections


{-| **@private:** update the currently active section with one, where something
has changed (`effect_model`, `quiz_vector`, etc.).
-}
set_active_section : Model -> Section -> Model
set_active_section model section =
    { model | sections = Array.set model.section_active section model.sections }


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
            set_active_section
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
                section

        Nothing ->
            model
