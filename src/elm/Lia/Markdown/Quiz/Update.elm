module Lia.Markdown.Quiz.Update exposing (Msg(..), handle, update)

import Array
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types exposing (Scripts, outputs)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Json as Json
import Lia.Markdown.Quiz.Matrix.Update as Matrix
import Lia.Markdown.Quiz.Types exposing (Element, Solution(..), State(..), Type, Vector, comp, toState)
import Lia.Markdown.Quiz.Vector.Update as Vector
import Port.Eval as Eval
import Port.Event as Event exposing (Event)


type Msg sub
    = Block_Update Int (Block.Msg sub)
    | Vector_Update Int (Vector.Msg sub)
    | Matrix_Update Int (Matrix.Msg sub)
    | Check Int Type (Maybe String)
    | ShowHint Int
    | ShowSolution Int Type
    | Handle Event
    | Script (Script.Msg sub)


update : Scripts a -> Msg sub -> Vector -> ( Vector, List Event, Maybe (Script.Msg sub) )
update scripts msg vector =
    case msg of
        Block_Update id _ ->
            update_ id vector (state_ msg)

        Vector_Update id _ ->
            update_ id vector (state_ msg)

        Matrix_Update id _ ->
            update_ id vector (state_ msg)

        Check id solution Nothing ->
            check solution
                |> update_ id vector
                |> store

        Check idx _ (Just code) ->
            let
                state =
                    case
                        vector
                            |> Array.get idx
                            |> Maybe.map .state
                    of
                        Just (Block_State b) ->
                            Block.toString b

                        Just (Vector_State s) ->
                            Vector.toString s

                        Just (Matrix_State m) ->
                            Matrix.toString m

                        _ ->
                            ""
            in
            ( vector
            , [ Eval.event idx
                    code
                    (outputs scripts)
                    [ state ]
              ]
            , Nothing
            )

        ShowHint idx ->
            (\e -> ( { e | hint = e.hint + 1 }, Nothing ))
                |> update_ idx vector
                |> store

        ShowSolution idx solution ->
            (\e -> ( { e | state = toState solution, solved = ReSolved, error_msg = "" }, Nothing ))
                |> update_ idx vector
                |> store

        Handle event ->
            case event.topic of
                "eval" ->
                    event.message
                        |> evalEventDecoder
                        |> update_ event.section vector
                        |> store

                "restore" ->
                    ( event.message
                        |> Json.toVector
                        |> Result.withDefault vector
                    , []
                    , Nothing
                    )

                _ ->
                    ( vector, [], Nothing )

        Script sub ->
            ( vector, [], Just sub )


get : Int -> Vector -> Maybe Element
get idx vector =
    case Array.get idx vector of
        Just elem ->
            if (elem.solved == Solved) || (elem.solved == ReSolved) then
                Nothing

            else
                Just elem

        _ ->
            Nothing


update_ :
    Int
    -> Vector
    -> (Element -> ( Element, Maybe (Script.Msg sub) ))
    -> ( Vector, List Event, Maybe (Script.Msg sub) )
update_ idx vector fn =
    case get idx vector |> Maybe.map fn of
        Just ( elem, sub ) ->
            ( Array.set idx elem vector, [], sub )

        _ ->
            ( vector, [], Nothing )


state_ : Msg sub -> Element -> ( Element, Maybe (Script.Msg sub) )
state_ msg e =
    case ( msg, e.state ) of
        ( Block_Update _ m, Block_State s ) ->
            s
                |> Block.update m
                |> Tuple.mapFirst (setState e Block_State)

        ( Vector_Update _ m, Vector_State s ) ->
            s
                |> Vector.update m
                |> Tuple.mapFirst (setState e Vector_State)

        ( Matrix_Update _ m, Matrix_State s ) ->
            s
                |> Matrix.update m
                |> Tuple.mapFirst (setState e Matrix_State)

        _ ->
            ( e, Nothing )


setState : Element -> (s -> State) -> s -> Element
setState e fn state =
    { e | state = fn state }


handle : Event -> Msg sub
handle =
    Handle


evalEventDecoder : JE.Value -> (Element -> ( Element, Maybe sub ))
evalEventDecoder json =
    let
        eval =
            Eval.decode json
    in
    if eval.ok then
        if eval.result == "true" then
            \e ->
                ( { e
                    | trial = e.trial + 1
                    , solved = Solved
                    , error_msg = ""
                  }
                , Nothing
                )

        else
            \e ->
                ( { e
                    | trial = e.trial + 1
                    , solved = Open
                    , error_msg = ""
                  }
                , Nothing
                )

    else
        \e -> ( { e | error_msg = eval.result }, Nothing )


store : ( Vector, List Event, Maybe (Script.Msg sub) ) -> ( Vector, List Event, Maybe (Script.Msg sub) )
store ( vector, events, sub ) =
    ( vector
    , (vector
        |> Json.fromVector
        |> Event.store
      )
        :: events
    , sub
    )


check : Type -> Element -> ( Element, Maybe (Script.Msg sub) )
check solution e =
    ( { e
        | trial = e.trial + 1
        , solved = comp solution e.state
      }
    , Nothing
    )
