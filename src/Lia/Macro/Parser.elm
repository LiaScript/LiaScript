module Lia.Macro.Parser exposing (..)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.PState exposing (PState)


pattern : Parser s String
pattern =
    regex "@[a-zA-Z0-9_]+"


macro : Parser PState ()
macro =
    skip (maybe (pattern >>= inject_macro))


inject_macro : String -> Parser PState ()
inject_macro name =
    let
        inject code =
            case code of
                Just str ->
                    modifyStream ((++) str) *> succeed ()

                Nothing ->
                    modifyStream ((++) name) *> succeed ()
    in
    withState (\s -> s.defines |> get name |> succeed) >>= inject


get : String -> Definition -> Maybe String
get name def =
    case name of
        "@author" ->
            Just def.author

        "@date" ->
            Just def.date

        "@email" ->
            Just def.email

        "@version" ->
            Just def.version

        _ ->
            Dict.get name def.macro


add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }
