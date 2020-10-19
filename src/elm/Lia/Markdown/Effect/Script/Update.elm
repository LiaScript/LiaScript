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
import Task


type Msg
    = Click Int
    | Activate Bool Int
    | Value Int String
    | Edit Bool Int
    | EditCode Int String
    | NoOp
    | Handle Event


update : Msg -> Scripts -> ( Scripts, Cmd Msg, List Event )
update msg scripts =
    case msg of
        Activate bool id ->
            ( scripts
                |> Script.set id
                    (\js -> { js | input = Input.active bool js.input })
            , if bool then
                Task.attempt (always NoOp) (Dom.focus "lia-focus")

              else
                Cmd.none
            , []
            )

        Value id str ->
            reRun (\js -> { js | input = Input.value str js.input }) Cmd.none id scripts

        Click id ->
            reRun identity Cmd.none id scripts

        NoOp ->
            ( scripts, Cmd.none, [] )

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


update_ : Int -> Eval -> Scripts -> Scripts
update_ id e =
    Script.set id (eval_ e)


eval_ : Eval -> Script -> Script
eval_ e js =
    let
        result =
            trim e.result

        waiting =
            result == "LIA: wait"
    in
    { js
        | running = waiting
        , counter = js.counter + 1
        , result =
            if waiting then
                js.result

            else if result == "LIA: stop" then
                js.result

            else if e.ok then
                Just (Ok result)

            else
                Just (Err result)
    }


trim : String -> String
trim str =
    str
        |> CString.dropLeftIf (String.startsWith "\"" str) 1
        |> CString.dropRightIf (String.endsWith "\"" str) 1


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
