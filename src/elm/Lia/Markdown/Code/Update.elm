module Lia.Markdown.Code.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array exposing (Array)
import Conditional.Array as CArray
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Code.Events as Event
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (Code(..), File, Model, Project, loadVersion, updateVersion)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Return exposing (Return)
import Service.Event as PEvent exposing (Event)
import Service.Script as Script exposing (Eval)


type Msg
    = Eval Int
    | Stop Int
    | Update Int Int String
    | FlipView Code Int
    | FlipFullscreen Code Int
    | Load Int Int
    | First Int
    | Last Int
    | UpdateTerminal Int Terminal.Msg
    | Handle Event
    | Resize Code String


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
                    (if Array.length model.evaluate == 0 then
                        []

                     else
                        Event.store sectionID model.evaluate
                    )

        Err _ ->
            model
                |> Return.val


update : Maybe Int -> Scripts a -> Msg -> Model -> Return Model msg sub
update sectionID scripts msg model =
    case msg of
        Eval idx ->
            execute sectionID scripts model idx

        --|> Return.sync (PEvent.initWithId "eval" idx JE.null)
        Update id_1 id_2 code_str ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | code = code_str })
                (\_ -> [])

        --|> Return.sync
        --    ([ ( "id", JE.int id_2 )
        --     , ( "code", JE.string code_str )
        --     ]
        --        |> JE.object
        --        |> PEvent.initWithId "update" id_1
        --    )
        FlipView (Evaluate projectID) fileID ->
            flipEval sectionID model projectID fileID

        --|> Return.sync (PEvent.initWithId "flip_eval" id_1 (JE.int id_2))
        FlipView (Highlight projectID) fileID ->
            flipHigh model projectID fileID

        --|> Return.sync (PEvent.initWithId "flip_high" id_1 (JE.int id_2))
        FlipFullscreen (Highlight id_1) id_2 ->
            { model
                | highlight =
                    CArray.setWhen id_1
                        (model.highlight
                            |> Array.get id_1
                            |> Maybe.map
                                (\pro ->
                                    { pro
                                        | file =
                                            updateArray (\f -> { f | fullscreen = not f.fullscreen }) id_2 pro.file
                                    }
                                )
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

        --|> Return.sync (PEvent.initWithId "load" idx (JE.int version))
        First idx ->
            load sectionID model idx 0

        --|> Return.sync (PEvent.initWithId "load" idx (JE.int 0))
        Last projectID ->
            let
                version =
                    model
                        |> maybe_project projectID (.version >> Array.length >> (+) -1)
                        |> Maybe.map .value
                        |> Maybe.withDefault 0
            in
            load sectionID model projectID version

        Handle event ->
            case PEvent.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    restore sectionID param model

                ( Just "project", id, ( "eval", param ) ) ->
                    let
                        e =
                            Script.decode param
                    in
                    case e.result of
                        "LIA: wait" ->
                            model
                                |> maybe_project id (\p -> { p | log = Log.empty })
                                |> maybe_update id model

                        "LIA: stop" ->
                            model
                                |> maybe_project id stop
                                |> Maybe.map2 (Event.updateVersion id) sectionID
                                |> maybe_update id model

                        "LIA: clear" ->
                            model
                                |> maybe_project id clr
                                |> maybe_update id model

                        -- preserve previous logging by setting ok to false
                        "LIA: terminal" ->
                            model
                                |> maybe_project id (\p -> { p | terminal = Just <| Terminal.init })
                                |> maybe_update id model

                        _ ->
                            model
                                |> maybe_project id (set_result False e)
                                |> Maybe.map2 (Event.updateVersion id) sectionID
                                |> maybe_update id model

                ( Just "project", id, ( "log", param ) ) ->
                    case JD.decodeValue (JD.list JD.string) param of
                        Ok [ log, message ] ->
                            model
                                |> maybe_project id (logger log message)
                                |> maybe_update id model

                        _ ->
                            Return.val model

                _ ->
                    Return.val model

        -- TODO:
        -- case PEvent.destructure eval of
        --     {- Just ( "sync", _, message ) ->
        --        case PEvent.topicWithId event of
        --            Just ( "flip_eval", Just id ) ->
        --                message
        --                    |> JD.decodeValue JD.int
        --                    |> Result.map (flipEval model id)
        --                    |> Result.withDefault (Return.val model)
        --            Just ( "flip_high", Just id ) ->
        --                message
        --                    |> JD.decodeValue JD.int
        --                    |> Result.map (flipHigh model id)
        --                    |> Result.withDefault (Return.val model)
        --            Just ( "eval", Just id ) ->
        --                execute scripts model id
        --            Just ( "update", Just id_1 ) ->
        --                case
        --                    JD.decodeValue
        --                        (JD.map2 Tuple.pair
        --                            (JD.field "id" JD.int)
        --                            (JD.field "code" JD.string)
        --                        )
        --                        message
        --                of
        --                    Ok ( id_2, code ) ->
        --                        update_file
        --                            id_1
        --                            id_2
        --                            model
        --                            (\f -> { f | code = code })
        --                            (\_ -> [])
        --                    _ ->
        --                        Return.val model
        --            Just ( "load", Just id ) ->
        --                message
        --                    |> JD.decodeValue JD.int
        --                    |> Result.map (load model id)
        --                    |> Result.withDefault (Return.val model)
        --            _ ->
        --                Return.val model
        --     -}
        --     _ ->
        Stop idx ->
            model
                |> maybe_project idx (\p -> { p | running = False, terminal = Nothing })
                |> Maybe.map (Return.batchEvent (Event.stop idx))
                |> maybe_update idx model

        Resize code height ->
            Return.val <|
                case code of
                    Evaluate id ->
                        { model | evaluate = onResize id height model.evaluate }

                    Highlight id ->
                        { model | highlight = onResize id height model.highlight }

        UpdateTerminal idx childMsg ->
            model
                |> maybe_project idx (update_terminal (Event.input idx) childMsg)
                |> Maybe.map .value
                |> maybe_update idx model


onResize : Int -> String -> Array Project -> Array Project
onResize id height code =
    CArray.setWhen id
        (code
            |> Array.get id
            |> Maybe.map (\pro -> { pro | logSize = Just height })
        )
        code


update_terminal : (String -> Event) -> Terminal.Msg -> Project -> Return Project msg sub
update_terminal f msg project =
    case project.terminal |> Maybe.map (Terminal.update msg) of
        Just ( terminal, Nothing ) ->
            { project | terminal = Just terminal }
                |> Return.val

        Just ( terminal, Just str ) ->
            { project | terminal = Just terminal, log = Log.add Log.Info str project.log }
                |> Return.val
                |> Return.batchEvent (f str)

        Nothing ->
            Return.val project


eval : Int -> Scripts a -> Project -> Return Project msg sub
eval id scripts project =
    { project | running = True }
        |> Return.val
        |> Return.batchEvent (Event.eval id scripts project)


maybe_project : Int -> (Project -> x) -> Model -> Maybe (Return x cmd sub)
maybe_project idx f =
    .evaluate
        >> Array.get idx
        >> Maybe.map (f >> Return.val)


maybe_update : Int -> Model -> Maybe (Return Project msg sub) -> Return Model msg sub
maybe_update idx model =
    Maybe.map (Return.mapVal (\v -> { model | evaluate = Array.set idx v model.evaluate }))
        >> Maybe.withDefault (Return.val model)


update_file : Int -> Int -> Model -> (File -> File) -> (File -> List Event) -> Return Model msg sub
update_file id_1 id_2 model f f_log =
    case Array.get id_1 model.evaluate of
        Just project ->
            case
                project.file
                    |> Array.get id_2
                    |> Maybe.map f
            of
                Just file ->
                    { model
                        | evaluate =
                            Array.set id_1
                                { project
                                    | file = Array.set id_2 file project.file
                                }
                                model.evaluate
                    }
                        |> Return.val
                        |> Return.batchEvents (f_log file)

                Nothing ->
                    Return.val model

        Nothing ->
            Return.val model


is_version_new : Maybe Int -> Int -> Return Project msg sub -> Return Project msg sub
is_version_new sectionID idx return =
    case ( sectionID, updateVersion return.value ) of
        ( Just sectionID_, Just ( new_project, repo_update ) ) ->
            new_project
                |> Return.replace return
                |> Return.batchEvent (Event.updateAppend idx new_project repo_update sectionID_)

        _ ->
            return


stop : Project -> Project
stop project =
    case project.version |> Array.get project.version_active of
        Just ( code, _ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, project.log )
                        project.version
                , running = False
                , terminal = Nothing
            }

        Nothing ->
            project


set_result : Bool -> Eval -> Project -> Project
set_result continue e project =
    case project.version |> Array.get project.version_active of
        Just ( code, _ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, Log.add_Eval e project.log )
                        project.version
                , running =
                    if continue then
                        project.running

                    else
                        False
                , log =
                    Log.add_Eval e project.log
            }

        Nothing ->
            project


