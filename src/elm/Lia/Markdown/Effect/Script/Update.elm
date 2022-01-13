module Lia.Markdown.Effect.Script.Update exposing
    ( execute
    , getAll
    , getVisible
    , handle
    , run
    , setRunning
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
                        |> update main (Handle Event.todo)

                -- TODO:
                -- (Eval True value []
                --     |> Service.Script.encode
                --     |> Event.initWithId Nothing "code" id
                --     |> Handle
                -- )
                Nothing ->
                    Return.val scripts

        Activate active id ->
            case Array.get id scripts of
                Just node ->
                    if not active then
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

                    else
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
                            |> Return.cmd
                                (if active then
                                    focus NoOp "lia-focus"

                                 else
                                    Cmd.none
                                )

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

        Handle event ->
            case Event.destructure event of
                ( Just "code", section, { cmd, param } ) ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ main.globals section param

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
                                    |> Maybe.map (\n -> [ ( section, n.script, Input.getValue n.input ) ])
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

                ( Just "codeX", section, { cmd, param } ) ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ main.globals section param

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

                ( Just "sub", section, { cmd, param } ) ->
                    case scripts |> Array.get section |> Maybe.andThen .result of
                        Just (IFrame lia) ->
                            lia
                                |> main.handle scripts param
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
                        [ ( id, node.script, Input.getValue node.input ) ]
                            |> Script.replaceInputs scripts
                            |> List.map (execute 0)
                    )

        Nothing ->
            Return.val scripts_


execute : Int -> ( Int, String ) -> Event
execute delay ( id, code ) =
    { cmd = "execute"
    , param =
        [ ( "delay", JE.int delay )
        , ( "code", JE.string code )
        , ( "id", JE.int id )
        ]
            |> JE.object
    }
        |> Event.init "executeTODO"


update_ : Maybe Definition -> Int -> JE.Value -> Scripts SubSection -> ( Bool, Scripts SubSection )
update_ defintion id e scripts =
    case Array.get id scripts of
        Just js ->
            let
                new =
                    eval_ defintion id (Service.Script.decode e) js
            in
            ( new.result /= js.result
            , Array.set id new scripts
            )

        _ ->
            ( False, scripts )


eval_ : Maybe Definition -> Int -> Eval -> Script SubSection -> Script SubSection
eval_ defintion id e js =
    let
        waiting =
            e.result == "LIA: wait"
    in
    { js
        | running = waiting
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
            not js.running && not js.block && not (js.runOnce && js.counter >= 1)
        )


getAll : Scripts a -> List ( Int, String )
getAll javascript =
    javascript
        |> getIdle identity
        |> List.map
            (\( id, node ) ->
                ( id, node.script, Input.getValue node.input )
            )
        |> Script.replaceInputs javascript


getVisible : Int -> Scripts a -> List ( Int, String )
getVisible visible javascript =
    javascript
        |> getIdle identity
        |> List.filterMap
            (\( id, node ) ->
                if node.effect_id == visible then
                    Just ( id, node.script, Input.getValue node.input )

                else
                    Nothing
            )
        |> Script.replaceInputs javascript
