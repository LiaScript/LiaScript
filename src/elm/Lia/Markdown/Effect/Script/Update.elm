module Lia.Markdown.Effect.Script.Update exposing
    ( Msg(..)
    , execute
    , getAll
    , getVisible
    , setRunning
    , update
    )

import Array
import Browser.Dom as Dom
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Types as Script exposing (Script, Scripts, Stdout(..))
import Lia.Parser.Parser exposing (parse_subsection)
import Lia.Section exposing (SubSection)
import Port.Eval as Eval exposing (Eval)
import Port.Event as Event exposing (Event)
import Process
import Task


type Msg sub
    = Click Int
    | Reset Int
    | Activate Bool Int
    | Value Int Bool String
    | Radio Int Bool String
    | Checkbox Int Bool String
    | Edit Bool Int
    | EditCode Int String
    | NoOp
    | Handle Event
    | Delay Float (Msg sub)
    | Sub Int sub


update :
    { update : Scripts SubSection -> sub -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    , handle : Scripts SubSection -> JE.Value -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    }
    -> Msg sub
    -> Scripts SubSection
    -> ( Scripts SubSection, Cmd (Msg sub), List Event )
update main msg scripts =
    case msg of
        Sub id sub ->
            case scripts |> Array.get id |> Maybe.andThen .result of
                Just (IFrame lia) ->
                    let
                        ( new, cmd, events ) =
                            main.update scripts sub lia
                    in
                    ( Script.set id (\s -> { s | result = Just (IFrame new) }) scripts
                    , Cmd.map (Sub id) cmd
                    , events
                        |> List.map (\( name, json ) -> Event name id json |> Event.encode)
                        |> List.map (Event "sub" id)
                    )

                _ ->
                    ( scripts
                    , Cmd.none
                    , []
                    )

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

        Checkbox id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.toggle str js.input, updated = True }) Cmd.none id scripts

            else
                ( scripts
                    |> Script.set id (\js -> { js | input = Input.toggle str js.input, updated = True })
                , Cmd.none
                , []
                )

        Radio id exec str ->
            if exec then
                reRun (\js -> { js | input = Input.value str js.input, updated = True }) Cmd.none id scripts

            else
                ( scripts
                    |> Script.set id (\js -> { js | input = Input.value str js.input, updated = True })
                , Cmd.none
                , []
                )

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
                                    |> Maybe.map (\n -> [ ( event.section, n.script, Input.getValue n.input ) ])
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

                "sub" ->
                    case scripts |> Array.get event.section |> Maybe.andThen .result of
                        Just (IFrame lia) ->
                            let
                                ( new, cmd, events ) =
                                    main.handle scripts event.message lia
                            in
                            ( Script.set event.section (\s -> { s | result = Just (IFrame new) }) scripts
                            , Cmd.map (Sub event.section) cmd
                            , events
                                |> List.map (\( name, json ) -> Event name event.section json |> Event.encode)
                                |> List.map (Event "sub" event.section)
                            )

                        _ ->
                            ( scripts, Cmd.none, [] )

                _ ->
                    ( scripts, Cmd.none, [] )


reRun : (Script a -> Script a) -> Cmd (Msg sub) -> Int -> Scripts a -> ( Scripts a, Cmd (Msg sub), List Event )
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
                [ ( id, node.script, Input.getValue node.input ) ]
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


update_ : Int -> JE.Value -> Scripts SubSection -> ( Bool, Scripts SubSection )
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


eval_ : Eval -> Script SubSection -> Script SubSection
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
                        if String.startsWith "HTML:" e.result then
                            e.result
                                |> String.dropLeft 5
                                |> HTML

                        else if String.startsWith "LIASCRIPT:" e.result then
                            case e.result |> String.dropLeft 10 |> parse_subsection of
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
