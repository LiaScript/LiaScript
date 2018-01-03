module Lia.Quiz.Update exposing (Msg(..), update)

import Array
import Json.Encode as JE
import Lia.Quiz.Model exposing (Model, model2json)
import Lia.Quiz.Types exposing (..)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int State
    | ShowHint Int
    | ShowSolution Int State


update : Msg -> Model -> ( Model, Maybe JE.Value )
update msg model =
    case msg of
        CheckBox idx question_id ->
            ( flip_check idx question_id model, Nothing )

        RadioButton idx answer ->
            ( flip_check idx answer model, Nothing )

        Input idx string ->
            ( update_input idx string model, Nothing )

        Check idx solution ->
            let
                new_model =
                    check_answer idx solution model
            in
            ( new_model, Just <| model2json new_model )

        ShowHint idx ->
            ( update_hint idx model, Nothing )

        ShowSolution idx solution ->
            let
                new_model =
                    update_solution idx model solution
            in
            ( new_model, Just <| model2json new_model )


get : Int -> Vector -> Maybe Element
get idx model =
    case Array.get idx model of
        Just elem ->
            if (elem.solved == Solved) || (elem.solved == ReSolved) then
                Nothing
            else
                Just elem

        _ ->
            Nothing


update_input : Int -> String -> Vector -> Vector
update_input idx text vector =
    case get idx vector of
        Just elem ->
            case elem.state of
                TextState _ ->
                    Array.set idx { elem | state = TextState text } vector

                _ ->
                    vector

        _ ->
            vector


update_hint : Int -> Vector -> Vector
update_hint idx vector =
    case get idx vector of
        Just elem ->
            Array.set idx { elem | hint = elem.hint + 1 } vector

        _ ->
            vector


update_solution : Int -> Vector -> State -> Vector
update_solution idx vector quiz_solution =
    case get idx vector of
        Just elem ->
            Array.set idx
                { elem
                    | state = quiz_solution
                    , solved = ReSolved
                }
                vector

        _ ->
            vector


flip_check : Int -> Int -> Vector -> Vector
flip_check idx question_id vector =
    case get idx vector of
        Just elem ->
            case elem.state of
                SingleChoiceState _ ->
                    Array.set idx { elem | state = SingleChoiceState question_id } vector

                MultipleChoiceState quiz ->
                    case Array.get question_id quiz of
                        Just question ->
                            question
                                |> (\c -> not c)
                                |> (\q -> Array.set question_id q quiz)
                                |> (\q -> Array.set idx { elem | state = MultipleChoiceState q } vector)

                        Nothing ->
                            vector

                _ ->
                    vector

        _ ->
            vector


check_answer : Int -> State -> Vector -> Vector
check_answer idx solution vector =
    case get idx vector of
        Just elem ->
            Array.set idx
                { elem
                    | trial = elem.trial + 1
                    , solved =
                        if elem.state == solution then
                            Solved
                        else
                            Open
                }
                vector

        Nothing ->
            vector
