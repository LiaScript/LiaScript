module Lia.Markdown.Quiz.Update exposing (Msg(..), handle, update)

import Array
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Json as Json
import Lia.Markdown.Quiz.MultipleChoice.Update as MultipleChoice
import Lia.Markdown.Quiz.MultipleChoiceMatrix.Update as MultipleChoiceMatrix
import Lia.Markdown.Quiz.SingleChoice.Update as SingleChoice
import Lia.Markdown.Quiz.Types exposing (Element, Solution(..), State(..), Type, Vector, comp, toState)


type Msg
    = Block_Update Int Block.Msg
    | SingleChoice_Update Int SingleChoice.Msg
    | MultipleChoice_Update Int MultipleChoice.Msg
    | MultipleChoiceMatrix_Update Int MultipleChoiceMatrix.Msg
    | Check Int Type (Maybe String)
    | ShowHint Int
    | ShowSolution Int Type
    | Handle Event


update : Msg -> Vector -> ( Vector, List Event )
update msg vector =
    case msg of
        Block_Update id _ ->
            ( update_ id vector (state_ msg), [] )

        SingleChoice_Update id _ ->
            ( update_ id vector (state_ msg), [] )

        MultipleChoice_Update id _ ->
            ( update_ id vector (state_ msg), [] )

        MultipleChoiceMatrix_Update id _ ->
            ( update_ id vector (state_ msg), [] )

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

                        Just (SingleChoice_State s) ->
                            SingleChoice.toString s

                        Just (MultipleChoice_State m) ->
                            MultipleChoice.toString m

                        _ ->
                            ""
            in
            ( vector, [ Event.eval idx code [ state ] ] )

        ShowHint idx ->
            (\e -> { e | hint = e.hint + 1 })
                |> update_ idx vector
                |> store

        ShowSolution idx solution ->
            (\e -> { e | state = toState solution, solved = ReSolved, error_msg = "" })
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
                    )

                _ ->
                    ( vector, [] )


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


update_ : Int -> Vector -> (Element -> Element) -> Vector
update_ idx vector f =
    case get idx vector of
        Just elem ->
            Array.set idx (f elem) vector

        _ ->
            vector


state_ : Msg -> Element -> Element
state_ msg e =
    { e
        | state =
            case ( msg, e.state ) of
                ( Block_Update _ m, Block_State s ) ->
                    s
                        |> Block.update m
                        |> Block_State

                ( SingleChoice_Update _ m, SingleChoice_State s ) ->
                    s
                        |> SingleChoice.update m
                        |> SingleChoice_State

                ( MultipleChoice_Update _ m, MultipleChoice_State s ) ->
                    s
                        |> MultipleChoice.update m
                        |> MultipleChoice_State

                ( MultipleChoiceMatrix_Update _ m, MultipleChoiceMatrix_State s ) ->
                    s
                        |> MultipleChoiceMatrix.update m
                        |> MultipleChoiceMatrix_State

                _ ->
                    e.state
    }


handle : Event -> Msg
handle =
    Handle


evalEventDecoder : JE.Value -> (Element -> Element)
evalEventDecoder json =
    let
        eval =
            Event.evalDecode json
    in
    if eval.ok then
        if eval.result == "true" then
            \e ->
                { e
                    | trial = e.trial + 1
                    , solved = Solved
                    , error_msg = ""
                }

        else
            \e ->
                { e
                    | trial = e.trial + 1
                    , solved = Open
                    , error_msg = ""
                }

    else
        \e -> { e | error_msg = eval.result }


store : Vector -> ( Vector, List Event )
store vector =
    ( vector
    , vector
        |> Json.fromVector
        |> Event.store
        |> List.singleton
    )


check : Type -> Element -> Element
check solution e =
    { e
        | trial = e.trial + 1
        , solved = comp solution e.state
    }
