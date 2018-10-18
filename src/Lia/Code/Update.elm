module Lia.Code.Update exposing
    ( Msg(..)
    , default_replace
    , jsEventHandler
    , restore
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Event as Event
import Lia.Code.Json exposing (json2details, json2event, json2vector, merge, vector2json)
import Lia.Code.Terminal as Terminal
import Lia.Code.Types exposing (..)
import Lia.Helper exposing (ID)
import Lia.Utils exposing (toJSstring)


type Msg
    = Eval ID
    | Stop ID
    | Update ID ID String
    | FlipView ID ID
    | FlipFullscreen ID ID
    | Event String ( Bool, Int, String, JD.Value )
    | Load ID Int
    | First ID
    | Last ID
    | UpdateTerminal ID Terminal.Msg


jsEventHandler : String -> JE.Value -> Vector -> ( Vector, Maybe JE.Value )
jsEventHandler topic json =
    case json |> json2event of
        Ok event ->
            update (Event topic event)

        Err msg ->
            let
                debug =
                    Debug.log "error: " msg
            in
            update (Event "" ( False, -1, "", JE.null ))


restore : JE.Value -> Vector -> ( Vector, Maybe JE.Value )
restore json model =
    case json2vector json of
        Ok (Just model_) ->
            ( merge model model_, Nothing )

        Ok Nothing ->
            ( model
            , if Array.length model == 0 then
                Nothing

              else
                Just <| Event.store model
            )

        Err msg ->
            let
                debug =
                    Debug.log "Error: restoring code-vector" msg
            in
            ( model, Nothing )


update : Msg -> Vector -> ( Vector, Maybe JE.Value )
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
                (\_ -> Nothing)

        FlipView id_1 id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | visible = not f.visible })
                (.visible >> Event.flip_view id_1 id_2 >> Just)

        FlipFullscreen id_1 id_2 ->
            update_file
                id_1
                id_2
                model
                (\f -> { f | fullscreen = not f.fullscreen })
                (.fullscreen >> Event.fullscreen id_1 id_2 >> Just)

        Load idx version ->
            model
                |> maybe_project idx (load version)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model

        First idx ->
            model
                |> maybe_project idx (load 0)
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
                |> maybe_project idx (load version)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model

        Event "eval" ( _, idx, "LIA: wait", _ ) ->
            model
                |> maybe_project idx (\p -> { p | log = noLog })
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model

        Event "eval" ( _, idx, "LIA: stop", _ ) ->
            model
                |> maybe_project idx stop
                |> Maybe.map (Event.version_update idx)
                |> maybe_update idx model

        -- preserve previous logging by setting ok to false
        Event "eval" ( ok, idx, "LIA: terminal", _ ) ->
            model
                |> maybe_project idx
                    (\p ->
                        { p
                            | terminal = Just <| Terminal.init
                            , log =
                                if ok then
                                    noLog

                                else
                                    p.log
                        }
                    )
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model

        Event "eval" ( ok, idx, message, details ) ->
            model
                |> maybe_project idx (set_result False (toLog ok message details))
                |> Maybe.map (Event.version_update idx)
                |> maybe_update idx model

        Event "log" ( ok, idx, message, details ) ->
            model
                |> maybe_project idx (set_result True (toLog ok message details))
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model

        Event "output" ( _, idx, message, _ ) ->
            model
                |> maybe_project idx (append2log message)
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model

        Event "clr" ( _, idx, _, _ ) ->
            model
                |> maybe_project idx clr
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model

        Event _ _ ->
            ( model, Nothing )

        Stop idx ->
            model
                |> maybe_project idx (\p -> { p | running = False, terminal = Nothing })
                |> Maybe.map (\p -> ( p, [ Event.stop idx ] ))
                |> maybe_update idx model

        UpdateTerminal idx childMsg ->
            model
                |> maybe_project idx (update_terminal (Event.input idx) childMsg)
                |> maybe_update idx model


toLog : Bool -> String -> JD.Value -> Log
toLog ok message details =
    details
        |> json2details
        |> Log ok message


replace : ( Int, String ) -> String -> String
replace ( int, insert ) into =
    into
        |> String.split ("@input(" ++ toString int ++ ")")
        |> String.join insert


default_replace : String -> String -> String
default_replace insert into =
    into
        |> String.split "@input"
        |> String.join insert


update_terminal : (String -> JE.Value) -> Terminal.Msg -> Project -> ( Project, List JE.Value )
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


eval : Int -> Project -> ( Project, List JE.Value )
eval idx project =
    let
        code_0 =
            project.file
                |> Array.get 0
                |> Maybe.map .code
                |> Maybe.withDefault ""

        eval_str =
            toJSstring <|
                default_replace code_0 <|
                    if Array.length project.file == 1 then
                        project.evaluation
                            |> replace ( 0, code_0 )

                    else
                        project.file
                            |> Array.indexedMap (\i f -> ( i, f.code ))
                            |> Array.foldl replace project.evaluation
    in
    ( { project | running = True }, [ Event.eval idx eval_str ] )


maybe_project : Int -> (a -> b) -> Array a -> Maybe b
maybe_project idx f model =
    model
        |> Array.get idx
        |> Maybe.map f


maybe_update : Int -> Vector -> Maybe ( Project, List JE.Value ) -> ( Vector, Maybe JE.Value )
maybe_update idx model project =
    case project of
        Just ( p, logs ) ->
            ( Array.set idx p model
            , if logs == [] then
                Nothing

              else
                Just <| JE.list logs
            )

        _ ->
            ( model, Nothing )


update_file : ID -> ID -> Vector -> (File -> File) -> (File -> Maybe JE.Value) -> ( Vector, Maybe JE.Value )
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
                    ( model, Nothing )

        Nothing ->
            ( model, Nothing )


is_version_new : Int -> ( Project, List JE.Value ) -> ( Project, List JE.Value )
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
                , Event.version_append idx new_project :: events
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


set_result : Bool -> Log -> Project -> Project
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
                        ( code, { log | message = "" } )
                        project.version
                , log = { log | message = "" }
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
