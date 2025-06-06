module Lia.Markdown.Effect.Script.Update exposing
    ( execute
    , getAll
    , getVisible
    , handle
    , run
    , setRunning
    , submit
    , update
    )

import Array
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Types as Script exposing (Msg(..), Script, Scripts, Stdout(..))
import Lia.Parser.Parser exposing (parse_subsection)
import Lia.Section exposing (SubSection(..))
import Lia.Utils exposing (focus)
import List.Extra
import Process
import Return exposing (Return)
import Service.Event as Event exposing (Event)
import Service.Script exposing (Eval)
import Task


run : Int -> String -> Msg sub
run =
    Execute


handle : Event -> Msg sub
handle =
    Handle


{-| Used by external models with associated scripts, such as Quizzes, Tasks,
etc. to indicate that an evaluated script that contains an output, should
trigger the execution of all scripts, that are subscribed to this topic.
-}
submit : Int -> Event -> Msg sub
submit scriptID event =
    Handle
        { event
            | service = "script"
            , track = [ ( "script", scriptID ) ]
            , message =
                { cmd = "exec"
                , param = event.message.param
                }
        }


update :
    { update : Scripts SubSection -> sub -> SubSection -> Return SubSection sub sub
    , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection sub sub
    , globals : Maybe Definition
    }
    -> Msg sub
    -> Scripts SubSection
    -> Return (Scripts SubSection) (Msg sub) sub
update main msg scripts =
    case msg of
        Sub id sub ->
            case scripts |> Array.get id |> Maybe.andThen .result of
                Just (IFrame lia) ->
                    lia
                        |> main.update scripts sub
                        |> Return.mapValCmd (\v -> Script.set id (\s -> { s | result = Just (IFrame v) }) scripts) (Sub id)
                        |> Return.mapEvents "sub" id

                _ ->
                    Return.val scripts

        Execute id value ->
            case Array.get id scripts of
                Just node ->
                    scripts
                        |> Array.set id
                            { node
                                | input = Input.value value node.input
                                , updated = True
                            }
                        |> update main
                            (value
                                |> Service.Script.evalDummy
                                |> Event.pushWithId "script" id
                                |> Handle
                            )

                Nothing ->
                    Return.val scripts

        Activate active id ->
            case Array.get id scripts of
                Just node ->
                    if active then
                        Array.set id
                            { node
                                | input =
                                    if node.updated then
                                        node.input

                                    else
                                        Input.active active node.input
                                , updated = False
                            }
                            scripts
                            |> Return.val
                            |> Return.cmd (focus NoOp "lia-focus")

                    else
                        reRun
                            (\js ->
                                { js
                                    | input =
                                        if node.updated then
                                            js.input

                                        else
                                            Input.active active js.input
                                    , updated = False
                                }
                            )
                            Cmd.none
                            id
                            scripts

                Nothing ->
                    Return.val scripts

        Value id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input })
                    |> Return.val

        Checkbox id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.toggle str js.input, updated = True }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.toggle str js.input, updated = True })
                    |> Return.val

        Radio id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input, updated = True }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input, updated = True })
                    |> Return.val

        Click id ->
            reRun identity Cmd.none id scripts

        Reset id ->
            reRun
                (\js ->
                    { js
                        | input =
                            js.input
                                |> Input.default
                                |> Input.active True
                    }
                )
                Cmd.none
                id
                scripts

        NoOp ->
            Return.val scripts

        Delay milliseconds subMsg ->
            scripts
                |> Return.val
                |> Return.cmd
                    (Process.sleep milliseconds
                        |> Task.perform (always subMsg)
                    )

        Edit bool id ->
            let
                fn js =
                    { js
                        | edit = bool
                        , input = Input.active False js.input
                    }
            in
            if bool then
                scripts
                    |> Script.set id fn
                    |> Return.val
                    |> Return.cmd (focus NoOp "lia-focus")

            else
                reRun fn Cmd.none id scripts

        EditCode id str ->
            scripts
                |> Script.set id (\js -> { js | script = str })
                |> Return.val

        EditParam id subPattern str ->
            scripts
                |> Script.set id
                    (\js ->
                        { js
                            | script =
                                String.split subPattern js.script
                                    |> List.Extra.setAt 1 str
                                    |> String.join subPattern
                        }
                    )
                |> Return.val

        Handle event ->
            case Event.destructure event of
                ( Just "script", section, ( "exec", param ) ) ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ False main.globals section param

                        node =
                            javascript
                                |> Script.get identity section

                        nodeUpdate =
                            if
                                node
                                    |> Maybe.map .update
                                    |> Maybe.withDefault False
                            then
                                node
                                    |> Maybe.map
                                        (\n ->
                                            [ { id = section
                                              , worker = n.worker
                                              , script = n.script
                                              , input_ = Input.getValue n.input
                                              }
                                            ]
                                        )
                                    |> Maybe.withDefault []
                                    |> Script.replaceInputs javascript

                            else
                                []
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            Script.set
                                section
                                (\js -> { js | update = False })
                                javascript
                                |> Return.val
                                |> Return.batchEvents (List.map (execute 0) nodeUpdate)

                        Just output ->
                            javascript
                                |> Script.updateChildren output
                                |> Script.set section (\js -> { js | update = False })
                                |> Return.val
                                |> Return.batchEvents
                                    (if publish then
                                        javascript
                                            |> Script.scriptChildren output
                                            |> List.append nodeUpdate
                                            |> List.map (execute 0)

                                     else
                                        []
                                    )

                ( Just "script", section, ( "async", param ) ) ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ True main.globals section param

                        node =
                            javascript
                                |> Script.get identity section
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            Return.val javascript

                        Just output ->
                            Script.updateChildren output javascript
                                |> Return.val
                                |> Return.batchEvents
                                    (if publish then
                                        javascript
                                            |> Script.scriptChildren output
                                            |> List.map (execute 0)

                                     else
                                        []
                                    )

                ( Just "sub", section, ( _, param ) ) ->
                    let
                        subParams =
                            case Event.popWithId event of
                                Just ( "sub", _, e ) ->
                                    Event.encode e

                                _ ->
                                    param
                    in
                    case
                        scripts
                            |> Array.get section
                            |> Maybe.andThen .result
                    of
                        Just (IFrame lia) ->
                            lia
                                |> main.handle scripts subParams
                                |> Return.mapValCmd (\v -> Script.set section (\s -> { s | result = Just (IFrame v) }) scripts) (Sub section)
                                |> Return.mapEvents "sub" section

                        _ ->
                            Return.val scripts

                _ ->
                    Return.val scripts


