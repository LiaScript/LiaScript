module Lia.PState exposing (PState, init)

import Array
import Lia.Quiz.Types exposing (QuizVector)


type alias PState =
    { section : List Int
    , identation : Int
    , skip_identation : Bool
    , num_effects : Int
    , num_code : Int
    , num_quiz : Int
    , quiz_vector : QuizVector
    , def_author : String
    , def_date : String
    , def_email : String
    , def_language : String
    , def_narator : String
    , def_version : String
    , def_comment : String
    }


init : PState
init =
    { section = []
    , identation = 0
    , skip_identation = False
    , num_effects = 0
    , num_code = 0
    , num_quiz = 0
    , quiz_vector = Array.empty
    , def_author = ""
    , def_date = ""
    , def_email = ""
    , def_language = ""
    , def_narator = ""
    , def_version = ""
    , def_comment = ""
    }
