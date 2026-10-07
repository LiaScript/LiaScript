port module Lia.Markdown.Code.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array exposing (Array)
import Helper.Array as Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Events as Event
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Sync as Sync_ exposing (Sync)
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model, Project, loadVersion, updateVersion)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Return exposing (Return)
import Service.Event as PEvent exposing (Event)
import Service.Script as Script exposing (Eval)
import Service.Slide
import Service.Sync as Sync


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


handle : Event -> Msg
handle =
    Handle


restore : Maybe Int -> JE.Value -> Model -> Return Model msg sub
restore sectionID json model =
    case
        model.evaluate
            |> Array.map .attr
            |> Array.toList
            |> Json.toVector json
    of
        Ok (Just vector) ->
            Json.merge model vector
                |> Return.val

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
            model
                |> Return.val


update : Array Sync -> Maybe Int -> Scripts a -> Msg -> Model -> Return Model msg sub
update sync sectionID scripts msg model =
    case msg of
        Eval idx ->
            execute sync sectionID scripts model idx

        Update id_1 id_2 code_str ->
            if isSyncModeActive id_1 model then
                Return.val model

            else
                update_file
                    id_1
                    id_2
                    model
                    (\f -> { f | code = code_str })
                    (\_ -> [])

        FlipView (Evaluate projectID) fileID ->
            flipEval sectionID model projectID fileID

        FlipView (Highlight projectID) fileID ->
            flipHigh model projectID fileID

        FlipFullscreen (Highlight id_1) id_2 ->
            { model
                | highlight =
                    Array.update id_1
                        (\pro ->
                            { pro
                                | file =
                                    Array.update id_2 (\f -> { f | fullscreen = not f.fullscreen }) pro.file
                            }
                        )
                        model.highlight
            }
                |> Return.val

        FlipFullscreen (Evaluate projectID) fileID ->
            update_file
                projectID
                fileID
                model
                (\f -> { f | fullscreen = not f.fullscreen })
                (Event.fullscreen sectionID projectID fileID)

        Load idx version ->
            load sectionID model idx version

        First idx ->
            load sectionID model idx 0

        Last projectID ->
            model.evaluate
                |> Array.get projectID
                |> Maybe.map (.version >> Array.length >> (+) -1)
                |> Maybe.withDefault 0
                |> load sectionID model projectID

        Handle event ->
            case PEvent.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    restore sectionID param model
                        |> doSync sync sectionID

                ( Just "project", id, ( "eval", param ) ) ->
                    let
                        e =
                            Script.decode param
                    in
                    case e.result of
                        "LIA: wait" ->
                            if isSyncModeActive id model then
                                updateProject id (\p -> { p | syncLog = Log.empty }) model

                            else
                                updateProject id (\p -> { p | log = Log.empty }) model

                        "LIA: stop" ->
                            model
                                |> maybe_project id stop
                                |> Maybe.map
                                    (if isSyncModeActive id model then
                                        identity

                                     else
                                        Event.updateVersion id sectionID
                                    )
                                |> maybe_update id model

                        "LIA: clear" ->
                            if isSyncModeActive id model then
                                updateProject id (\p -> { p | syncLog = Log.empty }) model

                            else
                                updateProject id clr model

                        -- preserve previous logging by setting ok to false
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
                                updateProject id ((\p -> { p | syncLog = Log.add_Eval e p.syncLog }) >> set_result e) model

                            else
                                model
                                    |> maybe_project id (set_result e)
                                    |> Maybe.map (Event.updateVersion id sectionID)
                                    |> maybe_update id model
                                    |> reveal id

                ( Just "project", id, ( "log", param ) ) ->
                    case JD.decodeValue (JD.list JD.string) param of
                        Ok [ log, message ] ->
                            if isSyncModeActive id model then
                                model
                                    |> updateProject id
                                        (\p ->
                                            { p
                                                | syncLog =
                                                    Log.add
                                                        (log
                                                            |> Log.fromString
                                                            |> Maybe.withDefault Log.Info
                                                        )
                                                        message
                                                        p.syncLog
                                            }
                                        )

                            else
                                model
                                    |> updateProject id (logger log message)
                                    -- only on the first message, to not fight the user while a program keeps printing
                                    |> (if Maybe.map (.log >> Log.isEmpty) (Array.get id model.evaluate) == Just True then
                                            reveal id

                                        else
                                            identity
                                       )

                        _ ->
                            Return.val model

                _ ->
                    Return.val model

        Stop id ->
            model
                |> maybe_project id halt
                |> Maybe.map (Return.batchEvent (Event.stop id))
                |> maybe_update id model

        Resize code height ->
            Return.val <|
                case code of
                    Evaluate id ->
                        { model | evaluate = onResize id height model.evaluate }

                    Highlight id ->
                        { model | highlight = onResize id height model.highlight }

        UpdateTerminal idx childMsg ->
            case
                model
                    |> maybe_project idx (update_terminal childMsg)
                    |> Maybe.map .value
            of
                Just ( project, Just str ) ->
                    if isSyncModeActive idx model then
                        { project | syncLog = Log.add Log.Info str project.syncLog }
                            |> Return.val
                            |> Return.batchEvent (Event.input idx str)
                            |> Just
                            |> maybe_update idx model

                    else
                        { project | log = Log.add Log.Info str project.log }
                            |> Return.val
                            |> Return.batchEvent (Event.input idx str)
                            |> Just
                            |> maybe_update idx model

                Just ( project, Nothing ) ->
                    project
                        |> Return.val
                        |> Just
                        |> maybe_update idx model

                Nothing ->
                    Return.val model

        ToggleSync id ->
            { model
                | evaluate =
                    Array.update id
                        (\pro -> { pro | syncMode = not pro.syncMode })
                        model.evaluate
            }
                |> Return.val

        Synchronize id1 id2 event ->
            model
                |> Return.val
                |> Return.batchEvent
                    (if isSyncModeActive id1 model then
                        Sync.code id1 id2 event

                     else
                        PEvent.none
                    )

        SynchronizeCursor id1 id2 position ->
            model
                |> Return.val
                |> Return.batchEvent
                    (if isSyncModeActive id1 model then
                        Sync.cursor id1 id2 position

                     else
                        PEvent.none
                    )

        CopyToClipboard project file ->
            let
                code =
                    case project of
                        Evaluate id ->
                            sync
                                |> Array.get id
                                |> Maybe.andThen (Array.get file)
                                |> Maybe.withDefault
                                    (model.evaluate
                                        |> Array.get id
                                        |> Maybe.map .file
                                        |> Maybe.andThen (Array.get file)
                                        |> Maybe.map .code
                                        |> Maybe.withDefault ""
                                    )

                        Highlight id ->
                            model.highlight
                                |> Array.get id
                                |> Maybe.map .file
                                |> Maybe.andThen (Array.get file)
                                |> Maybe.map .code
                                |> Maybe.withDefault ""
            in
            model
                |> Return.val
                |> Return.cmd (copyToClipboard code)


