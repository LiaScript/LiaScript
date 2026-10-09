port module Lia.Markdown.Code.Update exposing
    ( Msg(..)
    , handle
    , update
    )

{-| Editing, running and versioning of code projects.

Projects referenced by `Evaluate id` can be edited and run, every run of
changed code creates a new version. In a classroom, a project can be switched
into `syncMode`, it then shows and runs the shared code of the classroom
(`sync`) and writes its output into `syncLog` instead of `log`.

-}

import Array exposing (Array)
import Helper.Array as Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Events as Event
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Sync as Sync_ exposing (Sync)
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model, Project, Vector, loadVersion, updateVersion)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Return exposing (Return)
import Service.Event as PEvent exposing (Event)
import Service.Script as Script exposing (Eval)
import Service.Slide
import Service.Sync as Sync


{-| Most messages carry the project id (the index in `evaluate`) and
optionally the file id within the project.
-}
type Msg
    = Eval Int
    | Stop Int
    | Update Int Int String
    | Synchronize Int Int JE.Value
    | SynchronizeCursor Int Int JE.Value
    | FlipView Code Int
    | FlipFullscreen Code Int
    | Load Int Int
    | First Int
    | Last Int
    | UpdateTerminal Int Terminal.Msg
    | Handle Event
    | Resize Code String
    | ToggleSync Int
    | CopyToClipboard Code Int


port copyToClipboard : String -> Cmd msg


{-| Wrap an event from JavaScript.
-}
handle : Event -> Msg
handle =
    Handle


{-| `sync` is the classroom code of the section (empty if there is none),
`sectionID` is `Nothing` within subsections, there nothing gets stored.
-}
update : Array Sync -> Maybe Int -> Scripts a -> Msg -> Model -> Return Model msg sub
update sync sectionID scripts msg model =
    case msg of
        Eval id ->
            model
                |> onProject id
                    (\project ->
                        project
                            |> startRun
                            |> Return.val
                            |> Return.batchEvent (Event.eval sync id scripts project)
                            |> appendVersion sectionID id
                    )

        Update id fileID code ->
            if isSyncModeActive id model then
                Return.val model

            else
                updateFile id fileID (\f -> { f | code = code }) (always []) model

        FlipView (Evaluate id) fileID ->
            updateFile id fileID toggleVisible (Event.flip_view sectionID id fileID) model

        FlipView (Highlight id) fileID ->
            Return.val { model | highlight = mapFile id fileID toggleVisible model.highlight }

        FlipFullscreen (Evaluate id) fileID ->
            updateFile id fileID toggleFullscreen (Event.fullscreen sectionID id fileID) model

        FlipFullscreen (Highlight id) fileID ->
            Return.val { model | highlight = mapFile id fileID toggleFullscreen model.highlight }

        Load id version ->
            load sectionID id version model

        First id ->
            load sectionID id 0 model

        Last id ->
            load sectionID
                id
                (model.evaluate
                    |> Array.get id
                    |> Maybe.map (.version >> Array.length >> (+) -1)
                    |> Maybe.withDefault 0
                )
                model

        Handle event ->
            case PEvent.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    restore sectionID param model
                        |> shareCodes sync sectionID

                ( Just "project", id, ( "eval", param ) ) ->
                    evaluated sectionID id (Script.decode param) model

                ( Just "project", id, ( "log", param ) ) ->
                    case JD.decodeValue (JD.list JD.string) param of
                        Ok [ level, message ] ->
                            logged id level message model

                        _ ->
                            Return.val model

                _ ->
                    Return.val model

        Stop id ->
            model
                |> onProject id
                    (halt
                        >> Return.val
                        >> Return.batchEvent (Event.stop id)
                    )

        Resize code height ->
            let
                resize =
                    Array.update (idOf code) (\p -> { p | logSize = Just height })
            in
            Return.val <|
                case code of
                    Evaluate _ ->
                        { model | evaluate = resize model.evaluate }

                    Highlight _ ->
                        { model | highlight = resize model.highlight }

        UpdateTerminal id childMsg ->
            model
                |> onProject id
                    (\project ->
                        case project.terminal |> Maybe.map (Terminal.update childMsg) of
                            Just ( terminal, Just input ) ->
                                { project | terminal = Just terminal }
                                    |> mapLog (Log.add Log.Info input)
                                    |> Return.val
                                    |> Return.batchEvent (Event.input id input)

                            Just ( terminal, Nothing ) ->
                                Return.val { project | terminal = Just terminal }

                            Nothing ->
                                Return.val project
                    )

        ToggleSync id ->
            updateProject id (\p -> { p | syncMode = not p.syncMode }) model

        Synchronize id fileID change ->
            model
                |> Return.val
                |> whenSyncMode id model (Sync.code id fileID change)

        SynchronizeCursor id fileID position ->
            model
                |> Return.val
                |> whenSyncMode id model (Sync.cursor id fileID position)

        CopyToClipboard project fileID ->
            let
                local vector =
                    vector
                        |> Array.get (idOf project)
                        |> Maybe.andThen (.file >> Array.get fileID)
                        |> Maybe.map .code
                        |> Maybe.withDefault ""

                code =
                    case project of
                        Evaluate id ->
                            sync
                                |> Array.get id
                                |> Maybe.andThen (Array.get fileID)
                                |> Maybe.withDefault (local model.evaluate)

                        Highlight _ ->
                            local model.highlight
            in
            model
                |> Return.val
                |> Return.cmd (copyToClipboard code)


