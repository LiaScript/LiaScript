module Lia.Macro.Parser exposing (..)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.PState exposing (PState)
import Lia.Utils exposing (string_replace)


pattern : Parser s String
pattern =
    regex "@[a-zA-Z0-9_]+"


macro : Parser PState ()
macro =
    let
        temp p =
            maybe (String.split "," <$> parens (regex "[^)]+")) >>= inject_macro p
    in
    skip (maybe (pattern >>= temp))


inject_macro : String -> Maybe (List String) -> Parser PState ()
inject_macro name params =
    let
        inject code =
            case ( code, params ) of
                ( Just str, Nothing ) ->
                    modifyStream ((++) str) *> succeed ()

                ( Just str, Just list ) ->
                    let
                        new_code =
                            list
                                |> List.indexedMap (\k v -> ( "@" ++ toString k, v ))
                                |> List.foldr (\( k, v ) s -> string_replace k v s) str
                    in
                    modifyStream ((++) new_code) *> succeed ()

                _ ->
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
