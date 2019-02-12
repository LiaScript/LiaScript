module Lia.Definition.Types exposing
    ( Definition
    , Resource(..)
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
        | macro =
            Dict.toList temp.macro
                |> List.append (Dict.toList orig.macro)
                |> Dict.fromList
        , onload =
            case ( orig.onload, temp.onload ) of
                ( "", "" ) ->
                    ""

                ( str1, "" ) ->
                    str1

                ( "", str2 ) ->
                    str2

                ( str1, str2 ) ->
                    str1 ++ "\n" ++ str2
    }


add_imports : String -> Definition -> Definition
add_imports url def =
    { def
        | imports =
            toURL def.base url :: def.imports
    }


toURL : String -> String -> String
toURL basis url =
    if String.startsWith "http" url then
        url

    else
        basis ++ url
