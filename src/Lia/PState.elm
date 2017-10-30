module Lia.PState exposing (PState, init)

--import Combine exposing (Parser, skip, string)

import Array
import Dict
import Lia.Code.Types exposing (Codes)
import Lia.Quiz.Types exposing (QuizVector)
import Lia.Survey.Types exposing (SurveyVector)


type alias PState =
    { identation : Int
    , skip_identation : Bool
    , num_effects : Int
    , code_vector : Codes
    , quiz_vector : QuizVector
    , survey_vector : SurveyVector
    , def_author : String
    , def_date : String
    , def_email : String
    , def_language : String
    , def_narrator : String
    , def_version : String
    , def_comment : String
    , def_scripts : List String
    }


init : PState
init =
    { identation = 0
    , skip_identation = False
    , num_effects = 0
    , code_vector = Dict.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , def_author = ""
    , def_date = ""
    , def_email = ""
    , def_language = ""
    , def_narrator = ""
    , def_version = ""
    , def_comment = ""
    , def_scripts = []
    }
