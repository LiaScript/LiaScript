module Lia.Quiz.Update exposing (Msg(..), update)

import Array
import Lia.Quiz.Model exposing (Model)
import Lia.Quiz.Type exposing (..)


--import Lia.Helper exposing (get_slide_effects)
--import Lia.Index
--import Lia.Model exposing (..)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int
    | ShowHint Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckBox idx question_id ->
            ( flip_checkbox idx question_id model, Cmd.none )

        RadioButton idx answer ->
            ( flip_checkbox idx answer model, Cmd.none )

        Input idx string ->
            ( update_input idx string model, Cmd.none )

        Check idx ->
            ( check_answer idx model, Cmd.none )

        ShowHint idx ->
            ( update_hint idx model, Cmd.none )


get : Int -> QuizVector -> Maybe QuizElement
get idx model =
    case Array.get idx model of
        Just elem ->
            if elem.solved == Just True then
                Nothing
            else
                Just elem

        _ ->
            Nothing


update_input : Int -> String -> QuizVector -> QuizVector
update_input idx text vector =
    case get idx vector of
        Just elem ->
            case elem.state of
                Text input answer ->
                    Array.set idx { elem | state = Text text answer } vector

                _ ->
                    vector

        _ ->
            vector


update_hint : Int -> QuizVector -> QuizVector
update_hint idx vector =
    case get idx vector of
        Just elem ->
            Array.set idx { elem | hint = elem.hint + 1 } vector

        _ ->
            vector


flip_checkbox : Int -> Int -> QuizVector -> QuizVector
flip_checkbox idx question_id vector =
    case get idx vector of
        Just elem ->
            case elem.state of
                Single c answer ->
                    Array.set idx { elem | state = Single question_id answer } vector

                Multi quiz ->
                    case Array.get question_id quiz of
                        Just question ->
                            question
                                |> (\( c, a ) -> ( not c, a ))
                                |> (\q -> Array.set question_id q quiz)
                                |> (\q -> Array.set idx { elem | state = Multi q } vector)

                        Nothing ->
                            vector

                _ ->
                    vector

        _ ->
            vector


check_answer : Int -> QuizVector -> QuizVector
check_answer idx vector =
    let
        ccheck state =
            case state of
                Multi quiz ->
                    let
                        f ( input, answer ) result =
                            result && (input == answer)
                    in
                    Just (Array.foldr f True quiz)

                Single input answer ->
                    Just (input == answer)

                Text input answer ->
                    Just (input == answer)
    in
    case get idx vector of
        Just elem ->
            Array.set idx { elem | solved = ccheck elem.state, trial = elem.trial + 1 } vector

        Nothing ->
            vector
