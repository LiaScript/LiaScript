module Lia.PState exposing (PState, init)

--import Combine exposing (Parser, skip, string)

import Array
import Lia.Code.Types exposing (CodeVector)
import Lia.Quiz.Types exposing (QuizVector)
import Lia.Survey.Types exposing (SurveyVector)


type alias PState =
    { identation : Int
    , skip_identation : Bool
    , num_effects : Int
    , code_temp : ( String, String ) -- Lang Code
    , code_vector : CodeVector
    , quiz_vector : QuizVector
    , survey_vector : SurveyVector
    }


init : PState
init =
    { identation = 0
    , skip_identation = False
    , num_effects = 0
    , code_temp = ( "", "" )
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    }
