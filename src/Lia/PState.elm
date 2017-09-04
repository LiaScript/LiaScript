module Lia.PState exposing (PState, init)

import Array
import Lia.Quiz.Types exposing (QuizVector)


type alias PState =
    { quiz : Int
    , section : List Int
    , identation : Int
    , skip_identation : Bool
    , effects : Int
    , code : Int
    , def_author : String
    , def_date : String
    , def_email : String
    , def_language : String
    , def_narator : String
    , def_version : String
    , def_comment : String
    , quiz_vector : QuizVector
    }


init : PState
init =
    { quiz = 0
    , section = []
    , identation = 0
    , skip_identation = False
    , effects = 0
    , code = 0
    , def_author = ""
    , def_date = ""
    , def_email = ""
    , def_language = ""
    , def_narator = ""
    , def_version = ""
    , def_comment = ""
    , quiz_vector = Array.empty
    }
