module Lia.Code.Update exposing
    ( Msg(..)
    , default_replace
    , jsEventHandler
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Event as Event
import Lia.Code.Json exposing (decoder_result, json2event, vector2json)
import Lia.Code.Terminal as Terminal
import Lia.Code.Types exposing (..)
import Lia.Helper exposing (ID)
import Lia.Utils exposing (toJSstring)


type Msg
    = Eval ID
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


update : Msg -> Vector -> ( Vector, Maybe JE.Value )
update msg model =
    case msg of
        Eval idx ->
            model
                |> maybe_project idx (eval_ idx)
                |> Maybe.map (is_version_new model)
                |> maybe_update idx model []

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
                |> maybe_update idx model []

        First idx ->
            model
                |> maybe_project idx (load 0)
                |> Maybe.map (Event.load idx)
                |> maybe_update idx model []

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
                |> maybe_update idx model []

        Event "eval" ( _, idx, "LIA: wait", _ ) ->
            model
                |> maybe_project idx (\p -> { p | result = noResult })
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "eval" ( _, idx, "LIA: terminal", _ ) ->
            model
                |> maybe_project idx (\p -> { p | result = noResult, terminal = Just <| Terminal.init })
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "eval" ( _, idx, "LIA: stop", _ ) ->
            model
                |> maybe_project idx (\p -> { p | running = False, terminal = Nothing })
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "eval" ( ok, idx, message, details ) ->
            model
                |> maybe_project idx (set_result False (decoder_result ok message details))
                |> Maybe.map (Event.version_update idx)
                |> maybe_update idx model []

        Event "info" ( ok, idx, message, details ) ->
            model
                |> maybe_project idx (set_result True (decoder_result ok message details))
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "log" ( ok, idx, message, details ) ->
            model
                |> maybe_project idx (set_result True (decoder_result ok message details))
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "stdout" ( _, idx, message, _ ) ->
            model
                |> maybe_project idx (append2result message)
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event "stderr" ( _, idx, message, _ ) ->
            model
                |> maybe_project idx (append2result message)
                |> Maybe.map (\p -> ( p, [] ))
                |> maybe_update idx model []

        Event _ _ ->
            ( model, Nothing )

        UpdateTerminal idx childMsg ->
            model
                |> maybe_project idx (update_terminal (Event.stdin idx) childMsg)
                |> maybe_update idx model []



{- case Array.get idx model of
   Just project ->
       case project.terminal of
           Nothing ->
               ( model, Nothing )

           Just terminal ->
               let
                   ( new_terminal, stdin ) =
                       Terminal.update childMsg terminal
               in
               ( Array.set idx
                   { project
                       | terminal = Just new_terminal
                       , result =
                           case stdin of
                               Just str ->
                                   append2result str project.result

                               Nothing ->
                                   project.result
                   }
                   model
               , Event.stdin idx stdin
               )

   Nothing ->
       ( model, Nothing )
-}


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


update_terminal f msg project =
    case project.terminal |> Maybe.map (Terminal.update msg) of
        Just ( terminal, Nothing ) ->
            ( { project | terminal = Just terminal }
            , []
            )

        Just ( terminal, Just str ) ->
            ( append2result str { project | terminal = Just terminal }
            , [ f str ]
            )

        Nothing ->
            ( project, [] )


eval_ idx project =
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


update_and_eval : ID -> Vector -> Project -> String -> ( Vector, Maybe JE.Value )
update_and_eval idx model project code_0 =
    let
        eval_str =
            if Array.length project.file == 1 then
                project.evaluation
                    |> replace ( 0, code_0 )
                    |> default_replace code_0

            else
                project.file
                    |> Array.indexedMap (\i f -> ( i, f.code ))
                    |> Array.foldl replace project.evaluation
                    |> default_replace code_0
                    |> toJSstring
    in
    update_
        idx
        model
        [ Event.eval idx eval_str ]
        (\p -> { p | running = True })


update_ : ID -> Vector -> List JE.Value -> (Project -> Project) -> ( Vector, Maybe JE.Value )
update_ idx model event_logs f =
    case Array.get idx model of
        Just elem ->
            let
                new_model =
                    Array.set idx (f elem) model
            in
            ( new_model
            , event_logs
                |> (::) (Event.store new_model)
                |> JE.list
                |> Just
            )

        Nothing ->
            ( model, Nothing )



--model |> update_ idx f |> log ( ... ) |> Model.set


maybe_project idx f model =
    model
        |> Array.get idx
        |> Maybe.map f



--maybe_log : (Project -> ( Project, List JE.Value )) -> Maybe Project -> ( Maybe Project, List JE.Value )


maybe_update idx model logs project =
    case project of
        Just ( p, log ) ->
            let
                event_logs =
                    List.append logs log
            in
            ( Array.set idx p model
            , if event_logs == [] then
                Nothing

              else
                Just <| JE.list event_logs
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


is_version_new : Vector -> ( Project, List JE.Value ) -> ( Project, List JE.Value )
is_version_new model ( project, events ) =
    case ( project.version |> Array.get project.version_active, project.file |> Array.map .code ) of
        ( Just ( code, _ ), new_code ) ->
            if code /= new_code then
                ( { project
                    | version = Array.push ( new_code, noResult ) project.version
                    , version_active = Array.length project.version
                    , result = noResult
                  }
                , Event.store model :: events
                )

            else
                ( project, events )

        _ ->
            ( project, events )


resulting : Bool -> Result Log Log -> Project -> Project
resulting still_running result elem =
    let
        ( code, _ ) =
            elem.version
                |> Array.get elem.version_active
                |> Maybe.withDefault ( Array.empty, noResult )

        e =
            { elem
                | result = result
                , running = still_running
            }

        new_code =
            e.file |> Array.map .code
    in
    if code == new_code then
        { e
            | version = Array.set e.version_active ( code, result ) e.version
        }

    else
        { e
            | version = Array.push ( new_code, result ) e.version
            , version_active = Array.length e.version
        }


set_result : Bool -> Result Log Log -> Project -> Project
set_result continue result project =
    case project.version |> Array.get project.version_active of
        Just ( code, _ ) ->
            { project
                | version =
                    Array.set
                        project.version_active
                        ( code, result )
                        project.version
                , running = continue
                , result = result
            }

        Nothing ->
            project


load : Int -> Project -> Project
load idx project =
    case Array.get idx project.version of
        Just ( code, result ) ->
            { project
                | version_active = idx
                , file =
                    Array.indexedMap
                        (\i a -> { a | code = Array.get i code |> Maybe.withDefault a.code })
                        project.file
                , result = result
            }

        _ ->
            project


append2result : String -> Project -> Project
append2result str project =
    { project | result = message_update str project.result }
