module Lia.Macro.Parser exposing (add, get, macro, pattern)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.PState exposing (PState)
import Lia.Utils exposing (string_replace)


pattern : Parser s String
pattern =
    regex "@[a-zA-Z0-9_]+"


params : Parser PState String
params =
    choice
        [ string "`" *> regex "[^`\\n]+" <* string "`"
        , string "```" *> regex "([^`]+|(\\`)|\\n)+" <* string "```"
        , regex "[^),]+"
        ]


macro : Parser PState ()
macro =
    let
        temp p =
            maybe (parens (sepBy (string ",") params)) >>= inject_macro p
    in
    skip (maybe (pattern >>= temp))


inject_macro : String -> Maybe (List String) -> Parser PState ()
inject_macro name params =
    let
        inject state =
            case ( get name state.defines, params ) of
                ( Just code, Nothing ) ->
                    modifyStream ((++) code) *> succeed ()

                ( Just code, Just list ) ->
                    let
                        new_code =
                            list
                                |> List.indexedMap (\k v -> ( "@" ++ toString k, parse v state ))
                                |> List.foldr (\( k, v ) s -> string_replace k v s) code
                    in
                    modifyStream ((++) new_code) *> succeed ()

                _ ->
                    modifyStream ((++) name) *> succeed ()
    in
    withState succeed >>= inject


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


parse : String -> PState -> String
parse str defines =
    case runParser (String.concat <$> many1 (macro *> regex "[^@]+")) defines str of
        Ok ( _, _, s ) ->
            s

        _ ->
            str
