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
import Port.Eval exposing (Eval)
import Port.Event exposing (Event)
import Return exposing (Return)


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


restore : JE.Value -> Model -> Return Model Never sub
restore json model =
    case
        model.evaluate
            |> Array.map .attr
            |> Array.toList
            |> Json.toVector json
    of
        Ok (Just vector) ->
            Json.merge model vector
                |> Return.value

        Ok Nothing ->
            model
                |> Return.value
                |> Return.events
                    (if Array.length model.evaluate == 0 then
                        []

                     else
                        [ Event.store model.evaluate ]
                    )

        Err _ ->
            model
                |> Return.value


update : Scripts sub -> Msg -> Model -> Return Model Never sub
update scripts msg model =
    case msg of
        Eval idx ->
            model
                |> maybe_project idx (eval scripts idx)
                |> Maybe.map (is_version_new idx)
                |> maybe_update idx model

        Update id_1 id_2 code_str ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | code = code_str })
                (\_ -> [])

        FlipView (Evaluate id_1) id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | visible = not f.visible })
                (Event.flip_view id_1 id_2)

        FlipView (Highlight id_1) id_2 ->
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
                |> Return.value

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
                |> Return.value

        FlipFullscreen (Evaluate id_1) id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | fullscreen = not f.fullscreen })
                (Event.fullscreen id_1 id_2)

        Load idx version ->
            model
                |> maybe_project idx (loadVersion version)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model

        First idx ->
            model
                |> maybe_project idx (loadVersion 0)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model

        Last idx ->
            let
                version =
                    model
                        |> maybe_project idx (.version >> Array.length >> (+) -1)
                        |> Maybe.withDefault 0
            in
            model
                |> maybe_project idx (loadVersion version)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model

        Handle event ->
            case event.topic of
                "eval" ->
                    let
                        e =
                            Event.evalDecode event
                    in
                    case e.result of
                        "LIA: wait" ->
                            model
                                |> maybe_project event.section (\p -> { p | log = Log.empty })
                                |> Maybe.map (\p -> ( p, [] ))
                                |> maybe_update event.section model

                        "LIA: stop" ->
                            model
                                |> maybe_project event.section stop
                                |> Maybe.map (Event.version_update event.section)
                                |> maybe_update event.section model

                        "LIA: clear" ->
                            model
                                |> maybe_project event.section clr
                                |> Maybe.map (\p -> ( p, [] ))
                                |> maybe_update event.section model

                        -- preserve previous logging by setting ok to false
                        "LIA: terminal" ->
                            model
                                |> maybe_project event.section (\p -> { p | terminal = Just <| Terminal.init })
                                |> Maybe.map (\p -> ( p, [] ))
                                |> maybe_update event.section model

                        _ ->
                            model
                                |> maybe_project event.section (set_result False e)
                                |> Maybe.map (Event.version_update event.section)
                                |> maybe_update event.section model

                "restore" ->
                    restore event.message model

                "debug" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.Debug event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "info" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.Info event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "warn" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.Warn event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "error" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.Error event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "html" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.HTML event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "stream" ->
                    model
                        |> maybe_project event.section (logger Log.add Log.Stream event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                _ ->
                    Return.value model

        Stop idx ->
            model
                |> maybe_project idx (\p -> { p | running = False, terminal = Nothing })
                |> Maybe.map (\p -> ( p, Event.stop idx ))
                |> maybe_update idx model

        Resize code height ->
            Return.value <|
                case code of
                    Evaluate id ->
                        { model | evaluate = onResize id height model.evaluate }

                    Highlight id ->
                        { model | highlight = onResize id height model.highlight }

        UpdateTerminal idx childMsg ->
            model
                |> maybe_project idx (update_terminal (Event.input idx) childMsg)
                |> maybe_update idx model


onResize : Int -> String -> Array Project -> Array Project
onResize id height code =
    CArray.setWhen id
        (code
            |> Array.get id
            |> Maybe.map (\pro -> { pro | logSize = Just height })
        )
        code


update_terminal : (String -> Event) -> Terminal.Msg -> Project -> ( Project, List Event )
update_terminal f msg project =
    case project.terminal |> Maybe.map (Terminal.update msg) of
        Just ( terminal, Nothing ) ->
            ( { project | terminal = Just terminal }
            , []
            )

        Just ( terminal, Just str ) ->
            ( { project | terminal = Just terminal, log = Log.add Log.Info str project.log }
            , [ f str ]
            )

        Nothing ->
            ( project, [] )


eval : Scripts a -> Int -> Project -> ( Project, List Event )
eval scripts idx project =
    ( { project | running = True }, Event.eval scripts idx project )


maybe_project : Int -> (a -> b) -> { project | evaluate : Array a } -> Maybe b
maybe_project idx f =
    .evaluate
        >> Array.get idx
        >> Maybe.map f


maybe_update : Int -> Model -> Maybe ( Project, List Event ) -> Return Model Never sub
maybe_update idx model project =
    case project of
        Just ( p, logs ) ->
            { model | evaluate = Array.set idx p model.evaluate }
                |> Return.value
                |> Return.events logs

        _ ->
            Return.value model


update_file : Int -> Int -> Model -> (File -> File) -> (File -> List Event) -> Return Model Never sub
update_file id_1 id_2 model f f_log =
    case Array.get id_1 model.evaluate of
        Just project ->
            case project.file |> Array.get id_2 |> Maybe.map f of
                Just file ->
                    { model
                        | evaluate =
                            Array.set id_1
                                { project
                                    | file = Array.set id_2 file project.file
                                }
                                model.evaluate
                    }
                        |> Return.value
                        |> Return.events (f_log file)

                Nothing ->
                    Return.value model

        Nothing ->
            Return.value model


is_version_new : Int -> ( Project, List Event ) -> ( Project, List Event )
is_version_new idx ( project, events ) =
    case updateVersion project of
        Just ( new_project, repo_update ) ->
            ( new_project
            , Event.version_append idx new_project repo_update :: events
            )

        Nothing ->
            ( project, events )


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


logger : (Log.Level -> String -> Log.Log -> Log.Log) -> Log.Level -> JD.Value -> Project -> Project
logger fn level event_str project =
    case ( project.version |> Array.get project.version_active, JD.decodeValue JD.string event_str ) of
        ( Just ( code, _ ), Ok str ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, fn level str project.log )
                        project.version
                , log = fn level str project.log
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
