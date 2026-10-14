module Lia.Markdown.Effect.Script.Update exposing
    ( execute
    , getAll
    , revealSolution
    , getVisible
    , handle
    , run
    , setRunning
    , submit
    , update
    )

import Array
import Helper.Array as Array
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


{-| Set the input of script `id` to the given value and pass it through as its
result, without executing any code.
-}
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
            iframe id (main.update scripts sub) scripts

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
                    let
                        activate js =
                            { js
                                | input =
                                    if node.updated then
                                        js.input

                                    else
                                        Input.active active js.input
                                , updated = False
                            }
                    in
                    if active then
                        scripts
                            |> Array.set id (activate node)
                            |> Return.val
                            |> Return.cmd (focus NoOp "lia-focus")

                    else
                        reRun activate (focus NoOp ("lia-script-" ++ String.fromInt id)) id scripts

                Nothing ->
                    Return.val scripts

        Value id exec str ->
            change exec (\js -> { js | input = Input.value str js.input }) id scripts

        Checkbox id exec str ->
            change exec (\js -> { js | input = Input.toggle str js.input, updated = True }) id scripts

        Radio id exec str ->
            change exec (\js -> { js | input = Input.value str js.input, updated = True }) id scripts

        Click id ->
            reRun identity Cmd.none id scripts

        Reset id ->
            reRun
                (\js -> { js | input = js.input |> Input.default |> Input.active True })
                Cmd.none
                id
                scripts

        NoOp ->
            Return.val scripts

        Batch msgs ->
            List.foldl
                (\subMsg ret ->
                    let
                        r =
                            update main subMsg ret.value
                    in
                    { r
                        | command = Cmd.batch [ ret.command, r.command ]
                        , events = ret.events ++ r.events
                        , sub =
                            case r.sub of
                                Just _ ->
                                    r.sub

                                Nothing ->
                                    ret.sub
                    }
                )
                (Return.val scripts)
                msgs

        Delay milliseconds subMsg ->
            scripts
                |> Return.val
                |> Return.cmd
                    (Process.sleep milliseconds
                        |> Task.perform (always subMsg)
                    )

        Edit bool id ->
            let
                edit js =
                    { js
                        | edit = bool
                        , input = Input.active False js.input
                    }
            in
            if bool then
                scripts
                    |> Array.update id edit
                    |> Return.val
                    |> Return.cmd (focus NoOp "lia-focus")

            else
                reRun edit Cmd.none id scripts
                    |> Return.cmd (focus NoOp ("lia-script-" ++ String.fromInt id))

        EditCode id str ->
            scripts
                |> Array.update id (\js -> { js | script = str })
                |> Return.val

        EditParam id subPattern str ->
            scripts
                |> Array.update id
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
                ( Just "script", id, ( "exec", param ) ) ->
                    evaluated False main.globals id param scripts

                ( Just "script", id, ( "async", param ) ) ->
                    evaluated True main.globals id param scripts

                ( Just "sub", id, ( _, param ) ) ->
                    iframe id
                        (main.handle scripts
                            (case Event.popWithId event of
                                Just ( "sub", _, e ) ->
                                    Event.encode e

                                _ ->
                                    param
                            )
                        )
                        scripts

                _ ->
                    Return.val scripts


{-| Pass a message to the LiaScript result (`IFrame`) of script `id`.
-}
iframe : Int -> (SubSection -> Return SubSection sub sub) -> Scripts SubSection -> Return (Scripts SubSection) (Msg sub) sub
iframe id fn scripts =
    case Array.get id scripts |> Maybe.andThen .result of
        Just (IFrame lia) ->
            lia
                |> fn
                |> Return.mapValCmd (\v -> Array.update id (\s -> { s | result = Just (IFrame v) }) scripts) (Sub id)
                |> Return.mapEvents "sub" id

        _ ->
            Return.val scripts


