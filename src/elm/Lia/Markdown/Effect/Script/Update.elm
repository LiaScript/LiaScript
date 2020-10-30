module Lia.Markdown.Effect.Script.Update exposing
    ( Msg(..)
    , execute
    , getAll
    , getVisible
    , none
    , setRunning
    , update
    )

import Array exposing (Array)
import Browser.Dom as Dom
import Conditional.String as CString
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Types as Script exposing (Script, Scripts)
import Port.Eval as Eval exposing (Eval)
import Port.Event exposing (Event)
import Process
import Task


type Msg
    = Click Int
    | Reset Int
    | Activate Bool Int
    | Value Int Bool String
    | Radio Int String
    | Checkbox Int String
    | Edit Bool Int
    | EditCode Int String
    | NoOp
    | Handle Event
    | Delay Float Msg


update : Msg -> Scripts -> ( Scripts, Cmd Msg, List Event )
update msg scripts =
    case msg of
        Activate active id ->
            case Array.get id scripts of
                Just node ->
                    if
                        not active
                            && (node.input.type_
                                    |> Maybe.map (Input.runnable >> not)
                                    |> Maybe.withDefault False
                               )
                    then
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
                        ( Array.set id
                            { node
                                | input =
                                    if node.updated then
                                        node.input

                                    else
                                        Input.active active node.input
                                , updated = False
                            }
                            scripts
                        , if active then
                            Task.attempt (always NoOp) (Dom.focus "lia-focus")

                          else
                            Cmd.none
                        , []
                        )

                Nothing ->
                    ( scripts, Cmd.none, [] )

        Value id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input }) Cmd.none id scripts

            else
                ( scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input })
                , Cmd.none
                , []
                )

        Checkbox id str ->
            reRun (\js -> { js | input = Input.toggle str js.input, updated = True }) Cmd.none id scripts

        Radio id str ->
            reRun (\js -> { js | input = Input.value str js.input, updated = True }) Cmd.none id scripts

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
            ( scripts, Cmd.none, [] )

        Delay milliseconds subMsg ->
            ( scripts
            , Process.sleep milliseconds
                |> Task.perform (always subMsg)
            , []
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
                ( scripts
                    |> Script.set id fn
                , Task.attempt (always NoOp) (Dom.focus "lia-focus")
                , []
                )

            else
                reRun fn Cmd.none id scripts

        EditCode id str ->
            ( scripts
                |> Script.set id (\js -> { js | script = str })
            , Cmd.none
            , []
            )

        Handle event ->
            case event.topic of
                "code" ->
                    let
                        ( publish, javascript ) =
                            scripts
                                |> update_ event.section event.message

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
                                    |> Maybe.map (\n -> [ ( event.section, n.script, n.input.value ) ])
                                    |> Maybe.withDefault []
                                    |> Script.replaceInputs javascript

                            else
                                []
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            ( Script.set
                                event.section
                                (\js -> { js | update = False })
                                javascript
                            , Cmd.none
                            , List.map (execute 0) nodeUpdate
                            )

                        Just output ->
                            ( javascript
                                |> Script.updateChildren output
                                |> Script.set event.section (\js -> { js | update = False })
                            , Cmd.none
                            , if publish then
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
                                |> update_ event.section event.message

                        node =
                            javascript
                                |> Script.get identity event.section
                    in
                    case Maybe.andThen .output node of
                        Nothing ->
                            ( javascript
                            , Cmd.none
                            , []
                            )

                        Just output ->
                            ( Script.updateChildren output javascript
                            , Cmd.none
                            , if publish then
                                javascript
                                    |> Script.scriptChildren output
                                    |> List.map (execute 0)

                              else
                                []
                            )

                _ ->
                    ( scripts, Cmd.none, [] )


reRun : (Script -> Script) -> Cmd Msg -> Int -> Scripts -> ( Scripts, Cmd Msg, List Event )
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
            ( scripts_
            , cmd
            , if node.running then
                []

              else
                [ ( id, node.script, node.input.value ) ]
                    |> Script.replaceInputs scripts
                    |> List.map (execute 0)
            )

        Nothing ->
            ( scripts_, cmd, [] )


execute : Int -> ( Int, String ) -> Event
execute delay ( id, code ) =
    Event "execute" id <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            , ( "id", JE.int id )
            ]


update_ : Int -> JE.Value -> Scripts -> ( Bool, Scripts )
update_ id e scripts =
    case Array.get id scripts of
        Just js ->
            let
                new =
                    eval_ (Eval.decode e) js
            in
            ( new.result /= js.result
            , Array.set id new scripts
            )

        _ ->
            ( False, scripts )


eval_ : Eval -> Script -> Script
eval_ e js =
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
                        Ok e.result

                    else
                        Err e.result
    }


setRunning : Int -> Bool -> Scripts -> Scripts
setRunning id state javascript =
    Script.set id (\js -> { js | running = state }) javascript


getIdle : (Script -> x) -> Scripts -> List ( Int, x )
getIdle =
    Script.filterMap
        (\js ->
            not js.running && not (js.runOnce && js.counter >= 1)
        )


getAll : Scripts -> List ( Int, String )
getAll javascript =
    javascript
        |> getIdle identity
        |> List.map
            (\( id, node ) ->
                ( id, node.script, node.input.value )
            )
        |> Script.replaceInputs javascript


getVisible : Int -> Scripts -> List ( Int, String )
getVisible visible javascript =
    javascript
        |> getIdle identity
        |> List.filterMap
            (\( id, node ) ->
                if node.effect_id == visible then
                    Just ( id, node.script, node.input.value )

                else
                    Nothing
            )
        |> Script.replaceInputs javascript


none : x -> ( x, Maybe y )
none x =
    ( x, Nothing )
