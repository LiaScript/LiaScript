module Lia.Markdown.Effect.Script.Update exposing
    ( execute
    , getAll
    , getVisible
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
import Port.Eval as Eval exposing (Eval)
import Port.Event as Event exposing (Event)
import Process
import Return exposing (Return)
import Task


update :
    { update : Scripts SubSection -> sub -> SubSection -> ( SubSection, Cmd sub, List Event )
    , handle : Scripts SubSection -> JE.Value -> SubSection -> ( SubSection, Cmd sub, List Event )
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
                    let
                        ( new, cmd, events ) =
                            main.update scripts sub lia
                    in
                    Script.set id (\s -> { s | result = Just (IFrame new) }) scripts
                        |> Return.value
                        |> Return.cmd (Cmd.map (Sub id) cmd)
                        |> Return.events
                            (events
                                |> List.map (Event.encode >> Event "sub" id)
                            )

                _ ->
                    Return.value scripts

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
                            |> Return.value
                            |> Return.cmd
                                (if active then
                                    focus NoOp "lia-focus"

                                 else
                                    Cmd.none
                                )

                Nothing ->
                    Return.value scripts

        Value id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input })
                    |> Return.value

        Checkbox id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.toggle str js.input, updated = True }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.toggle str js.input, updated = True })
                    |> Return.value

        Radio id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input, updated = True }) Cmd.none id scripts

            else
                scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input, updated = True })
                    |> Return.value

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
            Return.value scripts

        Delay milliseconds subMsg ->
            scripts
                |> Return.value
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
                    |> Return.value
                    |> Return.cmd (focus NoOp "lia-focus")

            else
                reRun fn Cmd.none id scripts

        EditCode id str ->
            scripts
                |> Script.set id (\js -> { js | script = str })
                |> Return.value

        Handle event ->
            case event.topic of
                "code" ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ main.globals event.section event.message

                        node =
                            javascript
                                |> Script.get identity event.section

                        nodeUpdate =
                            if
                                node
                                    |> Maybe.map .update
                                    |> Maybe.withDefault False
                            then
                                node
                                    |> Maybe.map (\n -> [ ( event.section, n.script, Input.getValue n.input ) ])
                                    |> Maybe.withDefault []
                                    |> Script.replaceInputs javascript

                            else
                                []
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            Script.set
                                event.section
                                (\js -> { js | update = False })
                                javascript
                                |> Return.value
                                |> Return.events (List.map (execute 0) nodeUpdate)

                        Just output ->
                            javascript
                                |> Script.updateChildren output
                                |> Script.set event.section (\js -> { js | update = False })
                                |> Return.value
                                |> Return.events
                                    (if publish then
                                        javascript
                                            |> Script.scriptChildren output
                                            |> List.append nodeUpdate
                                            |> List.map (execute 0)

                                     else
                                        []
                                    )

                "codeX" ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ main.globals event.section event.message

                        node =
                            javascript
                                |> Script.get identity event.section
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            Return.value javascript

                        Just output ->
                            Script.updateChildren output javascript
                                |> Return.value
                                |> Return.events
                                    (if publish then
                                        javascript
                                            |> Script.scriptChildren output
                                            |> List.map (execute 0)

                                     else
                                        []
                                    )

                "sub" ->
                    case scripts |> Array.get event.section |> Maybe.andThen .result of
                        Just (IFrame lia) ->
                            let
                                ( new, cmd, events ) =
                                    main.handle scripts event.message lia
                            in
                            Script.set event.section (\s -> { s | result = Just (IFrame new) }) scripts
                                |> Return.value
                                |> Return.cmd (Cmd.map (Sub event.section) cmd)
                                |> Return.events (List.map (Event.encode >> Event "sub" event.section) events)

                        _ ->
                            Return.value scripts

                _ ->
                    Return.value scripts


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
                |> Return.value
                |> Return.cmd cmd
                |> Return.events
                    (if node.running then
                        []

                     else
                        [ ( id, node.script, Input.getValue node.input ) ]
                            |> Script.replaceInputs scripts
                            |> List.map (execute 0)
                    )

        Nothing ->
            Return.value scripts_


execute : Int -> ( Int, String ) -> Event
execute delay ( id, code ) =
    Event "execute" id <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            , ( "id", JE.int id )
            ]


update_ : Maybe Definition -> Int -> JE.Value -> Scripts SubSection -> ( Bool, Scripts SubSection )
update_ defintion id e scripts =
    case Array.get id scripts of
        Just js ->
            let
                new =
                    eval_ defintion id (Eval.decode e) js
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
            not js.running && not (js.runOnce && js.counter >= 1)
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
