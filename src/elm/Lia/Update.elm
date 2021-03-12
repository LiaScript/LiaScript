module Lia.Update exposing
    ( Msg(..)
    , generate
    , get_active_section
    , subscriptions
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Index.Update as Index
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (Model, loadResource)
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section exposing (Section)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Settings.Update as Settings
import Port.Event as Event exposing (Event)
import Session exposing (Session)


{-| If the model has an activated section, then all subscriptions will be passed
to this section, otherwise everything is blocked.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    case get_active_section model of
        Just section ->
            section
                |> Markdown.subscriptions
                |> Sub.map UpdateMarkdown

        Nothing ->
            Sub.none


{-| Main LiaScript messages:

  - `Load`: load a specific section if it is not loaded yet or force a loading
  - `InitSection`: if the `Load` response is received, this message is called to
    perform parsing, if necessary, and initialize all section base settings
  - `PrevSection`: go to next anaimation fragment or section, this depends on
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


{-| **@private:** shortcut for generating events for a specific section:

1.  id of the active section
2.  a list of (`String` topics, `Event` messages)

-}
send : Int -> List ( String, JE.Value ) -> List Event
send sectionID =
    List.map (\( name, json ) -> Event name sectionID json)


update : Session -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update session msg model =
    case msg of
        Load force idx ->
            if (-1 < idx) && (idx < Array.length model.sections) then
                if idx == model.section_active || force then
                    { model | section_active = idx }
                        |> generate
                        |> update session InitSection

                else
                    ( { model | section_active = idx }
                    , Session.navToSlide session idx
                    , []
                    )

            else
                ( model, Cmd.none, [] )

        Home ->
            ( model, Session.navToHome session, [] )

        UpdateSettings childMsg ->
            let
                ( settings, cmd, events ) =
                    Settings.update childMsg model.settings
            in
            ( { model | settings = settings }
            , Cmd.map UpdateSettings cmd
            , events
            )

        UpdateIndex childMsg ->
            let
                ( index, sections, cmd ) =
                    Index.update childMsg model.index_model model.sections
            in
            ( { model
                | index_model = index
                , sections = sections
              }
            , Cmd.map UpdateIndex cmd
            , []
            )

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
                            ( model, Cmd.none, [] )

                "load" ->
                    update session InitSection (generate model)

                "reset" ->
                    ( model
                    , Cmd.none
                    , [ Event "reset" -1 JE.null ]
                    )

                "goto" ->
                    update session (Load True event.section) model

                "swipe" ->
                    case JD.decodeValue JD.string event.message of
                        Ok "left" ->
                            update session NextSection model

                        Ok "right" ->
                            update session PrevSection model

                        _ ->
                            ( model, Cmd.none, [] )

                _ ->
                    case
                        ( Array.get event.section model.sections
                        , Event.decode event.message
                        )
                    of
                        ( Just sec, Ok e ) ->
                            let
                                ( sec_, cmd_, events ) =
                                    Markdown.handle event.topic e sec
                            in
                            ( { model | sections = Array.set event.section sec_ model.sections }
                            , Cmd.map UpdateMarkdown cmd_
                            , send event.section events
                            )

                        _ ->
                            ( model, Cmd.none, [] )

        Script ( id, sub ) ->
            case Array.get id model.sections of
                Just sec ->
                    let
                        ( section, cmd_, log_ ) =
                            Markdown.updateScript (Just sub) ( sec, Cmd.none, [] )
                    in
                    ( { model | sections = Array.set id section model.sections }
                    , Cmd.map UpdateMarkdown cmd_
                    , send id log_
                    )

                _ ->
                    ( model, Cmd.none, [] )

        _ ->
            case ( msg, get_active_section model ) of
                ( UpdateMarkdown childMsg, Just sec ) ->
                    let
                        ( section, cmd_, log_ ) =
                            Markdown.update childMsg sec
                    in
                    ( set_active_section model section
                    , Cmd.map UpdateMarkdown cmd_
                    , send model.section_active log_
                    )

                ( NextSection, Just sec ) ->
                    if
                        (model.settings.mode == Textbook)
                            || not (Effect.has_next sec.effect_model)
                    then
                        update session (Load False (model.section_active + 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect model.settings.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , send model.section_active log_
                        )

                ( PrevSection, Just sec ) ->
                    if (model.settings.mode == Textbook) || not (Effect.has_previous sec.effect_model) then
                        update session (Load False (model.section_active - 1)) model

                    else
                        let
                            ( sec_, cmd_, log_ ) =
                                Markdown.previousEffect model.settings.sound sec
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , send model.section_active log_
                        )

                ( InitSection, Just sec ) ->
                    let
                        ( sec_, cmd_, log_ ) =
                            case model.settings.mode of
                                Textbook ->
                                    Markdown.initEffect True False sec

                                _ ->
                                    Markdown.initEffect False model.settings.sound sec
                    in
                    ( set_active_section { model | to_do = [] } sec_
                    , Cmd.map UpdateMarkdown cmd_
                    , model.to_do
                        |> List.append (send model.section_active log_)
                        |> (::) (Event "slide" model.section_active JE.null)
                    )

                ( JumpToFragment id, Just sec ) ->
                    if (model.settings.mode == Textbook) || sec.effect_model.visible == id then
                        ( model, Cmd.none, [] )

                    else
                        let
                            effect =
                                sec.effect_model

                            ( sec_, cmd_, log_ ) =
                                Markdown.nextEffect model.settings.sound { sec | effect_model = { effect | visible = id - 1 } }
                        in
                        ( set_active_section model sec_
                        , Cmd.map UpdateMarkdown cmd_
                        , send model.section_active log_
                        )

                ( TTSReplay bool, sec ) ->
                    ( model
                    , Cmd.none
                    , Markdown.ttsReplay model.settings.sound bool sec
                        |> send -1
                    )

                _ ->
                    ( model, Cmd.none, [] )


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

    ```Mardown
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
                                new_sec

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
                            |> add_load section.code_vector model.section_active "code"
                            |> add_load section.survey_vector model.section_active "survey"
                            |> add_load section.task_vector model.section_active "task"
                }
                section

        Nothing ->
            model
