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
    | Select Int Int
    | SelectToggle Int
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

        SelectToggle id ->
            ( update_ id vector selectToggle, [] )

        Check idx solution Nothing ->
            selectClose
                >> (\e ->
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
                        Just (State_Text str) ->
                            str

                        Just (State_Selection i _) ->
                            String.fromInt i

                        Just (State_SingleChoice i) ->
                            String.fromInt i

                        Just (State_MultipleChoice list) ->
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
        State_Text _ ->
            { e | state = State_Text text }

        _ ->
            e


select : Int -> Element -> Element
select option e =
    case e.state of
        State_Selection _ _ ->
            { e | state = State_Selection option False }

        _ ->
            e


selectToggle : Element -> Element
selectToggle e =
    case e.state of
        State_Selection i b ->
            { e | state = State_Selection i <| not b }

        _ ->
            e


selectClose : Element -> Element
selectClose e =
    case e.state of
        State_Selection i _ ->
            { e | state = State_Selection i False }

        _ ->
            e


flip : Int -> Element -> Element
flip question_id e =
    case e.state of
        State_SingleChoice _ ->
            { e | state = State_SingleChoice question_id }

        State_MultipleChoice quiz ->
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
                        |> (\q -> { e | state = State_MultipleChoice q })

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
