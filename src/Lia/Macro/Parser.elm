module Lia.Macro.Parser exposing (add, get, macro, pattern)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Helper exposing (..)
import Lia.PState exposing (PState, identation)
import Lia.Utils exposing (string_replace, toJSstring)


pattern : Parser s String
pattern =
    spaces *> regex "@[\\w.]+"


param : Parser PState String
param =
    toJSstring
        <$> choice
                [ c_frame *> regex "(([^`]+|(`[^`]+)|(``[^`]+))|\\n)+" <* c_frame
                , string "`" *> regex "[^`\\n]+" <* string "`"
                , regex "[^),]+"
                ]


param_list : Parser PState (List String)
param_list =
    optional [] (parens (sepBy (string ",") param))


macro : Parser PState ()
macro =
    many1
        ((uid_macro >>= inject_macro)
            <|> (simple_macro >>= inject_macro)
            <|> macro_listing
        )
        |> maybe
        |> skip


uid_macro : Parser PState ( String, List String )
uid_macro =
    string "@uid" *> modifyState uid_update $> ( "@uid", [] )


uid_update : PState -> PState
uid_update state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


simple_macro : Parser PState ( String, List String )
simple_macro =
    (,) <$> pattern <*> param_list


code_block : Parser PState (List String)
code_block =
    String.concat
        >> List.singleton
        <$> manyTill
                (maybe identation *> regex "(.(?!```))*\\n?")
                (maybe identation *> c_frame)


macro_listing : Parser PState ()
macro_listing =
    (c_frame *> regex "[ \\t]*[a-zA-Z0-9_]*[ \\t]*" *> pattern)
        >>= (\name ->
                (param_list <* regex "[ \\t]*\\n")
                    >>= (\params ->
                            (List.append params <$> code_block)
                                >>= (\p -> inject_macro ( name, p ))
                        )
            )


inject_macro : ( String, List String ) -> Parser PState ()
inject_macro ( name, params ) =
    let
        inject state =
            case get name state.defines of
                Just code ->
                    let
                        code_ =
                            if state.identation == [] then
                                code

                            else
                                code
                                    |> String.lines
                                    |> String.join
                                        (state.identation
                                            |> String.concat
                                            |> (++) "\n"
                                        )

                        ( new_state, _, new_code ) =
                            List.foldl
                                eval_param
                                ( state, 0, code_ )
                                params
                    in
                    modifyStream ((++) new_code) *> putState new_state *> succeed ()

                Nothing ->
                    fail "macro definition not found"
    in
    withState inject


eval_param : String -> ( PState, Int, String ) -> ( PState, Int, String )
eval_param param ( state, i, code ) =
    let
        ( new_state, new_param ) =
            macro_parse state param
    in
    ( new_state, i + 1, string_replace ( "@" ++ toString i, new_param ) code )


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

        "@section" ->
            Just (toString def.section)

        "@uid" ->
            Just (toString def.section ++ "." ++ toString def.uid)

        _ ->
            Dict.get name def.macro


add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


macro_parse : PState -> String -> ( PState, String )
macro_parse defines str =
    case runParser (String.concat <$> many1 (regex "@input[^@]+" <|> macro *> regex "[^@]+")) defines str of
        Ok ( state, _, s ) ->
            ( state, s )

        _ ->
            ( defines, str )
