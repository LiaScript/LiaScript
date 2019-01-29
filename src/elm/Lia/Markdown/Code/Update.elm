module Lia.Markdown.Code.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Code.Events as Eve
import Lia.Markdown.Code.Json as Json
import Lia.Markdown.Code.Terminal as Terminal
import Lia.Markdown.Code.Types exposing (..)


type Msg
    = Eval Int
    | Stop Int
    | Update Int Int String
    | FlipView Int Int
    | FlipFullscreen Int Int
    | Load Int Int
    | First Int
    | Last Int
    | UpdateTerminal Int Terminal.Msg
    | Handle Event


handle : Event -> Msg
handle =
    Handle


restore : JE.Value -> Vector -> ( Vector, List Event )
restore json model =
    case Json.toVector json of
        Ok (Just model_) ->
            ( Json.merge model model_, [] )

        Ok Nothing ->
            ( model
            , if Array.length model == 0 then
                []

              else
                [ Event.store <| Json.fromVector model ]
            )

        Err msg ->
            let
                debug =
                    Debug.log "Error: restoring code-vector" msg
            in
            ( model, [] )


update : Msg -> Vector -> ( Vector, List Event )
update msg model =
    case msg of
        Eval idx ->
            model
                |> maybe_project idx (eval idx)
                |> Maybe.map (is_version_new idx)
                |> maybe_update idx model

        Update id_1 id_2 code_str ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | code = code_str })
                (\_ -> [])

        FlipView id_1 id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | visible = not f.visible })
                (.visible >> Eve.flip_view id_1 id_2 >> List.singleton)

        FlipFullscreen id_1 id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | fullscreen = not f.fullscreen })
                (.fullscreen >> Eve.fullscreen id_1 id_2 >> List.singleton)

        Load idx version ->
            model
                |> maybe_project idx (load version)
                |> Maybe.map (Eve.load idx)
                |> maybe_update idx model

        First idx ->
            model
                |> maybe_project idx (load 0)
                |> Maybe.map (Eve.load idx)
                |> maybe_update idx model

        Last idx ->
            let
                version =
                    model
                        |> maybe_project idx (.version >> Array.length >> (+) -1)
                        |> Maybe.withDefault 0
            in
            model
                |> maybe_project idx (load version)
                |> Maybe.map (Eve.load idx)
                |> maybe_update idx model

        Handle event ->
            case event.topic of
                "eval" ->
                    let
                        e =
                            Event.evalDecode event.message
                    in
                    case e.result of
                        "LIA: wait" ->
                            model
                                |> maybe_project event.section (\p -> { p | log = noLog })
                                |> Maybe.map (\p -> ( p, [] ))
                                |> maybe_update event.section model

                        "LIA: stop" ->
                            model
                                |> maybe_project event.section stop
                                |> Maybe.map (Eve.version_update event.section)
                                |> maybe_update event.section model

                        -- preserve previous logging by setting ok to false
                        "LIA: terminal" ->
                            model
                                |> maybe_project event.section
                                    (\p ->
                                        { p
                                            | terminal = Just <| Terminal.init
                                            , log =
                                                if e.ok then
                                                    noLog

                                                else
                                                    p.log
                                        }
                                    )
                                |> Maybe.map (\p -> ( p, [] ))
                                |> maybe_update event.section model

                        _ ->
                            model
                                |> maybe_project event.section (set_result False e)
                                |> Maybe.map (Eve.version_update event.section)
                                |> maybe_update event.section model

                "restore" ->
                    restore event.message model

                "log" ->
                    model
                        |> maybe_project event.section (set_result True (Event.evalDecode event.message))
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "output" ->
                    model
                        |> maybe_project event.section (append2log <| .result <| Event.evalDecode event.message)
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                "clr" ->
                    model
                        |> maybe_project event.section clr
                        |> Maybe.map (\p -> ( p, [] ))
                        |> maybe_update event.section model

                _ ->
                    ( model, [] )

        Stop idx ->
            model
                |> maybe_project idx (\p -> { p | running = False, terminal = Nothing })
                |> Maybe.map (\p -> ( p, [ Eve.stop idx ] ))
                |> maybe_update idx model

        UpdateTerminal idx childMsg ->
            model
                |> maybe_project idx (update_terminal (Eve.input idx) childMsg)
                |> maybe_update idx model


update_terminal : (String -> Event) -> Terminal.Msg -> Project -> ( Project, List Event )
update_terminal f msg project =
    case project.terminal |> Maybe.map (Terminal.update msg) of
        Just ( terminal, Nothing ) ->
            ( { project | terminal = Just terminal }
            , []
            )

        Just ( terminal, Just str ) ->
            ( append2log str { project | terminal = Just terminal }
            , [ f str ]
            )

        Nothing ->
            ( project, [] )


eval : Int -> Project -> ( Project, List Event )
eval idx project =
    ( { project | running = True }
    , [ project.file
            |> Array.map .code
            |> Array.toList
            |> Event.eval idx project.evaluation
      ]
    )


maybe_project : Int -> (a -> b) -> Array a -> Maybe b
maybe_project idx f model =
    model
        |> Array.get idx
        |> Maybe.map f


maybe_update : Int -> Vector -> Maybe ( Project, List Event ) -> ( Vector, List Event )
maybe_update idx model project =
    case project of
        Just ( p, logs ) ->
            ( Array.set idx p model
            , if logs == [] then
                []

              else
                logs
            )

        _ ->
            ( model, [] )


update_file : Int -> Int -> Vector -> (File -> File) -> (File -> List Event) -> ( Vector, List Event )
update_file id_1 id_2 model f f_log =
    case Array.get id_1 model of
        Just project ->
            case project.file |> Array.get id_2 |> Maybe.map f of
                Just file ->
                    ( Array.set id_1
                        { project
                            | file = Array.set id_2 file project.file
                        }
                        model
                    , f_log file
                    )

                Nothing ->
                    ( model, [] )

        Nothing ->
            ( model, [] )


is_version_new : Int -> ( Project, List Event ) -> ( Project, List Event )
is_version_new idx ( project, events ) =
    case ( project.version |> Array.get project.version_active, project.file |> Array.map .code ) of
        ( Just ( code, _ ), new_code ) ->
            if code /= new_code then
                let
                    new_project =
                        { project
                            | version = Array.push ( new_code, noLog ) project.version
                            , version_active = Array.length project.version
                            , log = noLog
                        }
                in
                ( new_project
                , Eve.version_append idx new_project :: events
                )

            else
                ( project, events )

        ( Nothing, _ ) ->
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


set_result : Bool -> Event.Eval -> Project -> Project
set_result continue log project =
    case project.version |> Array.get project.version_active of
        Just ( code, _ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, log )
                        project.version
                , running = continue
                , log =
                    if continue then
                        log_append project.log log

                    else
                        log
            }

        Nothing ->
            project


clr : Project -> Project
clr project =
    case project.version |> Array.get project.version_active of
        Just ( code, log ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, { log | result = "" } )
                        project.version
                , log = { log | result = "" }
            }

        Nothing ->
            project


load : Int -> Project -> Project
load idx project =
    case Array.get idx project.version of
        Just ( code, log ) ->
            { project
                | version_active = idx
                , file =
                    Array.indexedMap
                        (\i a -> { a | code = Array.get i code |> Maybe.withDefault a.code })
                        project.file
                , log = log
            }

        _ ->
            project


append2log : String -> Project -> Project
append2log str project =
    { project | log = message_append str project.log }