isSyncModeActive : Int -> Model -> Bool
isSyncModeActive id =
    .evaluate
        >> Array.get id
        >> Maybe.map .syncMode
        >> Maybe.withDefault False


doSync : Array Sync -> Maybe Int -> Return Model msg sub -> Return Model msg sub
doSync sync sectionID ret =
    case ( sectionID, Array.length sync ) of
        ( Just _, 0 ) ->
            ret
                |> Return.batchEvent
                    (ret.value
                        |> .evaluate
                        |> Array.map Sync_.sync
                        |> Sync.codes
                    )

        _ ->
            ret


onResize : Int -> String -> Array Project -> Array Project
onResize id height code =
    Array.update id
        (\pro -> { pro | logSize = Just height })
        code


update_terminal : Terminal.Msg -> Project -> ( Project, Maybe String )
update_terminal msg project =
    case project.terminal |> Maybe.map (Terminal.update msg) of
        Just ( terminal, log ) ->
            ( { project | terminal = Just terminal }, log )

        Nothing ->
            ( project, Nothing )


eval : Array Sync -> Int -> Scripts a -> Project -> Return Project msg sub
eval sync id scripts project =
    (if project.syncMode then
        { project | running = True, syncLog = Log.empty }

     else
        { project | running = True, log = Log.empty }
    )
        |> Return.val
        |> Return.batchEvent (Event.eval sync id scripts project)


