module Lia.Markdown.Quiz.Update exposing
    ( Msg(..)
    , handle
    , init
    , lockAnswered
    , merge
    , update
    )

{-| State transitions of all quizzes within a section, which are stored in one
`Vector`, the index of a quiz within it is its `id`.

Besides the user interactions, a quiz reacts on events from TypeScript:

  - `load` and `restore` merge a stored vector into the parsed one
  - `eval` is the result of a script that checks a quiz (`scriptID`)
  - `input` are the interactions with the inputs of a gap-text (`Multi`)

Every change of a solution state is stored and synced to the classroom.

-}

import Array exposing (Array)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as JS
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Json as Json
import Lia.Markdown.Quiz.Matrix.Update as Matrix
import Lia.Markdown.Quiz.Multi.Update as Multi
import Lia.Markdown.Quiz.Solution as Solution exposing (Solution)
import Lia.Markdown.Quiz.Sync as Sync
import Lia.Markdown.Quiz.Types
    exposing
        ( Element
        , State(..)
        , Type(..)
        , Vector
        , comp
        , comp2
        , reset
        , toState
        )
import Lia.Markdown.Quiz.Vector.Update as Vector
import Lia.Markdown.Types as Markdown
import Lia.Sync.Types as Classroom
import Return exposing (Return)
import Service.Console
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script
import Service.Slide


{-| The first `Int` is always the `id` of the quiz. `Check` and `ShowSolution`
carry the quiz definition, since the vector only holds the states.
-}
type Msg sub
    = Block_Update Int (Block.Msg sub)
    | Vector_Update Int Vector.Msg
    | Matrix_Update Int (Matrix.Msg sub)
    | Check Int (Type Markdown.Block)
    | ShowHint Int
    | ShowSolution Int (Type Markdown.Block)
    | Handle Event
    | Script (Script.Msg sub)


{-| Update the quiz vector of the section with the id `sectionID`. Without a
`sectionID` (subsections) nothing is stored or synced. `scripts` are the scripts
of the section, used by quizzes that are checked by a script.
-}
update :
    { sync | state : Classroom.State, data : Classroom.Data }
    -> Maybe Int
    -> Scripts a
    -> Msg sub
    -> Vector
    -> Return Vector (Msg sub) sub
update classroom sectionID scripts msg vector =
    let
        connected =
            Classroom.isConnected classroom.state

        evaluated id =
            store sectionID
                >> doSync connected sectionID (Just id)
                >> reveal id

        restore param =
            param
                |> Json.toVector
                |> Result.map (mergeHelper vector)
                |> Result.withDefault vector
                |> lockAnswered classroom sectionID
                |> Return.val
                |> init (\i s -> execute i s.state)
                |> doSync connected sectionID Nothing
    in
    case msg of
        Block_Update id sub ->
            updateElement id vector <|
                \e ->
                    case e.state of
                        Block_State s ->
                            s
                                |> Block.update sub
                                |> Return.mapVal (\new -> { e | state = Block_State new })
                                |> Return.mapCmd (Block_Update id)

                        _ ->
                            Return.val e

        Vector_Update id sub ->
            updateElement id vector <|
                \e ->
                    case e.state of
                        Vector_State s ->
                            Return.val { e | state = Vector_State (Vector.update sub s) }

                        _ ->
                            Return.val e

        Matrix_Update id sub ->
            updateElement id vector <|
                \e ->
                    case e.state of
                        Matrix_State s ->
                            s
                                |> Matrix.update sub
                                |> Return.mapVal (\new -> { e | state = Matrix_State new })

                        _ ->
                            Return.val e

        Check id solution ->
            case Array.get id vector of
                Just e ->
                    case e.scriptID of
                        Nothing ->
                            (\_ -> Return.val (evaluate (Just solution) (comp solution e.state) e))
                                |> updateElement id vector
                                |> evaluated id

                        Just scriptID ->
                            -- the script decides, the quiz stays deactivated until its result arrives
                            case Array.get scriptID scripts of
                                Just script ->
                                    vector
                                        |> Array.set id { e | deactivated = True }
                                        |> Return.val
                                        |> Return.batchEvent
                                            ([ toString e.state ]
                                                |> Service.Script.eval Nothing script.script (outputs scripts)
                                                |> Event.pushWithId "eval" id
                                            )

                                Nothing ->
                                    vector
                                        |> Array.set id { e | deactivated = False }
                                        |> Return.val

                Nothing ->
                    Return.val vector

        ShowHint id ->
            (\e -> Return.val { e | hint = e.hint + 1 })
                |> updateElement id vector
                |> store sectionID
                |> Return.batchEvent (Service.Slide.reveal ("lia-quiz-hints-" ++ String.fromInt id))

        ShowSolution id solution ->
            (\e -> Return.val { e | state = toState solution, solved = Solution.ReSolved, error_msg = "" })
                |> updateElement id vector
                |> store sectionID
                |> (case Array.get id vector |> Maybe.andThen .scriptID of
                        Just scriptID ->
                            case solution of
                                Generic_Type ->
                                    Return.script (JS.run scriptID "true")

                                _ ->
                                    Return.script (execute scriptID (toState solution))

                        Nothing ->
                            identity
                   )
                |> doSync connected sectionID (Just id)
                |> reveal id

        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    if Array.isEmpty vector then
                        -- Section not parsed yet (no quiz blocks known
                        -- locally, e.g. this is the eager sync preload for
                        -- an unvisited section) - nothing local to merge
                        -- into, but the CRDT should still learn about
                        -- persisted answers so peers see them in "details
                        -- mode" before this section is ever visited.
                        vector
                            |> Return.val
                            |> (if connected then
                                    Return.batchEvents
                                        (param
                                            |> Json.toVector
                                            |> Result.map (Array.toList >> List.indexedMap Sync.event >> List.filter Event.notNone)
                                            |> Result.withDefault []
                                        )

                                else
                                    identity
                               )

                    else
                        restore param

                ( Just "restore", _, ( _, param ) ) ->
                    restore param

                ( Just "input", id, input ) ->
                    updateElement id vector <|
                        \e ->
                            case e.state of
                                Multi_State s ->
                                    s
                                        |> Multi.update (Multi.handle input)
                                        |> Return.mapVal (\new -> { e | state = Multi_State new })

                                _ ->
                                    Return.val e

                ( Just "eval", id, ( "eval", param ) ) ->
                    (evalEventDecoder param >> Return.val)
                        |> updateElement id vector
                        |> (case Array.get id vector |> Maybe.andThen .scriptID of
                                Just scriptID ->
                                    Return.script (JS.submit scriptID event)

                                Nothing ->
                                    identity
                           )
                        |> evaluated id

                ( _, _, ( cmd, _ ) ) ->
                    vector
                        |> Return.val
                        |> Return.batchEvent (Service.Console.warn ("Quiz: unknown command => " ++ cmd))

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub


