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
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Script, Scripts)
import Port.Eval as Eval exposing (Eval)
import Port.Event exposing (Event)
import Task


type Msg
    = Click Int
    | Date Int
    | Activate Int
    | Deactivate Int
    | Value Int String
    | NoOp
    | Handle Event


update : Msg -> Scripts -> ( Scripts, Cmd Msg, List Event )
update msg scripts =
    case msg of
        Activate id ->
            ( scripts
                |> Script.set id
                    (\js ->
                        let
                            input =
                                js.input
                        in
                        { js | input = { input | active = not input.active } }
                    )
            , Task.attempt (always NoOp) (Dom.focus "lia-focus")
            , []
            )

        Deactivate id ->
            case Script.get identity id scripts of
                Just node ->
                    let
                        input =
                            node.input
                    in
                    reRun id
                        { node | input = { input | active = False } }
                        scripts

                _ ->
                    ( scripts, Cmd.none, [] )

        Value id str ->
            case Script.get identity id scripts of
                Just node ->
                    let
                        input =
                            node.input
                    in
                    reRun id
                        { node
                            | input =
                                { input
                                    | value =
                                        if String.isEmpty str then
                                            input.default

                                        else
                                            str
                                }
                        }
                        scripts

                _ ->
                    ( scripts, Cmd.none, [] )

        Date id ->
            ( scripts, Cmd.none, [] )

        Click id ->
            case Script.get identity id scripts of
                Just node ->
                    reRun id node scripts

                _ ->
                    ( scripts, Cmd.none, [] )

        NoOp ->
            ( scripts, Cmd.none, [] )

        Handle event ->
            case event.topic of
                "code" ->
                    let
                        javascript =
                            scripts
                                |> update_ event.section (Eval.decode event.message)

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
                            , javascript
                                |> Script.scriptChildren output
                                |> List.append nodeUpdate
                                |> List.map (execute 0)
                            )

                "codeX" ->
                    let
                        javascript =
                            event.message
                                |> Eval.decode
                                |> .result
                                |> Script.setResult event.section scripts

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
                            , javascript
                                |> Script.scriptChildren output
                                |> List.map (execute 0)
                            )

                _ ->
                    ( scripts, Cmd.none, [] )


reRun : Int -> Script -> Scripts -> ( Scripts, Cmd Msg, List Event )
reRun id node scripts =
    ( Script.set id
        (always
            (if node.running then
                { node | update = True }

             else
                node
            )
        )
        scripts
    , Cmd.none
    , if node.running then
        []

      else
        [ ( id, node.script, node.input.value ) ]
            |> Script.replaceInputs scripts
            |> List.map (execute 0)
    )


execute : Int -> ( Int, String ) -> Event
execute delay ( id, code ) =
    Event "execute" id <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            , ( "id", JE.int id )
            ]


update_ : Int -> Eval -> Scripts -> Scripts
update_ id e =
    Script.set id (eval_ e)


eval_ : Eval -> Script -> Script
eval_ e js =
    { js
        | running = e.result == "\"LIA: wait\""
        , counter = js.counter + 1
        , result =
            if
                e.result
                    == "\"LIA: stop\""
                    || e.result
                    == "\"LIA: wait\""
            then
                js.result

            else if e.ok then
                Just (Ok e.result)

            else
                Just (Err e.result)
    }


setRunning : Int -> Bool -> Scripts -> Scripts
setRunning id state javascript =
    Script.set id (\js -> { js | running = state }) javascript


getAll : (Script -> x) -> Scripts -> List ( Int, x )
getAll =
    Script.filterMap
        (\js ->
            not js.running || not (js.runOnce && js.counter == 1)
        )


getVisible : Int -> Scripts -> List ( Int, String )
getVisible visble javascript =
    javascript
        |> getAll identity
        |> List.filterMap
            (\( id, node ) ->
                if node.effect_id == visble then
                    Just ( id, node.script, node.input.value )

                else
                    Nothing
            )
        |> Script.replaceInputs javascript


none : x -> ( x, Maybe y )
none x =
    ( x, Nothing )
