module Lia.Macro.Parser exposing (add, get, macro, pattern)

import Combine exposing (..)
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Helper exposing (..)
import Lia.PState exposing (PState, identation)
import Lia.Utils exposing (string_replace, toJSstring)


pattern : Parser s String
pattern =
    spaces |> keep (regex "@[\\w.]+")


parameter : Parser PState String
parameter =
    [ c_frame
        |> keep (regex "(([^`]+|(`[^`]+)|(``[^`]+))|\\n)+")
        |> ignore c_frame
    , string "`"
        |> keep (regex "[^`\n]+")
        |> ignore (string "`")
    , regex "[^),]+"
    ]
        |> choice
        |> map toJSstring


parameter_list : Parser PState (List String)
parameter_list =
    optional [] (parens (sepBy (string ",") parameter))


macro : Parser PState ()
macro =
    many1
        (choice
            [ uid_macro |> andThen inject_macro
            , simple_macro |> andThen inject_macro
            , macro_listing
            ]
        )
        |> maybe
        |> skip


uid_macro : Parser PState ( String, List String )
uid_macro =
    string "@uid"
        |> keep (modifyState uid_update)
        |> onsuccess ( "@uid", [] )


uid_update : PState -> PState
uid_update state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


simple_macro : Parser PState ( String, List String )
simple_macro =
    pattern
        |> map Tuple.pair
        |> andMap parameter_list


code_block : Parser PState (List String)
code_block =
    manyTill
        (maybe identation
            |> keep (regex "(.(?!```))*\\n?")
        )
        (maybe identation
            |> keep c_frame
        )
        |> map (String.concat >> List.singleton)


macro_listing : Parser PState ()
macro_listing =
    (c_frame
        |> keep (regex "[\t ]*[a-zA-Z0-9_]*[\t ]*")
        |> keep pattern
    )
        |> andThen
            (\name ->
                (parameter_list |> ignore (regex "[\t ]*\\n"))
                    |> andThen
                        (\params ->
                            map (List.append params) code_block
                                |> andThen (\p -> inject_macro ( name, p ))
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
                                eval_parameter
                                ( state, 0, code_ )
                                params
                    in
                    (++) new_code
                        |> modifyStream
                        |> keep (putState new_state)
                        |> keep (succeed ())

                Nothing ->
                    fail "macro definition not found"
    in
    withState inject


eval_parameter : String -> ( PState, Int, String ) -> ( PState, Int, String )
eval_parameter param ( state, i, code ) =
    let
        ( new_state, new_param ) =
            macro_parse state param
    in
    ( new_state, i + 1, string_replace ( "@" ++ String.fromInt i, new_param ) code )


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
            Just (String.fromInt def.section)

        "@uid" ->
            Just (String.fromInt def.section ++ "." ++ String.fromInt def.uid)

        _ ->
            Dict.get name def.macro


add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


macro_parse : PState -> String -> ( PState, String )
macro_parse defines str =
    case
        runParser
            (macro
                |> keep (regex "[^@]+")
                |> or (regex "@input[^@]+")
                |> many1
                |> map String.concat
            )
            defines
            str
    of
        Ok ( state, _, s ) ->
            ( state, s )

        _ ->
            ( defines, str )
