module Lia.Definition.Types exposing
    ( Definition
    , add_translation
    , default
    , get_translations
    )

import Dict exposing (Dict)


type alias Definition =
    { author : String
    , date : String
    , email : String
    , language : String
    , narrator : String
    , version : String
    , comment : String
    , scripts : List String
    , links : List String
    , base : String
    , translation : Dict String String
    , macro : Dict String String
    , section : Int
    , uid : Int
    }


default : String -> Definition
default base =
    { author = "Unknown"
    , date = ""
    , email = ""
    , language = "en"
    , narrator = "US English Male"
    , version = ""
    , comment = ""
    , scripts = []
    , links = []
    , base = base
    , translation = Dict.empty
    , macro = Dict.empty
    , section = -1
    , uid = -1
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