idOf : Code -> Int
idOf code =
    case code of
        Evaluate id ->
            id

        Highlight id ->
            id


{-| Handle the result of a run, special results are commands from the
evaluation script:

  - `LIA: wait` the program keeps running, results come in as log messages
  - `LIA: stop` the program has finished
  - `LIA: clear` clear the output
  - `LIA: terminal` the program reads input, show a terminal

-}
evaluated : Maybe Int -> Int -> Eval -> Model -> Return Model msg sub
evaluated sectionID id eval model =
    case eval.result of
        "LIA: wait" ->
            updateProject id (mapLog (always Log.empty)) model

        "LIA: stop" ->
            model
                |> onProject id
                    (\project ->
                        if project.syncMode then
                            Return.val (halt project)

                        else
                            halt project
                                |> withLog project.log
                                |> Return.val
                                |> Event.updateVersion id sectionID
                    )

        "LIA: clear" ->
            updateProject id
                (\project ->
                    if project.syncMode then
                        { project | syncLog = Log.empty }

                    else
                        withLog Log.empty project
                )
                model

        "LIA: terminal" ->
            model
                |> updateProject id
                    (\p ->
                        { p
                            | terminal =
                                p.file
                                    |> Array.get 0
                                    |> Maybe.map .lang
                                    |> Maybe.withDefault "sh"
                                    |> Terminal.init
                                    |> Just
                        }
                    )
                |> reveal id

        _ ->
            if isSyncModeActive id model then
                updateProject id (\p -> halt { p | syncLog = Log.add_Eval eval p.syncLog }) model

            else
                model
                    |> onProject id
                        (\project ->
                            halt project
                                |> withLog (Log.add_Eval eval project.log)
                                |> Return.val
                                |> Event.updateVersion id sectionID
                        )
                    |> reveal id


{-| Add a message of the running program. Unknown levels are ignored, in
`syncMode` they become info. The terminal is revealed on the first message
only, so it does not fight the user while a program keeps printing.
-}
logged : Int -> String -> String -> Model -> Return Model msg sub
logged id level message model =
    if isSyncModeActive id model then
        updateProject id
            (\p ->
                { p
                    | syncLog =
                        Log.add
                            (level
                                |> Log.fromString
                                |> Maybe.withDefault Log.Info
                            )
                            message
                            p.syncLog
                }
            )
            model

    else
        model
            |> updateProject id
                (\p ->
                    case Log.fromString level of
                        Just level_ ->
                            withLog (Log.add level_ message p.log) p

                        Nothing ->
                            p
                )
            |> (if Maybe.map (.log >> Log.isEmpty) (Array.get id model.evaluate) == Just True then
                    reveal id

                else
                    identity
               )


{-| Take over stored projects, or store the course's projects if nothing
was stored yet.
-}
restore : Maybe Int -> JE.Value -> Model -> Return Model msg sub
restore sectionID json model =
    case
        model.evaluate
            |> Array.map .attr
            |> Array.toList
            |> Json.toVector json
    of
        Ok (Just vector) ->
            Return.val (Json.merge model vector)

        Ok Nothing ->
            model
                |> Return.val
                |> Return.batchEvents
                    (if Array.isEmpty model.evaluate then
                        []

                     else
                        Event.store sectionID model.evaluate
                    )

        Err _ ->
            Return.val model


