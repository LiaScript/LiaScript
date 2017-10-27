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
    }


default : Definition
default =
    { author = "unknown"
    , date = ""
    , email = ""
    , language = "en_US"
    , narrator = "US English Male"
    , version = "0.1.0"
    , comment = ""
    , scripts = []
    }
