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
import Html.Attributes exposing (width)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Model as Graph
import Lia.Index.Update as Index
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (Model, loadResource)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section exposing (Section)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Settings.Update as Settings
import Port.Event as Event exposing (Event)
import Return exposing (Return)
import Session exposing (Session)
import SplitPane


port media : (( String, Maybe Int, Maybe Int ) -> msg) -> Sub msg


{-| If the model has an activated section, then all subscriptions will be passed
to this section, otherwise everything is blocked.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            Sub.batch
                [ section
                    |> Markdown.subscriptions
                    |> Sub.map UpdateMarkdown
                , media Media
                , Sub.map PaneMsg <| SplitPane.subscriptions model.splitPane
                ]

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
    | Handle Event
    | Home
    | Script ( Int, Script.Msg Markdown.Msg )
    | TTSReplay Bool
    | Media ( String, Maybe Int, Maybe Int )
    | PaneMsg SplitPane.Msg


update : Session -> Msg -> Model -> Return Model Msg Markdown.Msg
update session msg model =
    case msg of
        Load force idx ->
            let
                settings =
                    model.settings
            in
            if (-1 < idx) && (idx < Array.length model.sections) then
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

            else
                Return.val model

        Home ->
            model
                |> Return.val
                |> Return.cmd (Session.navToHome session)

        UpdateSettings childMsg ->
            model.settings
                |> Settings.update (Just { title = model.title, comment = model.definition.comment }) childMsg
                |> Return.mapValCmd (\v -> { model | settings = v }) UpdateSettings

        UpdateIndex childMsg ->
            let
                ( index, sections, cmd ) =
                    Index.update childMsg model.index_model model.sections
            in
            { model | index_model = index, sections = sections }
                |> Return.val
                |> Return.cmd (Cmd.map UpdateIndex cmd)

        Handle event ->
            case event.topic of
                "settings" ->
                    case event.message |> Event.decode of
                        Ok e ->
                            update
                                session
                                (e
                                    |> Settings.handle
                                    |> UpdateSettings
                                )
                                model

                        _ ->
                            Return.val model

                "load" ->
                    update session InitSection (generate model)

                "reset" ->
                    model
                        |> Return.val
                        |> Return.batchEvent (Event "reset" -1 JE.null)

                "goto" ->
                    update session (Load True event.section) model

                "swipe" ->
                    case JD.decodeValue JD.string event.message of
                        Ok "left" ->
                            update session NextSection model

                        Ok "right" ->
                            update session PrevSection model

                        _ ->
                            Return.val model

                _ ->
                    case
                        ( Array.get event.section model.sections
                        , Event.decode event.message
                        )
                    of
                        ( Just sec, Ok e ) ->
                            sec
                                |> Markdown.handle model.definition event.topic e
                                |> Return.mapValCmd (\v -> { model | sections = Array.set event.section v model.sections }) UpdateMarkdown

                        _ ->
                            Return.val model

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

        PaneMsg paneMsg ->
            ( { model | splitPane = SplitPane.update paneMsg model.splitPane }
            , Cmd.none
            , []
            )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    sec
                        |> Markdown.update model.definition childMsg
                        |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( NextSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_next sec.effect_model) then
                        update session (Load False (model.section_active + 1)) model

                    else
                        sec
                            |> Markdown.nextEffect model.definition model.settings.sound
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update session (Load False (model.section_active - 1)) model

                    else
                        sec
                            |> Markdown.previousEffect model.definition model.settings.sound
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( InitSection, Just sec ) ->
                    let
                        return =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect model.definition True False sec

                                _ ->
                                    Markdown.initEffect model.definition False model.settings.sound sec
                    in
                    return
                        |> Return.mapValCmd
                            (set_active_section { model | to_do = [] })
                            UpdateMarkdown
                        |> Return.batchEvents (Event "slide" model.section_active JE.null :: model.to_do)

                ( JumpToFragment id, Just sec ) ->
                    if (model.settings.mode == Textbook) || sec.effect_model.visible == id then
                        Return.val model

                    else
                        let
                            effect =
                                sec.effect_model

                            return =
                                Markdown.nextEffect model.definition model.settings.sound { sec | effect_model = { effect | visible = id - 1 } }
                        in
                        return
                            |> Return.mapValCmd (set_active_section model) UpdateMarkdown

                ( TTSReplay bool, sec ) ->
                    case Markdown.ttsReplay model.settings.sound bool sec of
                        Just event ->
                            Return.val model
                                |> Return.batchEvent event

                        Nothing ->
                            Return.val model

                _ ->
                    Return.val model


{-| **@private:** shortcut for creating load events for quiz-, survey-, task-,
and code-vectors and adding it to an existing event list. If the vector is empty
no element is added.
-}
add_load : Array a -> Int -> String -> List Event -> List Event
add_load vector sectionID name logs =
    if Array.isEmpty vector then
        logs

    else
        (Event "load" sectionID <| JE.string name) :: logs


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
                newGraph =
                    Graph.rootSection model.section_active model.graph

                ( graph, section ) =
                    if sec.parsed then
                        let
                            effects =
                                sec.effect_model
                        in
                        ( newGraph, { sec | effect_model = { effects | visible = 0 } } )

                    else
                        case parse_section newGraph model.search_index model.definition sec of
                            Ok new_sec ->
                                new_sec

                            Err msg ->
                                ( newGraph
                                , { sec
                                    | body = []
                                    , error = Just msg
                                  }
                                )

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
                    , graph = graph
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
