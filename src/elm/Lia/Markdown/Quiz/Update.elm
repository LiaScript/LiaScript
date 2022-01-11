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
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types exposing (Element, State(..), Type(..), Vector, comp, toState)
import Lia.Markdown.Quiz.Vector.Update as Vector
import Return exposing (Return)
import Service.Eval as Eval
import Service.Event as Event exposing (Event)
import Translations exposing (Lang(..))


type Msg sub
    = Block_Update Int (Block.Msg sub)
    | Vector_Update Int (Vector.Msg sub)
    | Matrix_Update Int (Matrix.Msg sub)
    | Check Int Type
    | ShowHint Int
    | ShowSolution Int Type
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> Return Vector msg sub
update scripts msg vector =
    case msg of
        Block_Update id _ ->
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
                                >> syncSolution id
                                |> update_ id vector
                                |> store
                                |> Return.doSync

                        Just scriptID ->
                            vector
                                |> Return.val
                                --|> Return.script (execute scriptID e)
                                |> Return.batchEvents
                                    (case
                                        scripts
                                            |> Array.get scriptID
                                            |> Maybe.map .script
                                     of
                                        Just code ->
                                            [ [ toString e.state ]
                                                |> Eval.event id code (outputs scripts)
                                            ]

                                        Nothing ->
                                            []
                                    )

                Nothing ->
                    vector
                        |> Return.val

        Check id solution Nothing ->
            check solution
                >> syncSolution id
                |> update_ id vector
                |> store

        ShowHint idx ->
            (\e -> Return.val { e | hint = e.hint + 1 })
                |> update_ idx vector
                |> store

        ShowSolution id solution ->
            (\e -> Return.val { e | state = toState solution, solved = Solution.ReSolved, error_msg = "" })
                |> update_ id vector
                |> store
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
                |> Return.doSync

        Handle event ->
            case Event.topicWithId event of
                Just ( "eval", section ) ->
                    case
                        vector
                            |> Array.get section
                            |> Maybe.andThen .scriptID
                    of
                        Just scriptID ->
                            let
                                message =
                                    Event.message event
                            in
                            message
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store
                                |> Return.doSync
                                |> Return.script
                                    (message
                                        |> Event.initWithId Nothing "code" scriptID
                                        |> JS.handle
                                    )

                        Nothing ->
                            event
                                |> Event.message
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store
                                |> Return.doSync

                Just ( "restore", _ ) ->
                    event
                        |> Event.message
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init (\i s -> execute i s.state)
                        |> Return.doSync

                {- |> (\ret ->
                        case sync of
                            Nothing ->
                                ret

                            Just sync_ ->
                                let
                                    ( vector_, events ) =
                                        synchronize sync_ ret.value
                                in
                                vector_
                                    |> Return.replace ret
                                    |> Return.syncAppend events
                   )
                -}
                {- Just ( "sync", Just section ) ->
                   event
                       |> Event.message
                       |> syncUpdate vector section
                -}
                _ ->
                    Return.val vector

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



{-
   syncUpdate : Vector -> Int -> JE.Value -> Return Vector msg sub
   syncUpdate vector id state =
       case
           ( Array.get id vector
           , Container.decode Synchronization.decoder state
           )
       of
           ( Just element, Ok sync ) ->
               case Container.union element.sync sync of
                   ( True, _ ) ->
                       vector
                           |> Return.val

                   ( False, union ) ->
                       vector
                           |> Array.set id { element | sync = union }
                           |> Return.val
                           |> Return.sync (Event.initWithId "sync" id (Container.encode Synchronization.encoder union))

           _ ->
               Return.val vector
-}
{-
   syncSolution : Int -> Sync.Settings -> Return Element msg sub -> Return Element msg sub
   syncSolution id sync ret =
       case Synchronization.toState ret.value of
           Just syncState ->
               case Sync.insert sync syncState ret.value.sync of
                   ( False, newSync ) ->
                       ret
                           |> Return.mapVal (\v -> { v | sync = newSync })
                           |> Return.syncMsg id (Container.encode Synchronization.encoder newSync)

                   _ ->
                       ret

           _ ->
               ret
-}
{-
   synchronize : Sync.Settings -> Vector -> ( Vector, List Event )
   synchronize sync vector =
       vector
           |> Array.indexedMap (\i -> Return.val >> syncSolution i sync)
           |> Array.map (\ret -> ( ret.value, ret.synchronize ))
           |> Array.toList
           |> List.unzip
           |> Tuple.mapSecond List.concat
           |> Tuple.mapFirst Array.fromList
-}


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
            Eval.decode json
    in
    if eval.ok then
        if eval.result == "true" then
            \e ->
                Return.val <|
                    if e.solved == Solution.Open then
                        { e
                            | trial = e.trial + 1
                            , solved = Solution.Solved
                            , error_msg = ""
                        }

                    else
                        e

        else if String.startsWith "LIA:" eval.result then
            Return.val

        else
            \e ->
                Return.val <|
                    if e.solved == Solution.Open then
                        { e
                            | trial = e.trial + 1
                            , solved = Solution.Open
                            , error_msg = ""
                        }

                    else
                        e

    else
        \e -> Return.val { e | error_msg = eval.result }


store : Return Vector msg sub -> Return Vector msg sub
store return =
    return
        |> Return.batchEvent
            (return.value
                |> Json.fromVector
                |> Event.store
            )


check : Type -> Element -> Return Element msg sub
check solution e =
    { e
        | trial = e.trial + 1
        , solved = comp solution e.state
    }
        |> Return.val


merge : Array { a | scriptID : Maybe Int } -> Array { a | scriptID : Maybe Int } -> Array { a | scriptID : Maybe Int }
merge v1 =
    Array.toList
        >> List.map2 (\sID body -> { body | scriptID = sID.scriptID }) (Array.toList v1)
        >> Array.fromList


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