{-| Change an input, rerun the script only if `exec` is set (update-on-change).
-}
change : Bool -> (Script a -> Script a) -> Int -> Scripts a -> Return (Scripts a) (Msg sub) sub
change exec fn id scripts =
    if exec then
        reRun fn Cmd.none id scripts

    else
        scripts
            |> Array.update id fn
            |> Return.val


{-| Apply `fn` to script `id` and execute it, if it is not running or blocked.
A running script is marked to be executed again, after it has finished.
-}
reRun : (Script a -> Script a) -> Cmd (Msg sub) -> Int -> Scripts a -> Return (Scripts a) (Msg sub) sub
reRun fn cmd id scripts =
    let
        scripts_ =
            Array.update id
                (\js ->
                    fn <|
                        if js.running then
                            { js | update = True }

                        else
                            js
                )
                scripts
    in
    case Array.get id scripts_ of
        Just node ->
            scripts_
                |> Return.val
                |> Return.cmd cmd
                |> Return.batchEvents
                    (if node.running || node.block then
                        []

                     else
                        toExecute scripts_ [ ( id, node ) ]
                            |> List.map (execute 0)
                    )

        Nothing ->
            Return.val scripts_


{-| Store the result of an `exec` or `async` event of script `id`. If the
result has changed, all idle subscribers of its output are executed. After a
finished `exec`, a script that was marked for `update` is executed again.
-}
evaluated : Bool -> Maybe Definition -> Int -> JE.Value -> Scripts SubSection -> Return (Scripts SubSection) (Msg sub) sub
evaluated async globals id param scripts =
    case Array.get id scripts of
        Just old ->
            let
                ( node, started ) =
                    eval async globals id (Service.Script.decode param) old
                        |> start id old

                javascript =
                    Array.set id node scripts

                publish =
                    node.result /= old.result || (node.update && not node.running)

                again =
                    if not async && node.update then
                        toExecute javascript [ ( id, node ) ]

                    else
                        []

                done =
                    if async then
                        identity

                    else
                        Array.update id (\js -> { js | update = False })
            in
            (case node.output of
                Nothing ->
                    javascript
                        |> done
                        |> Return.val
                        |> Return.batchEvents (List.map (execute 0) again)

                Just output ->
                    javascript
                        |> Array.map
                            (\js ->
                                if js.running && List.member output js.inputs then
                                    { js | update = True }

                                else
                                    js
                            )
                        |> done
                        |> Return.val
                        |> Return.batchEvents
                            (if publish then
                                javascript
                                    |> select (\js -> not js.running && not js.block && List.member output js.inputs)
                                    |> toExecute javascript
                                    |> (++) again
                                    |> List.map (execute 0)

                             else
                                []
                            )
            )
                |> Return.batchEvents started

        Nothing ->
            Return.val scripts


{-| A new LiaScript result runs its visible scripts, like a section does when it
gets shown. Their events are tracked through the result (`sub`) and its effects,
so that the replies find their way back, also for results within results.
-}
start : Int -> Script SubSection -> Script SubSection -> ( Script SubSection, List Event )
start id old node =
    case node.result of
        Just (IFrame sub) ->
            if node.result /= old.result then
                let
                    runVisible model =
                        let
                            scripts =
                                getVisible model.visible model.javascript
                        in
                        ( { model | javascript = List.foldl (\( i, _, _ ) -> setRunning i True) model.javascript scripts }
                          -- delayed, so that the result is rendered before
                        , List.map (execute 100 >> Event.pushWithId "effect" id >> Event.pushWithId "sub" id) scripts
                        )
                in
                case sub of
                    SubSection s ->
                        runVisible s.effect_model
                            |> Tuple.mapFirst (\m -> { node | result = Just (IFrame (SubSection { s | effect_model = m })) })

                    SubSubSection s ->
                        runVisible s.effect_model
                            |> Tuple.mapFirst (\m -> { node | result = Just (IFrame (SubSubSection { s | effect_model = m })) })

            else
                ( node, [] )

        _ ->
            ( node, [] )


