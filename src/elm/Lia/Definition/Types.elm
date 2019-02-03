module Lia.Definition.Types exposing
    ( Definition
    , Resource(..)
    , add_translation
    , default
    , get_translations
    )

import Dict exposing (Dict)


type Resource
    = Link String
    | Script String


type alias Definition =
    { author : String
    , date : String
    , email : String
    , language : String
    , logo : String
    , narrator : String
    , version : String
    , comment : String
    , resources : List Resource
    , base : String
    , translation : Dict String String
    , macro : Dict String String
    , borrowed : List String
    , section : Int
    , uid : Int
    , debug : Bool
    , onload : String
    }


default : String -> Definition
default base =
    { author = "Unknown"
    , date = ""
    , email = ""
    , language = "en"
    , logo = ""
    , narrator = "US English Male"
    , version = ""
    , comment = ""
    , resources = []
    , base = base
    , translation = Dict.empty
    , macro = Dict.empty
    , borrowed = []
    , section = -1
    , uid = -1
    , debug = False
    , onload = ""
    }


add_translation : String -> Definition -> Definition
add_translation str def =
    case String.words str of
        [ lang, url ] ->
            { def
                | translation =
                    Dict.insert lang
                        (if url |> String.toLower |> String.startsWith "http" then
                            url

                         else
                            def.base ++ url
                        )
                        def.translation
            }

        _ ->
            def


get_translations : Definition -> List ( String, String )
get_translations def =
    Dict.toList def.translation
