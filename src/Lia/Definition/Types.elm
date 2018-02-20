module Lia.Definition.Types exposing (Definition, default)


type alias Definition =
    { author : String
    , date : String
    , email : String
    , language : String
    , narrator : String
    , version : String
    , comment : String
    , scripts : List String
    , base : String
    }


default : String -> Definition
default base =
    { author = "Unknown"
    , date = ""
    , email = ""
    , language = "en_US"
    , narrator = "US English Male"
    , version = ""
    , comment = ""
    , scripts = []
    , base = base
    }