{-| Offer the original code to the classroom, if it has none for this
section yet.
-}
shareCodes : Array Sync -> Maybe Int -> Return Model msg sub -> Return Model msg sub
shareCodes sync sectionID return =
    if sectionID /= Nothing && Array.isEmpty sync then
        Return.batchEvent (Sync.codes (Array.map Sync_.sync return.value.evaluate)) return

    else
        return


{-| Send an event only if the project is in `syncMode`.
-}
whenSyncMode : Int -> Model -> Event -> Return Model msg sub -> Return Model msg sub
whenSyncMode id model event =
    if isSyncModeActive id model then
        Return.batchEvent event

    else
        identity


isSyncModeActive : Int -> Model -> Bool
isSyncModeActive id =
    .evaluate
        >> Array.get id
        >> Maybe.map .syncMode
        >> Maybe.withDefault False


{-| Scroll the terminal of a project into the visible area, if it is not already.
-}
reveal : Int -> Return Model msg sub -> Return Model msg sub
reveal id =
    Return.batchEvent (Service.Slide.reveal ("lia-code-terminal-" ++ String.fromInt id))


{-| Update an executable project, unknown ids change nothing.
-}
onProject : Int -> (Project -> Return Project msg sub) -> Model -> Return Model msg sub
onProject id fn model =
    case Array.get id model.evaluate of
        Just project ->
            Return.mapVal (\p -> { model | evaluate = Array.set id p model.evaluate }) (fn project)

        Nothing ->
            Return.val model


updateProject : Int -> (Project -> Project) -> Model -> Return Model msg sub
updateProject id fn model =
    Return.val { model | evaluate = Array.update id fn model.evaluate }


{-| Update a file of an executable project and attach the events for the
updated file.
-}
updateFile : Int -> Int -> (File -> File) -> (File -> List Event) -> Model -> Return Model msg sub
updateFile id fileID fn events model =
    case model.evaluate |> Array.get id |> Maybe.andThen (.file >> Array.get fileID) of
        Just file ->
            let
                new =
                    fn file
            in
            { model | evaluate = Array.update id (\p -> { p | file = Array.set fileID new p.file }) model.evaluate }
                |> Return.val
                |> Return.batchEvents (events new)

        Nothing ->
            Return.val model


mapFile : Int -> Int -> (File -> File) -> Vector -> Vector
mapFile id fileID fn =
    Array.update id (\p -> { p | file = Array.update fileID fn p.file })


toggleVisible : File -> File
toggleVisible file =
    { file | visible = not file.visible }


toggleFullscreen : File -> File
toggleFullscreen file =
    { file | fullscreen = not file.fullscreen }


{-| Mark as running and clear the output.
-}
startRun : Project -> Project
startRun project =
    { project | running = True }
        |> mapLog (always Log.empty)


{-| Append a new version if the code has changed since the last run.
-}
appendVersion : Maybe Int -> Int -> Return Project msg sub -> Return Project msg sub
appendVersion sectionID id return =
    case updateVersion return.value of
        Just ( project, repoUpdate ) ->
            case sectionID of
                Just section ->
                    { return | value = project }
                        |> Return.batchEvent (Event.updateAppend id project repoUpdate section)

                Nothing ->
                    { return | value = project }

        Nothing ->
            return


load : Maybe Int -> Int -> Int -> Model -> Return Model msg sub
load sectionID id version =
    onProject id (loadVersion version >> Return.val >> Event.updateActive id sectionID)


{-| Update the log of the editor that is shown, local or collaborative.
-}
mapLog : (Log -> Log) -> Project -> Project
mapLog fn project =
    if project.syncMode then
        { project | syncLog = fn project.syncLog }

    else
        { project | log = fn project.log }


{-| Set the log and store it in the active version too.
-}
withLog : Log -> Project -> Project
withLog log project =
    { project
        | version = Array.update project.version_active (Tuple.mapSecond (always log)) project.version
        , log = log
    }


halt : Project -> Project
halt project =
    { project | running = False, terminal = Nothing }
