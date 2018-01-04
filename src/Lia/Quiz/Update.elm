module Lia.Quiz.Update exposing (Msg(..), update)

import Array
import Json.Encode as JE
import Lia.Quiz.Model exposing (vector2json)
import Lia.Quiz.Types exposing (..)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int State
    | ShowHint Int
    | ShowSolution Int State


update : Msg -> Vector -> ( Vector, Maybe JE.Value )
update msg vector =
    case msg of
        CheckBox idx question_id ->
            ( update_ idx vector (flip question_id), Nothing )

        RadioButton idx answer ->
            ( update_ idx vector (flip answer), Nothing )

        Input idx string ->
            ( update_ idx vector (input string), Nothing )

        Check idx solution ->
            let
                new_vector =
                    update_ idx
                        vector
                        (\e ->
                            { e
                                | trial = e.trial + 1
                                , solved =
                                    if e.state == solution then
                                        Solved
                                    else
                                        Open
                            }
                        )
            in
            ( new_vector, Just <| vector2json new_vector )

        ShowHint idx ->
            ( update_ idx vector (\e -> { e | hint = e.hint + 1 }), Nothing )

        ShowSolution idx solution ->
            let
                new_vector =
                    update_ idx vector (\e -> { e | state = solution, solved = ReSolved })
            in
            ( new_vector, Just <| vector2json new_vector )


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


input : String -> Element -> Element
input text e =
    case e.state of
        TextState _ ->
            { e | state = TextState text }

        _ ->
            e


flip : Int -> Element -> Element
flip question_id e =
    case e.state of
        SingleChoiceState _ ->
            { e | state = SingleChoiceState question_id }

        MultipleChoiceState quiz ->
            case Array.get question_id quiz of
                Just question ->
                    question
                        |> (\c -> not c)
                        |> (\q -> Array.set question_id q quiz)
                        |> (\q -> { e | state = MultipleChoiceState q })

                Nothing ->
                    e

        _ ->
            e
