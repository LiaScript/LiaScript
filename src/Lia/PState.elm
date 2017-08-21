module Lia.PState exposing (PState, init)


type alias PState =
    { quiz : Int
    , section : List Int
    , indentation : List Int
    , effects : Int
    }


init : PState
init =
    { quiz = 0
    , section = []
    , indentation = [ 0 ]
    , effects = 0
    }