maybe_project : Int -> (Project -> x) -> Model -> Maybe (Return x cmd sub)
maybe_project idx f =
    .evaluate
        >> Array.get idx
        >> Maybe.map (f >> Return.val)


{-| Scroll the terminal of a project into the visible area, if it is not already.
-}
reveal : Int -> Return Model msg sub -> Return Model msg sub
reveal id =
    Return.batchEvent (Service.Slide.reveal ("lia-code-terminal-" ++ String.fromInt id))


maybe_update : Int -> Model -> Maybe (Return Project msg sub) -> Return Model msg sub
maybe_update idx model =
    Maybe.map (Return.mapVal (\v -> { model | evaluate = Array.set idx v model.evaluate }))
        >> Maybe.withDefault (Return.val model)


updateProject : Int -> (Project -> Project) -> Model -> Return Model msg sub
updateProject idx f model =
    Return.val { model | evaluate = Array.update idx f model.evaluate }


update_file : Int -> Int -> Model -> (File -> File) -> (File -> List Event) -> Return Model msg sub
update_file id_1 id_2 model f f_log =
    case
        model.evaluate
            |> Array.get id_1
            |> Maybe.andThen (.file >> Array.get id_2)
            |> Maybe.map f
    of
        Just file ->
            { model | evaluate = Array.update id_1 (\project -> { project | file = Array.set id_2 file project.file }) model.evaluate }
                |> Return.val
                |> Return.batchEvents (f_log file)

        Nothing ->
            Return.val model


is_version_new : Maybe Int -> Int -> Return Project msg sub -> Return Project msg sub
is_version_new sectionID idx return =
    case ( sectionID, updateVersion return.value ) of
        ( Just sectionID_, Just ( new_project, repo_update ) ) ->
            new_project
                |> Return.replace return
                |> Return.batchEvent (Event.updateAppend idx new_project repo_update sectionID_)

        ( Nothing, Just ( new_project, _ ) ) ->
            Return.replace return new_project

        _ ->
            return


withLog : Log.Log -> Project -> Project
withLog log project =
    { project
        | version =
            Array.update
                project.version_active
                (Tuple.mapSecond (always log))
                project.version
        , log = log
    }


halt : Project -> Project
halt project =
    { project | running = False, terminal = Nothing }


stop : Project -> Project
stop project =
    if project.syncMode then
        halt project

    else
        withLog project.log (halt project)


set_result : Eval -> Project -> Project
set_result e project =
    if project.syncMode then
        halt project

    else
        withLog (Log.add_Eval e project.log) (halt project)


clr : Project -> Project
clr =
    withLog Log.empty


logger : String -> String -> Project -> Project
logger level message project =
    case Log.fromString level of
        Just level_ ->
            withLog (Log.add level_ message project.log) project

        Nothing ->
            project


flipEval : Maybe Int -> Model -> Int -> Int -> Return Model msg sub
flipEval sectionID model projectID fileID =
    update_file
        projectID
        fileID
        model
        (\f -> { f | visible = not f.visible })
        (Event.flip_view sectionID projectID fileID)


flipHigh : Model -> Int -> Int -> Return Model msg sub
flipHigh model id_1 id_2 =
    { model
        | highlight =
            Array.update id_1
                (\pro ->
                    { pro
                        | file =
                            Array.update id_2 (\f -> { f | visible = not f.visible }) pro.file
                    }
                )
                model.highlight
    }
        |> Return.val


execute : Array Sync -> Maybe Int -> Scripts a -> Model -> Int -> Return Model msg sub
execute sync sectionID scripts model id =
    model
        |> maybe_project id (eval sync id scripts)
        |> Maybe.map (.value >> is_version_new sectionID id)
        |> maybe_update id model


load : Maybe Int -> Model -> Int -> Int -> Return Model msg sub
load sectionID model id version =
    model
        |> maybe_project id (loadVersion version)
        |> Maybe.map (Event.updateActive id sectionID)
        |> maybe_update id model