{-| Apply an evaluation result, the special results are:

  - `LIA: wait`: the script keeps running, the result stays
  - `LIA: stop`: the script has stopped, the result stays
  - `LIA: clear`: the result is removed

`async` results are sent while the script is still running.

-}
eval : Bool -> Maybe Definition -> Int -> Eval -> Script SubSection -> Script SubSection
eval async globals id e js =
    case e.result of
        "LIA: wait" ->
            { js | running = True, counter = js.counter + 1 }

        "LIA: stop" ->
            { js | running = False, counter = js.counter + 1 }

        "LIA: clear" ->
            { js | running = async, counter = js.counter + 1, result = Nothing }

        result ->
            { js
                | running = async
                , counter = js.counter + 1
                , result =
                    Just <|
                        if not e.ok then
                            Error result

                        else if String.startsWith "HTML:" result then
                            HTML (String.dropLeft 5 result)

                        else if String.startsWith "LIASCRIPT:" result then
                            case parse_subsection globals id (String.dropLeft 10 result) of
                                Ok sub ->
                                    IFrame sub

                                Err info ->
                                    Error info

                        else
                            Text result
            }


execute : Int -> ( Int, Bool, String ) -> Event
execute delay ( id, worker, code ) =
    Service.Script.exec delay worker code
        |> Event.pushWithId "script" id


setRunning : Int -> Bool -> Scripts a -> Scripts a
setRunning id state =
    Array.update id (\js -> { js | running = state })


{-| All scripts that match the filter, with their ids.
-}
select : (Script a -> Bool) -> Scripts a -> List ( Int, Script a )
select filter =
    Array.toIndexedList >> List.filter (Tuple.second >> filter)


{-| `(id, worker, code)` for every script to execute, the `@input` macros in
the code are replaced by the outputs of `javascript` and the script's own input.
-}
toExecute : Scripts a -> List ( Int, Script a ) -> List ( Int, Bool, String )
toExecute javascript =
    let
        inputs =
            Script.outputs javascript
    in
    List.map
        (\( id, js ) ->
            ( id
            , js.worker
            , inputs
                |> List.foldl Service.Script.replace_inputKey js.script
                |> (case Input.getValue js.input of
                        Just str ->
                            Service.Script.replace_input str

                        Nothing ->
                            identity
                   )
            )
        )


{-| Scripts that can be executed when a section or effect gets visible, submit
buttons and unrevealed solutions are excluded.
-}
idle : Script a -> Bool
idle js =
    not js.running
        && not js.block
        && not (js.runOnce && js.counter >= 1)
        && (js.input.type_ /= Just (Input.Button_ True))
        && (js.solution == Nothing)


{-| Scripts within a quiz or survey solution are not executed, until the
solution gets visible. Then they are released to the normal effect handling,
and all scripts of the solution, that are already visible (all if `runAll`), are
returned for execution.
-}
revealSolution : Bool -> Int -> String -> Scripts a -> ( Scripts a, List ( Int, Bool, String ) )
revealSolution runAll visible key javascript =
    let
        released =
            Array.map
                (\js ->
                    if js.solution == Just key then
                        { js | solution = Nothing }

                    else
                        js
                )
                javascript
    in
    ( released
    , javascript
        |> select (\js -> js.solution == Just key && not js.running && (runAll || js.effect_id <= visible))
        |> toExecute released
    )


getAll : Scripts a -> List ( Int, Bool, String )
getAll javascript =
    javascript
        |> select idle
        |> toExecute javascript


{-| All idle scripts bound to the effect `visible`.
-}
getVisible : Int -> Scripts a -> List ( Int, Bool, String )
getVisible visible javascript =
    javascript
        |> select (\js -> idle js && js.effect_id == visible)
        |> toExecute javascript
