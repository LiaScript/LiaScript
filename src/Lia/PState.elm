module Lia.PState exposing (..)

--import Combine exposing (Parser, skip, string)

import Array
import Combine exposing (..)
import Lia.Code.Types exposing (CodeVector)
import Lia.Quiz.Types exposing (QuizVector)
import Lia.Survey.Types exposing (SurveyVector)


type alias PState =
    { identation : List String
    , identation_skip : Bool
    , num_effects : Int
    , code_temp : ( String, String ) -- Lang Code
    , code_vector : CodeVector
    , quiz_vector : QuizVector
    , survey_vector : SurveyVector
    }


init : PState
init =
    { identation = []
    , identation_skip = False
    , num_effects = 0
    , code_temp = ( "", "" )
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    }


identation : Parser PState ()
identation =
    lazy <|
        \() ->
            let
                par s =
                    if s.identation == [] then
                        succeed ()
                    else if s.identation_skip then
                        skip (succeed ())
                    else
                        String.concat s.identation
                            |> regex
                            |> skip

                reset s =
                    { s | identation_skip = False }
            in
            withState par <* modifyState reset


identation_append : String -> Parser PState ()
identation_append str =
    modifyState
        (\state ->
            { state
                | identation_skip = True
                , identation = List.append state.identation [ str ]
            }
        )


identation_pop : Parser PState ()
identation_pop =
    modifyState
        (\state ->
            { state
                | identation_skip = False
                , identation =
                    state.identation
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            }
        )


ident_skip : Parser PState ()
ident_skip =
    modifyState (\state -> { state | identation_skip = True })
