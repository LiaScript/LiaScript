module Lia.Definition.Types
    exposing
        ( Definition
        , add_macro
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
    , base : String
    , translation : Dict String String
    , macro : Dict String String
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
    , translation = Dict.empty
    , macro = Dict.empty
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


add_macro : ( String, String ) -> Definition -> Definition
add_macro ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


get_translations : Definition -> List ( String, String )
get_translations def =
    Dict.toList def.translation