{-| The current input of a quiz, as it is passed to its script (`@input`).
-}
toString : State -> String
toString state =
    case state of
        Block_State b ->
            Block.toString False b

        Multi_State b ->
            Multi.toString b

        Vector_State s ->
            Vector.toString s

        Matrix_State m ->
            Matrix.toString m

        Generic_State ->
            ""


{-| Run the script `id` with the input `state`.
-}
execute : Int -> State -> Script.Msg sub
execute id =
    toString >> JS.run id


{-| Apply `fn` to the quiz `id`, unknown ids leave the vector untouched.
-}
updateElement :
    Int
    -> Vector
    -> (Element -> Return Element msg sub)
    -> Return Vector msg sub
updateElement id vector fn =
    case Array.get id vector of
        Just e ->
            Return.mapVal (\new -> Array.set id new vector) (fn e)

        Nothing ->
            Return.val vector


{-| Identify the TypeScript event as an `Event` handler.
-}
handle : Event -> Msg sub
handle =
    Handle


{-| Apply the result of a script that checks a quiz:

  - `true`: solved
  - `LIA: wait`: the script has not finished, the quiz stays deactivated
  - `LIA: ...`: other script commands only activate the quiz again
  - `true, false, ...` or `[true, false, ...]`: one result per input, solved
    if all are `true`
  - anything else: wrong
  - an error is shown as `error_msg`

-}
evalEventDecoder : JE.Value -> Element -> Element
evalEventDecoder json e =
    let
        eval =
            Service.Script.decode json

        active =
            { e | deactivated = False }
    in
    if not eval.ok then
        { active | error_msg = eval.result }

    else if eval.result == "true" then
        evaluate Nothing Solution.Solved active

    else if String.startsWith "LIA: wait" eval.result then
        e

    else if String.startsWith "LIA:" eval.result then
        active

    else if String.startsWith "[" eval.result || String.contains "," eval.result then
        let
            results =
                eval.result
                    |> String.replace "[" ""
                    |> String.replace "]" ""
                    |> String.split ","
                    |> List.filterMap
                        (\bool ->
                            case String.trim bool of
                                "true" ->
                                    Just True

                                "false" ->
                                    Just False

                                _ ->
                                    Nothing
                        )
        in
        evaluate Nothing
            (if List.all identity results then
                Solution.Solved

             else
                Solution.Open
            )
            { active | partiallySolved = Array.fromList results }

    else
        evaluate Nothing Solution.Open active


