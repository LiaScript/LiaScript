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
import Port.Eval as Eval
import Port.Event as Event exposing (Event)
import Return exposing (Return)
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

        ShowHint idx ->
            (\e -> Return.val { e | hint = e.hint + 1 })
                |> update_ idx vector
                |> store

        ShowSolution id solution ->
            (\e -> Return.val { e | state = toState solution, solved = Solution.ReSolved, error_msg = "" })
                >> syncSolution id
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

        Handle event ->
            case Event.topicWithId event of
                Just ( "eval", Just section ) ->
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
                                |> Return.script
                                    (message
                                        |> Event.initWithId "code" scriptID
                                        |> JS.handle
                                    )

                        Nothing ->
                            event
                                |> Event.message
                                |> evalEventDecoder
                                |> update_ section vector
                                |> store

                Just ( "restore", _ ) ->
                    event
                        |> Event.message
                        |> Json.toVector
                        |> Result.map (merge vector)
                        |> Result.withDefault vector
                        |> Return.val
                        |> init (\i s -> execute i s.state)

                Just ( "sync", _ ) ->
                    event
                        |> Event.pop
                        |> Maybe.map (Tuple.second >> syncUpdate vector)
                        |> Maybe.withDefault (Return.val vector)

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


syncUpdate : Vector -> Event -> Return Vector msg sub
syncUpdate vector event =
    case
        event
            |> Event.topicWithId
            |> syncGet vector
    of
        Just ( topic, id, element ) ->
            Array.set id
                { element
                    | sync =
                        Just <|
                            syncUpdateHelper topic event.message <|
                                case element.sync of
                                    Nothing ->
                                        { solved = 0, resolved = 0 }

                                    Just sync ->
                                        sync
                }
                vector
                |> Return.val

        _ ->
            Return.val vector


syncGet : Vector -> Maybe ( String, Maybe Int ) -> Maybe ( String, Int, Element )
syncGet vector conf =
    case conf of
        Just ( topic, Just id ) ->
            case Array.get id vector of
                Just elem ->
                    Just ( topic, id, elem )

                _ ->
                    Nothing

        _ ->
            Nothing


syncUpdateHelper : String -> JE.Value -> { solved : Int, resolved : Int } -> { solved : Int, resolved : Int }
syncUpdateHelper topic _ sync =
    case topic of
        "solved" ->
            { sync | solved = sync.solved + 1 }

        "resolved" ->
            { sync | resolved = sync.resolved + 1 }

        _ ->
            sync


syncSolution : Int -> Return Element msg sub -> Return Element msg sub
syncSolution id ret =
    case ret.value.solved of
        Solution.Solved ->
            Return.sync (Event.initWithId "solved" id (JE.int ret.value.trial)) ret

        Solution.ReSolved ->
            Return.sync (Event.initWithId "resolved" id JE.null) ret

        _ ->
            ret


execute : Int -> State -> Script.Msg sub
execute id =
    toString >> JS.run id


get : Int -> Vector -> Maybe Element
get idx vector =
    case Array.get idx vector of
        Just elem ->
            --if (elem.solved == Solution.Solved) || (elem.solved == Solution.ReSolved) then
            --    Nothing
            --else
            Just elem

        _ ->
            Nothing


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
