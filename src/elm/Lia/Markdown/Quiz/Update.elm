module Lia.Markdown.Quiz.Update exposing
    ( Msg(..)
    , handle
    , init
    , merge
    , update
    )

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
        , reset
        , toState
        )
import Lia.Markdown.Quiz.Vector.Update as Vector
import Return exposing (Return)
import Service.Console
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Script
import Translations exposing (Lang(..))


type Msg sub
    = Block_Update Int (Block.Msg sub)
    | Multi_Update Int (Multi.Msg sub)
    | Vector_Update Int (Vector.Msg sub)
    | Matrix_Update Int (Matrix.Msg sub)
    | Check Int Type
    | ShowHint Int
    | ShowSolution Int Type
    | Handle Event
    | Script (Script.Msg sub)


update : Bool -> Maybe Int -> Scripts a -> Msg sub -> Vector -> Return Vector msg sub
update sync sectionID scripts msg vector =
    case msg of
        Block_Update id _ ->
            update_ id vector (state_ msg)

        Multi_Update id _ ->
            update_ id vector (state_ msg)

        Vector_Update id _ ->
            update_ id vector (state_ msg)

        Matrix_Update id _ ->
            update_ id vector (state_ msg)

        Check id solution ->
            case Array.get id vector of
                Just e ->
                    case e.scriptID of
                        Nothing ->
                            check solution
                                -->> syncSolution id
                                |> update_ id vector
                                |> store sectionID
                                |> doSync sync sectionID (Just id)

                        Just scriptID ->
                            vector
                                |> Return.val
                                |> Return.batchEvents
                                    (case
                                        scripts
                                            |> Array.get scriptID
                                            |> Maybe.map .script
                                     of
                                        Just code ->
                                            [ [ toString e.state ]
                                                |> Service.Script.eval code (outputs scripts)
                                                |> Event.pushWithId "eval" id
                                            ]

                                        _ ->
                                            []
                                    )

                Nothing ->
                    vector
                        |> Return.val

        ShowHint idx ->
            (\e -> Return.val { e | hint = e.hint + 1 })
                |> update_ idx vector
                |> store sectionID

        ShowSolution id solution ->
            (\e -> Return.val { e | state = toState solution, solved = Solution.ReSolved, error_msg = "" })
                |> update_ id vector
                |> store sectionID
                |> (\return ->
                        case Array.get id vector |> Maybe.andThen .scriptID of
                            Just scriptID ->
                                case solution of
                                    Generic_Type ->
                                        return
                                            |> Return.script (JS.run scriptID "true")

                                    _ ->
                                        return
                                            |> Return.script (execute scriptID <| toState solution)

                            _ ->
                                return
                   )
                |> doSync sync sectionID (Just id)

        Handle event ->
            case Event.destructure event of
                ( Nothing, _, ( "load", param ) ) ->
                    param
                        |> Json.toVector
                        |> Result.map (mergeHelper vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init (\i s -> execute i s.state)
                        |> doSync sync sectionID Nothing

                ( Just "eval", id, ( "eval", param ) ) ->
                    case
                        vector
                            |> Array.get id
                            |> Maybe.andThen .scriptID
                    of
                        Just scriptID ->
                            param
                                |> evalEventDecoder
                                |> update_ id vector
                                |> store sectionID
                                |> Return.script (JS.submit scriptID event)
                                |> doSync sync sectionID (Just id)

                        Nothing ->
                            param
                                |> evalEventDecoder
                                |> update_ id vector
                                |> store sectionID
                                |> doSync sync sectionID (Just id)

                ( Just "restore", _, ( cmd, param ) ) ->
                    param
                        |> Json.toVector
                        |> Result.map (mergeHelper vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init (\i s -> execute i s.state)
                        |> doSync sync sectionID Nothing

                ( _, _, ( cmd, _ ) ) ->
                    vector
                        |> Return.val
                        |> Return.batchEvent
                            ("Quiz: unknown command => "
                                ++ cmd
                                |> Service.Console.warn
                            )

        Script sub ->
            vector
                |> Return.val
                |> Return.script sub


toString : State -> String
toString state =
    case state of
        Block_State b ->
            Block.toString b

        Vector_State s ->
            Vector.toString s

        Matrix_State m ->
            Matrix.toString m

        _ ->
            ""


execute : Int -> State -> Script.Msg sub
execute id =
    toString >> JS.run id


update_ :
    Int
    -> Vector
    -> (Element -> Return Element msg sub)
    -> Return Vector msg sub
update_ idx vector fn =
    case Array.get idx vector |> Maybe.map fn of
        Just ret ->
            Return.mapVal (\v -> Array.set idx v vector) ret

        _ ->
            Return.val vector


state_ : Msg sub -> Element -> Return Element msg sub
state_ msg e =
    case ( msg, e.state ) of
        ( Block_Update _ m, Block_State s ) ->
            s
                |> Block.update m
                |> Return.mapVal (setState e Block_State)

        ( Vector_Update _ m, Vector_State s ) ->
            s
                |> Vector.update m
                |> Return.mapVal (setState e Vector_State)

        ( Matrix_Update _ m, Matrix_State s ) ->
            s
                |> Matrix.update m
                |> Return.mapVal (setState e Matrix_State)

        _ ->
            Return.val e


setState : Element -> (s -> State) -> s -> Element
setState e fn state =
    { e | state = fn state }


handle : Event -> Msg sub
handle =
    Handle


evalEventDecoder : JE.Value -> Element -> Return Element msg sub
evalEventDecoder json =
    let
        eval =
            -- TODO:
            -- Eval.decode json
            Service.Script.decode json
    in
    if eval.ok then
        if eval.result == "true" then
            isSolved Nothing Solution.Solved >> Return.val

        else if String.startsWith "LIA:" eval.result then
            Return.val

        else
            isSolved Nothing Solution.Open >> Return.val

    else
        \e -> Return.val { e | error_msg = eval.result }


isSolved : Maybe Type -> Solution -> Element -> Element
isSolved solution state e =
    case ( e.opt.maxTrials, e.solved ) of
        ( Nothing, Solution.Open ) ->
            { e
                | trial = e.trial + 1
                , solved = state
                , error_msg = ""
            }

        ( Just maxTrials, Solution.Open ) ->
            if e.trial + 1 < maxTrials || state == Solution.Solved then
                { e
                    | trial = e.trial + 1
                    , solved = state
                    , error_msg = ""
                }

            else
                { e
                    | trial = e.trial + 1
                    , solved = Solution.ReSolved
                    , error_msg = ""
                    , state =
                        solution
                            |> Maybe.map toState
                            |> Maybe.withDefault e.state
                }

        _ ->
            e


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


check : Type -> Element -> Return Element msg sub
check solution e =
    e
        |> isSolved (Just solution) (comp solution e.state)
        |> Return.val


merge : (a -> a -> a) -> Array a -> Array a -> Array a
merge map v1 =
    Array.toList
        >> List.map2 map (Array.toList v1)
        >> Array.fromList


mergeHelper : Array Element -> Array Element -> Array Element
mergeHelper =
    merge mergeMap


mergeMap : Element -> Element -> Element
mergeMap sID body =
    { body
        | scriptID = sID.scriptID
        , opt = sID.opt
        , state =
            -- if the quiz is set to random and is not solved yet,
            -- then it is reset on every load
            case ( sID.opt.randomize, body.solved ) of
                ( Just _, Solution.Open ) ->
                    reset body.state

                _ ->
                    body.state
    }


init :
    (Int -> { a | scriptID : Maybe Int } -> Script.Msg sub)
    -> Return (Array { a | scriptID : Maybe Int }) msg sub
    -> Return (Array { a | scriptID : Maybe Int }) msg sub
init fn return =
    Array.foldl
        (\state ret ->
            case state.scriptID of
                Just id ->
                    Return.script (fn id state) ret

                _ ->
                    ret
        )
        return
        return.value


doSync : Bool -> Maybe Int -> Maybe Int -> Return Vector msg sub -> Return Vector msg sub
doSync sync sectionID vectorID ret =
    if not sync then
        ret

    else
        case ( sectionID, vectorID ) of
            ( Nothing, _ ) ->
                ret

            ( Just _, Nothing ) ->
                ret
                    |> Return.batchEvents
                        (ret.value
                            |> Array.toList
                            |> List.indexedMap Sync.event
                        )

            ( Just _, Just id ) ->
                ret
                    |> Return.batchEvent
                        (ret.value
                            |> Array.get id
                            |> Maybe.map (Sync.event id)
                            |> Maybe.withDefault Event.none
                        )
