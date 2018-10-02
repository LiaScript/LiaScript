module Lia.Code.Update exposing
    ( Msg(..)
    , default_replace
    , jsEventHandler
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Code.Json exposing (decoder_result, json2event, vector2json)
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
            case Array.get idx model of
                Just project ->
                    project.file
                        |> Array.get 0
                        |> Maybe.map .code
                        |> Maybe.withDefault ""
                        |> update_and_eval idx model project

                Nothing ->
                    ( model, Nothing )

        Update id_1 id_2 code_str ->
            update_file id_1 id_2 model (\f -> { f | code = code_str })

        FlipView id_1 id_2 ->
            update_file id_1 id_2 model (\f -> { f | visible = not f.visible })

        FlipFullscreen id_1 id_2 ->
            update_file id_1 id_2 model (\f -> { f | fullscreen = not f.fullscreen })

        Load idx version ->
            update_ idx model (load version)

        First idx ->
            update_ idx model (load 0)

        Last idx ->
            update_
                idx
                model
                (model
                    |> Array.get idx
                    |> Maybe.map (.version >> Array.length >> (+) -1)
                    |> Maybe.withDefault 0
                    |> load
                )

        Event "eval" ( _, _, "LIA: wait", _ ) ->
            ( model, Nothing )

        Event "eval" ( ok, idx, message, details ) ->
            let
                ( model_, event ) =
                    decoder_result ok message details
                        |> resulting
                        |> update_ idx model

                debug =
                    Debug.log "FUCCCCCCCCC" <| Maybe.map .version <| Array.get 0 model_
            in
            ( model_, event )

        Event "stdin" ( _, idx, message, _ ) ->
            let
                f project =
                    case project.result of
                        Ok log ->
                            { project | result = Ok (Log (log.message ++ message) log.details) }

                        Err log ->
                            { project | result = Err (Log (log.message ++ message) log.details) }
            in
            update_ idx model f

        Event _ _ ->
            ( model, Nothing )


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
    case update_ idx model (\p -> { p | running = True }) of
        ( model_, Just event_log ) ->
            ( model_
            , Just <|
                JE.list
                    [ event_log
                    , JE.list [ JE.string "eval", JE.int idx, JE.string eval_str ]
                    ]
            )

        log_nothing ->
            log_nothing



-- let
--     code_0 =
--         project.file
--             |> Array.get 0
--             |> Maybe.map .code
--             |> Maybe.withDefault ""
-- in
-- update_
--     idx
--     model
--     (eval2js
--         ( idx
--         , if Array.length project.file == 1 then
--             project.evaluation
--                 |> replace ( 0, code_0 )
--                 |> default_replace code_0
--
--           else
--             project.file
--                 |> Array.indexedMap (\i f -> ( i, f.code ))
--                 |> Array.foldl replace project.evaluation
--                 |> default_replace code_0
--                 |> toJSstring
--         )
--     )
--     (\p -> { p | running = True })


update_ : ID -> Vector -> (Project -> Project) -> ( Vector, Maybe JE.Value )
update_ idx model f =
    case Array.get idx model of
        Just elem ->
            let
                new_model =
                    Array.set idx (f elem) model
            in
            ( new_model, Just (JE.list [ JE.string "store", vector2json new_model ]) )

        Nothing ->
            ( model, Nothing )


update_file : ID -> ID -> Vector -> (File -> File) -> ( Vector, Maybe JE.Value )
update_file id_1 id_2 model f =
    ( case Array.get id_1 model of
        Just project ->
            case Array.get id_2 project.file of
                Just file ->
                    Array.set id_1 { project | file = Array.set id_2 (f file) project.file } model

                Nothing ->
                    model

        Nothing ->
            model
    , Nothing
    )


resulting : Result Log Log -> Project -> Project
resulting result elem =
    let
        ( code, _ ) =
            elem.version
                |> Array.get elem.version_active
                |> Maybe.withDefault ( Array.empty, noResult )

        e =
            { elem
                | result = result
                , running = False
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


load : Int -> Project -> Project
load version elem =
    if (version >= 0) && (version < Array.length elem.version) then
        let
            ( code, result ) =
                elem.version
                    |> Array.get version
                    |> Maybe.withDefault ( Array.empty, noResult )
        in
        { elem
            | version_active = version
            , file = Array.indexedMap (\i a -> { a | code = Array.get i code |> Maybe.withDefault a.code }) elem.file
            , result = result
        }

    else
        elem
