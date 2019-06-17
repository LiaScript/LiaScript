module Lia.Markdown.Quiz.Update exposing (Msg(..), handle, update)

import Array
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Quiz.Json as Json
import Lia.Markdown.Quiz.Types exposing (Element, Solution(..), State(..), Vector)


type Msg
    = CheckBox Int Int
    | RadioButton Int Int
    | Input Int String
    | Select Int String
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

        Select idx option ->
            ( update_ idx vector (select option), [] )

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

        Check idx _ (Just code) ->
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
            ( vector, [ Event.eval idx code [ state ] ] )

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


input : String -> Element -> Element
input text e =
    case e.state of
        TextState _ ->
            { e | state = TextState text }

        _ ->
            e


select : String -> Element -> Element
select option e =
    case e.state of
        SelectionState _ ->
            { e | state = SelectionState option }

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