{-| Count a trial of an open quiz with the result `state`. If the last allowed
trial (`data-max-trials`) failed, the quiz is resolved and shows the
`solution`. Partial results are kept only with `data-show-partial-solution`,
they are computed from the `solution` or taken from a script result
(`e.partiallySolved`).
-}
evaluate : Maybe (Type Markdown.Block) -> Solution -> Element -> Element
evaluate solution state e =
    if e.solved /= Solution.Open then
        e

    else
        let
            counted =
                { e
                    | trial = e.trial + 1
                    , error_msg = ""
                    , partiallySolved =
                        case solution of
                            Just quiz ->
                                comp2 e.opt.showPartialSolution quiz e.state

                            Nothing ->
                                if e.opt.showPartialSolution then
                                    e.partiallySolved

                                else
                                    Array.empty
                }

            exhausted =
                case e.opt.maxTrials of
                    Just maxTrials ->
                        e.trial + 1 >= maxTrials && state /= Solution.Solved

                    Nothing ->
                        False
        in
        if exhausted then
            { counted
                | solved = Solution.ReSolved
                , state =
                    solution
                        |> Maybe.map toState
                        |> Maybe.withDefault e.state
            }

        else
            { counted | solved = state }


{-| Persist the whole vector of the section.
-}
store : Maybe Int -> Return Vector msg sub -> Return Vector msg sub
store sectionID return =
    case sectionID of
        Just id ->
            return
                |> Return.batchEvent
                    (return.value
                        |> Json.fromVector
                        |> Service.Database.store "quiz" id
                    )

        Nothing ->
            return


{-| Scroll the feedback and the solution of a quiz into the visible area, if
they are not already.
-}
reveal : Int -> Return Vector msg sub -> Return Vector msg sub
reveal id =
    -- ports dispatch in reverse order, the solution (below the feedback) has to win
    Return.batchEvents
        [ Service.Slide.reveal ("lia-quiz-solution-" ++ String.fromInt id)
        , Service.Slide.reveal ("lia-quiz-feedback-" ++ String.fromInt id)
        ]


{-| Combine two arrays element by element, the result is as long as the shorter
one. Also used by surveys and tasks to merge stored states into parsed ones.
-}
merge : (a -> a -> a) -> Array a -> Array a -> Array a
merge map v1 =
    Array.toList
        >> List.map2 map (Array.toList v1)
        >> Array.fromList


{-| Merge a stored vector into the parsed one.
-}
mergeHelper : Array Element -> Array Element -> Array Element
mergeHelper =
    merge mergeMap


{-| Take everything from the stored element `body`, except for what is defined
by the course (`scriptID` and options).
-}
mergeMap : Element -> Element -> Element
mergeMap parsed body =
    { body
        | scriptID = parsed.scriptID
        , opt = parsed.opt
        , deactivated = False
        , state =
            -- if the quiz is set to random and is not solved yet,
            -- then it is reset on every load
            case ( parsed.opt.randomize, body.solved ) of
                ( Just _, Solution.Open ) ->
                    reset body.state

                _ ->
                    body.state
    }


{-| Lock all quizzes that have already been answered in the classroom, see
`Lia.Markdown.Quiz.Sync.lockAnswered`.
-}
lockAnswered : { sync | state : Classroom.State, data : Classroom.Data } -> Maybe Int -> Vector -> Vector
lockAnswered classroom sectionID =
    Sync.lockAnswered (Classroom.id classroom.state) classroom.data.quiz sectionID


{-| Run the script of every element that has one, with `fn` creating the
script message. Also used by surveys and tasks. Since a `Return` can carry
only one script message, several are combined into a `Batch`.
-}
init :
    (Int -> { a | scriptID : Maybe Int } -> Script.Msg sub)
    -> Return (Array { a | scriptID : Maybe Int }) msg sub
    -> Return (Array { a | scriptID : Maybe Int }) msg sub
init fn return =
    case
        return.value
            |> Array.toList
            |> List.filterMap (\state -> Maybe.map (\id -> fn id state) state.scriptID)
    of
        [] ->
            return

        [ msg ] ->
            Return.script msg return

        msgs ->
            Return.script (Script.Batch msgs) return


{-| Send the solved quiz `vectorID` (or all, if `Nothing`) to the classroom,
if connected.
-}
doSync : Bool -> Maybe Int -> Maybe Int -> Return Vector msg sub -> Return Vector msg sub
doSync connected sectionID vectorID ret =
    case ( connected, sectionID, vectorID ) of
        ( True, Just _, Nothing ) ->
            ret
                |> Return.batchEvents
                    (ret.value
                        |> Array.toList
                        |> List.indexedMap Sync.event
                    )

        ( True, Just _, Just id ) ->
            ret
                |> Return.batchEvent
                    (ret.value
                        |> Array.get id
                        |> Maybe.map (Sync.event id)
                        |> Maybe.withDefault Event.none
                    )

        _ ->
            ret
