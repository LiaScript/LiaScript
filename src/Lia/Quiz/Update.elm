module Lia.Quiz.Update exposing (Msg(..), update)

import Array
import Json.Encode as JE
import Lia.Quiz.Model exposing (json2vector, vector2json)
import Lia.Quiz.Types exposing (..)
import Lia.Utils exposing (evaluateJS, string_replace)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int State (Maybe String)
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

        Check idx solution eval_string ->
            let
                new_vector =
                    update_ idx
                        vector
                        (\e ->
                            case eval_string of
                                Nothing ->
                                    { e
                                        | trial = e.trial + 1
                                        , solved =
                                            if e.state == solution then
                                                Solved

                                            else
                                                Open
                                    }

                                Just code ->
                                    let
                                        state =
                                            case e.state of
                                                TextState str ->
                                                    str

                                                SingleChoiceState i ->
                                                    toString i

                                                MultipleChoiceState array ->
                                                    array
                                                        |> Array.map
                                                            (\s ->
                                                                if s then
                                                                    1

                                                                else
                                                                    0
                                                            )
                                                        |> Array.toList
                                                        |> toString

                                                _ ->
                                                    toString e.state
                                    in
                                    case code |> string_replace ( "@input", state ) |> evaluateJS of
                                        Ok "true" ->
                                            { e
                                                | trial = e.trial + 1
                                                , solved = Solved
                                                , error_msg = ""
                                            }

                                        Ok _ ->
                                            { e
                                                | trial = e.trial + 1
                                                , solved = Open
                                                , error_msg = ""
                                            }

                                        Err msg ->
                                            { e | error_msg = msg }
                        )
            in
            ( new_vector, Just <| vector2json new_vector )

        ShowHint idx ->
            let
                new_vector =
                    update_ idx vector (\e -> { e | hint = e.hint + 1 })
            in
            ( new_vector, Just <| vector2json new_vector )

        ShowSolution idx solution ->
            let
                new_vector =
                    update_ idx vector (\e -> { e | state = solution, solved = ReSolved, error_msg = "" })
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
