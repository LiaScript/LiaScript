module Lia.Macro.Parser exposing (add, get, macro, pattern)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.PState exposing (PState, identation)
import Lia.Utils exposing (string_replace)


pattern : Parser s String
pattern =
    regex "@[a-zA-Z0-9_]+"


param : Parser PState String
param =
    choice
        [ string "```" *> regex "([^`]+|\\n)+" <* string "```"
        , string "`" *> regex "[^`\\n]+" <* string "`"
        , regex "[^),]+"
        ]


param_list : Parser PState (List String)
param_list =
    optional [] (parens (sepBy (string ",") param))


macro : Parser PState ()
macro =
    skip
        (maybe
            ((pattern
                >>= (\name ->
                        param_list >>= inject_macro name
                    )
             )
                <|> macro_listing
            )
        )


inject_macro : String -> List String -> Parser PState ()
inject_macro name params =
    let
        inject state =
            case get name state.defines of
                Just code ->
                    let
                        new_code =
                            params
                                |> List.indexedMap (\k v -> ( "@" ++ toString k, macro_parse v state ))
                                |> List.foldr (\( k, v ) s -> string_replace k v s) code
                    in
                    modifyStream ((++) new_code) *> succeed ()

                Nothing ->
                    fail "macro not found"
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


macro_parse : String -> PState -> String
macro_parse str defines =
    case runParser (String.concat <$> many1 (macro *> regex "[^@]+")) defines str of
        Ok ( _, _, s ) ->
            s

        _ ->
            str


code_line : Parser PState String
code_line =
    maybe identation *> regex "(.(?!```))*\\n?"


macro_listing : Parser PState ()
macro_listing =
    (string "```" *> regex ".*\\n" *> identation *> pattern)
        >>= (\name ->
                (param_list <* regex "[ \\t]*\\n")
                    >>= (\params ->
                            ((\code -> List.append params [ String.concat code ])
                                <$> manyTill code_line (identation *> string "```")
                            )
                                >>= inject_macro name
                        )
            )
