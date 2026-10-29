module Lia.Definition.Types exposing
    ( Definition
    , Resource(..)
    , add_macros
    , default
    , getIcon
    , merge
    , setPersistent
    )

{-| The definitions of a course, taken from the main comment at the top of the
document (`author`, `language`, `@macros`, ...) and from the comments at the
beginning of a section. The parser is `Lia.Definition.Parser`.
-}

import Const
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Settings.Types exposing (Mode)


{-| External resources: CSS `link`, JavaScript `script` and ES `SCRIPT`
modules.
-}
type Resource
    = Link String
    | Script String
    | Module String


{-| All course definitions:

  - `base` and `appendix` (`?query` of the course URL, empty or starting with
    `?`) turn relative URLs into absolute ones
  - `macro` stores all `@macros`, also `comment`, `icon` and `persistent`
  - `section` and `uid` are set while parsing a section, to generate unique
    ids for `@uid`
  - `lightMode` and `mode` are only set if defined, otherwise the user
    settings are kept

-}
type alias Definition =
    { author : String
    , date : String
    , email : String
    , language : String
    , typographic_quotation :
        { single : ( String, String )
        , double : ( String, String )
        }
    , logo : String
    , narrator : String
    , version : String
    , comment : Inlines
    , resources : List Resource
    , base : String
    , appendix : String
    , translation : Dict String String
    , formulas : Dict String String
    , macro : Dict String String
    , imports : List String
    , attributes : List Inlines
    , section : Int
    , uid : Int
    , onload : String
    , lightMode : Maybe Bool
    , mode : Maybe Mode
    }


{-| Definitions of a course without a header. The `appendix` is passed
without the leading `?`.
-}
default : String -> String -> Definition
default base appendix =
    { author = ""
    , date = ""
    , email = ""
    , language = "en"
    , typographic_quotation =
        { single = ( "‘", "’" )
        , double = ( "“", "”" )
        }
    , logo = ""
    , narrator = "US English Male"
    , version = "0.0.1"
    , comment = []
    , resources = []
    , base = base
    , appendix =
        if String.isEmpty appendix then
            ""

        else
            "?" ++ appendix
    , translation = Dict.empty
    , formulas = Dict.empty
    , macro = Dict.empty
    , imports = []
    , attributes = []
    , section = -1
    , uid = -1
    , onload = ""
    , lightMode = Nothing
    , mode = Nothing
    }


{-| Add the definitions of an imported template `temp` to the course `orig`.
Macros and formulas of `orig` win, attributes and resources are appended and
a different `onload` is appended to the original one.
-}
add_macros : Definition -> Definition -> Definition
add_macros orig temp =
    { orig
        | macro = Dict.union orig.macro temp.macro
        , attributes = appendNew orig.attributes temp.attributes
        , onload =
            if orig.onload /= temp.onload then
                String.trim (orig.onload ++ ";\n" ++ temp.onload)

            else
                String.trim orig.onload
        , resources = appendNew orig.resources temp.resources
        , formulas = Dict.union orig.formulas temp.formulas
    }


{-| Append only the elements of `new` that `old` does not contain, a definition
is also merged with itself (header in `init_script`, cached `index_restore`).
-}
appendNew : List a -> List a -> List a
appendNew old new =
    old ++ List.filter (\x -> not (List.member x old)) new


{-| The URL of the course icon, defined by `icon` or the LiaScript default.
-}
getIcon : Definition -> String
getIcon =
    .macro
        >> Dict.get "icon"
        >> Maybe.withDefault Const.icon


{-| Overwrite the `persistent` macro.
-}
setPersistent : Bool -> Definition -> Definition
setPersistent b def =
    { def
        | macro =
            Dict.insert "persistent"
                (if b then
                    "true"

                 else
                    "false"
                )
                def.macro
    }


{-| Merge the main and the section definition if the section definition is
present. Non-empty `author`, `email` and `date` and all macros of the section
win.
-}
merge : Definition -> Maybe Definition -> Definition
merge main sub =
    case sub of
        Nothing ->
            main

        Just def ->
            { main
                | author = orElse main.author def.author
                , email = orElse main.email def.email
                , date = orElse main.date def.date
                , macro = Dict.union def.macro main.macro
            }


{-| `str` or the `fallback` if `str` is empty.
-}
orElse : String -> String -> String
orElse fallback str =
    if String.isEmpty str then
        fallback

    else
        str