clr : Project -> Project
clr project =
    case project.version |> Array.get project.version_active of
        Just ( code, _ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, Log.empty )
                        project.version
                , log = Log.empty
            }

        Nothing ->
            project


logger : String -> String -> Project -> Project
logger level message project =
    case
        ( project.version
            |> Array.get project.version_active
            |> Maybe.map Tuple.first
        , Log.fromString level
        )
    of
        ( Just code, Just level_ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, Log.add level_ message project.log )
                        project.version
                , log = Log.add level_ message project.log
            }

        _ ->
            project


updateArray : (e -> e) -> Int -> Array e -> Array e
updateArray fn i array =
    CArray.setWhen i
        (array
            |> Array.get i
            |> Maybe.map fn
        )
        array


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
            CArray.setWhen id_1
                (model.highlight
                    |> Array.get id_1
                    |> Maybe.map
                        (\pro ->
                            { pro
                                | file =
                                    updateArray (\f -> { f | visible = not f.visible }) id_2 pro.file
                            }
                        )
                )
                model.highlight
    }
        |> Return.val


execute : Maybe Int -> Scripts a -> Model -> Int -> Return Model msg sub
execute sectionID scripts model id =
    model
        |> maybe_project id (eval id scripts)
        |> Maybe.map (.value >> is_version_new sectionID id)
        |> maybe_update id model


load : Maybe Int -> Model -> Int -> Int -> Return Model msg sub
load sectionID model id version =
    model
        |> maybe_project id (loadVersion version)
        |> Maybe.map2 (Event.updateActive id) sectionID
        |> maybe_update id model
