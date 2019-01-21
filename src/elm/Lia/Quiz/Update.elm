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


update : Msg -> Vector -> ( Vector, Maybe JE.Value )
update msg vector =
    case msg of
        CheckBox idx question_id ->
            ( update_ idx vector (flip question_id), Nothing )

        RadioButton idx answer ->
            ( update_ idx vector (flip answer), Nothing )

        Input idx string ->
            ( update_ idx vector (input string), Nothing )

        Check idx solution Nothing ->
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
            ( new_vector, Just <| vectorToJson new_vector )

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

                        Just EmptyState ->
                            ""

                        _ ->
                            ""
            in
            ( vector, Nothing )

        {-
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
                                                       String.fromInt i

                                                   MultipleChoiceState array ->
                                                       array
                                                           |> Array.map
                                                               (\s ->
                                                                   if s then
                                                                       "1"

                                                                   else
                                                                       "0"
                                                               )
                                                           |> Array.toList
                                                           |> List.intersperse ","
                                                           |> List.concat
                                                           |> (\str -> "[" ++ str ++ "]")

                                                   _ ->
                                                       e.state
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
               ( new_vector, Just <| vectorToJson new_vector )
        -}
        ShowHint idx ->
            let
                new_vector =
                    update_ idx vector (\e -> { e | hint = e.hint + 1 })
            in
            ( new_vector, Just <| vectorToJson new_vector )

        ShowSolution idx solution ->
            let
                new_vector =
                    update_ idx vector (\e -> { e | state = solution, solved = ReSolved, error_msg = "" })
            in
            ( new_vector, Just <| vectorToJson new_vector )

        Handle event ->
            case event.topic of
                "restore" ->
                    ( event.message
                        |> jsonToVector
                        |> Result.withDefault vector
                    , Nothing
                    )

                _ ->
                    ( vector, Nothing )


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
