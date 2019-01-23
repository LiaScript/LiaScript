module Lia.Quiz.Update exposing (Msg(..), handle, update)

import Array exposing (Array)
import Json.Encode as JE
import Lia.Event exposing (..)
import Lia.Quiz.Json exposing (..)
import Lia.Quiz.Types exposing (..)
import Lia.Utils exposing (string_replace)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Check Int State (Maybe String)
    | ShowHint Int
    | ShowSolution Int State
    | Handle Event


update : Msg -> Vector -> ( Vector, List Event )
update msg vector =
    case msg of
        CheckBox idx question_id ->
            ( update_ idx vector (flip question_id), [] )

        RadioButton idx answer ->
            ( update_ idx vector (flip answer), [] )

        Input idx string ->
            ( update_ idx vector (input string), [] )

        Check idx solution Nothing ->
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
                |> update_ idx vector
                |> store

        Check idx solution (Just code) ->
            let
                state =
                    case vector |> Array.get idx |> Maybe.map .state of
                        Just (TextState str) ->
                            str

                        Just (SingleChoiceState i) ->
                            String.fromInt i

                        Just (MultipleChoiceState list) ->
                            list
                                |> List.map
                                    (\s ->
                                        if s then
                                            "1"

                                        else
                                            "0"
                                    )
                                |> List.intersperse ","
                                |> String.concat
                                |> (\str -> "[" ++ str ++ "]")

                        _ ->
                            ""
            in
            ( vector, [ evalEvent idx code state ] )

        ShowHint idx ->
            (\e -> { e | hint = e.hint + 1 })
                |> update_ idx vector
                |> store

        ShowSolution idx solution ->
            (\e -> { e | state = solution, solved = ReSolved, error_msg = "" })
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
                        |> jsonToVector
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
            let
                array =
                    Array.fromList quiz
            in
            case Array.get question_id array of
                Just question ->
                    question
                        |> (\c -> not c)
                        |> (\q -> Array.set question_id q array)
                        |> Array.toList
                        |> (\q -> { e | state = MultipleChoiceState q })

                Nothing ->
                    e

        _ ->
            e


handle : Event -> Msg
handle =
    Handle


evalEventDecoder : JE.Value -> (Element -> Element)
evalEventDecoder message =
    case decodeEval message of
        Ok (Eval "true" _) ->
            \e ->
                { e
                    | trial = e.trial + 1
                    , solved = Solved
                    , error_msg = ""
                }

        Ok (Eval _ _) ->
            \e ->
                { e
                    | trial = e.trial + 1
                    , solved = Open
                    , error_msg = ""
                }

        Err (Eval result _) ->
            \e -> { e | error_msg = result }


store : Vector -> ( Vector, List Event )
store vector =
    ( vector
    , vector
        |> vectorToJson
        |> storeEvent
        |> List.singleton
    )
