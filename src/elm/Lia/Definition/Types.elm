module Lia.Definition.Types exposing
    ( Definition
    , Resource(..)
    , addToResources
    , add_imports
    , add_macros
    , add_translation
    , default
    , get_translations
    , toURL
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
    , imports : List String
    , section : Int
    , uid : Int
    , debug : Bool
    , onload : String
    }


default : String -> Definition
default base =
    { author = ""
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
    , imports = []
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
                    Dict.insert lang (toURL def.base url) def.translation
            }

        _ ->
            def


get_translations : Definition -> List ( String, String )
get_translations def =
    Dict.toList def.translation


add_macros : Definition -> Definition -> Definition
add_macros orig temp =
    { orig
        | macro = Dict.union orig.macro temp.macro
        , onload = String.trim (orig.onload ++ "\n" ++ temp.onload)
    }


add_imports : String -> Definition -> Definition
add_imports url def =
    { def
        | imports =
            url
                |> String.split "\n"
                |> List.map (toURL def.base)
                |> List.append def.imports
    }


toURL : String -> String -> String
toURL basis url =
    if String.startsWith "http" url then
        url

    else
        basis ++ url


addToResources : (String -> Resource) -> String -> Definition -> Definition
addToResources to urls def =
    { def | resources = append to def.base urls def.resources }


append : (String -> a) -> String -> String -> List a -> List a
append to base urls list =
    urls
        |> String.split "\n"
        |> List.map (toURL base >> to)
        |> List.append list
