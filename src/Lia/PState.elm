module Lia.PState exposing (PState, init)


type alias PState =
    { quiz : Int
    , section : List Int
    , identation : Int
    , skip_identation : Bool
    , effects : Int
    }


init : PState
init =
    { quiz = 0
    , section = []
    , identation = 0
    , skip_identation = False
    , effects = 0
    }