reRun : (Script a -> Script a) -> Cmd (Msg sub) -> Int -> Scripts a -> Return (Scripts a) (Msg sub) sub
reRun fn cmd id scripts =
    let
        scripts_ =
            scripts
                |> Script.set id
                    (\js ->
                        fn <|
                            if js.running then
                                { js | update = True }

                            else
                                js
                    )
    in
    case Script.get identity id scripts_ of
        Just node ->
            scripts_
                |> Return.val
                |> Return.cmd cmd
                |> Return.batchEvents
                    (if node.running || node.block then
                        []

                     else
                        [ { id = id
                          , worker = node.worker
                          , script = node.script
                          , input_ = Input.getValue node.input
                          }
                        ]
                            |> Script.replaceInputs scripts
                            |> List.map (execute 0)
                    )

        Nothing ->
            Return.val scripts_


execute : Int -> ( Int, Bool, String ) -> Event
execute delay ( id, worker, code ) =
    Service.Script.exec delay worker code
        |> Event.pushWithId "script" id


update_ : Bool -> Maybe Definition -> Int -> JE.Value -> Scripts SubSection -> ( Bool, Scripts SubSection )
update_ async defintion id e scripts =
    case Array.get id scripts of
        Just js ->
            let
                new =
                    eval_ async defintion id (Service.Script.decode e) js
            in
            ( new.result /= js.result
            , Array.set id new scripts
            )

        _ ->
            ( False, scripts )


eval_ : Bool -> Maybe Definition -> Int -> Eval -> Script SubSection -> Script SubSection
eval_ async defintion id e js =
    let
        waiting =
            e.result == "LIA: wait"
    in
    { js
        | running =
            if async && e.result /= "LIA: stop" then
                True

            else if e.result == "LIA: stop" then
                False

            else
                waiting
        , counter = js.counter + 1
        , result =
            if waiting then
                js.result

            else if e.result == "LIA: stop" then
                js.result

            else if e.result == "LIA: clear" then
                Nothing

            else
                Just <|
                    if e.ok then
                        if String.startsWith "HTML:" e.result then
                            e.result
                                |> String.dropLeft 5
                                |> HTML

                        else if String.startsWith "LIASCRIPT:" e.result then
                            case
                                e.result
                                    |> String.dropLeft 10
                                    |> parse_subsection defintion id
                            of
                                Ok rslt ->
                                    IFrame rslt

                                Err info ->
                                    Error info

                        else
                            Text e.result

                    else
                        Error e.result
    }


setRunning : Int -> Bool -> Scripts a -> Scripts a
setRunning id state javascript =
    Script.set id (\js -> { js | running = state }) javascript


getIdle : (Script a -> x) -> Scripts a -> List ( Int, x )
getIdle =
    Script.filterMap
        (\js ->
            not js.running && not js.block && not (js.runOnce && js.counter >= 1) && (js.input.type_ /= Just (Input.Button_ True))
        )


getAll : Scripts a -> List ( Int, Bool, String )
getAll javascript =
    javascript
        |> getIdle identity
        |> List.map
            (\( id, node ) ->
                { id = id
                , worker = node.worker
                , script = node.script
                , input_ = Input.getValue node.input
                }
            )
        |> Script.replaceInputs javascript


getVisible : Int -> Scripts a -> List ( Int, Bool, String )
getVisible visible javascript =
    javascript
        |> getIdle identity
        |> List.filterMap
            (\( id, node ) ->
                if node.effect_id == visible && node.input.type_ /= Just (Input.Button_ True) then
                    Just
                        { id = id
                        , worker = node.worker
                        , script = node.script
                        , input_ = Input.getValue node.input
                        }

                else
                    Nothing
            )
        |> Script.replaceInputs javascript
