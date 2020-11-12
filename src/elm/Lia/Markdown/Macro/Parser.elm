module Lia.Markdown.Macro.Parser exposing (add, macro)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , fail
        , ignore
        , keep
        , many1
        , manyTill
        , map
        , maybe
        , modifyInput
        , modifyState
        , onsuccess
        , optional
        , or
        , parens
        , putState
        , regex
        , runParser
        , sepBy
        , skip
        , string
        , succeed
        , withState
        )
import Dict
import Lia.Definition.Types exposing (Definition)
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (c_frame)
import Lia.Utils exposing (toEscapeString, toJSstring)
import Regex


pattern : Parser s ( String, Bool )
pattern =
    regex "@-?@?"
        |> map (\ad escape name -> ( ad ++ name, escape ))
        |> andMap
            (string "'"
                |> onsuccess True
                |> optional False
            )
        |> andMap (regex "\\w[\\w\\d._]+")


parameter : Parser Context String
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


parameter_list : Parser Context (List String)
parameter_list =
    optional [] (parens (sepBy (string ",") parameter))


macro : Parser Context ()
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


uid_macro : Parser Context ( ( String, Bool ), List String )
uid_macro =
    string "@uid"
        |> keep (modifyState uid_update)
        |> onsuccess ( ( "@uid", False ), [] )


uid_update : Context -> Context
uid_update state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


simple_macro : Parser Context ( ( String, Bool ), List String )
simple_macro =
    pattern
        |> map Tuple.pair
        |> andMap parameter_list


code_block : Parser Context (List String)
code_block =
    manyTill
        (maybe indentation
            |> keep (regex "(.(?!```))*\\n?")
        )
        (maybe indentation
            |> keep c_frame
        )
        |> map (String.concat >> List.singleton)


macro_listing : Parser Context ()
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


inject_macro : ( ( String, Bool ), List String ) -> Parser Context ()
inject_macro ( ( name, escape ), params ) =
    let
        inject state =
            case get name state.defines of
                Just ( isDebug, deepDebug, code ) ->
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
                    (++)
                        ((if escape then
                            toEscapeString new_code

                          else
                            new_code
                         )
                            |> (if isDebug then
                                    debug deepDebug

                                else
                                    identity
                               )
                        )
                        |> modifyInput
                        |> keep (putState new_state)
                        |> keep (succeed ())

                Nothing ->
                    fail "macro definition not found"
    in
    withState inject


eval_parameter : String -> ( Context, Int, String ) -> ( Context, Int, String )
eval_parameter param ( state, i, code ) =
    let
        ( new_state, new_param ) =
            macro_parse state param
    in
    ( new_state
    , i + 1
    , code
        |> String.replace ("@'" ++ String.fromInt i) (toEscapeString new_param)
        |> String.replace ("@" ++ String.fromInt i) new_param
    )


get : String -> Definition -> Maybe ( Bool, Bool, String )
get name def =
    let
        ( isDebug, deepDebug, id ) =
            if String.startsWith "@@" name then
                ( True, True, String.dropLeft 2 name )

            else if String.startsWith "@-@" name then
                ( True, False, String.dropLeft 3 name )

            else
                ( False, False, String.dropLeft 1 name )
    in
    Maybe.map (\x -> ( isDebug, deepDebug, x )) <|
        case id of
            "author" ->
                Just def.author

            "date" ->
                Just def.date

            "email" ->
                Just def.email

            "version" ->
                Just def.version

            "section" ->
                Just (String.fromInt def.section)

            "uid" ->
                Just (String.fromInt def.section ++ "_" ++ String.fromInt def.uid)

            _ ->
                Dict.get id def.macro


debug : Bool -> String -> String
debug env =
    debugReplace "[*+`{}#^|$\\[\\]]" (.match >> (++) "\\")
        >> String.replace "<" "\\<"
        >> String.replace ">" "\\>"
        >> String.replace "\\\\`" "`"
        >> String.replace "\n" "<br id='ls'>"
        >> debugReplace "@[a-zA-Z]+[\\w\\d._\\-]*"
            (\x ->
                if x.match /= "@input" then
                    "@-" ++ x.match

                else
                    x.match
            )
        >> String.replace "\\<br id='ls'\\>" "<br id='ls'>"
        >> debugEnvironment env


debugEnvironment : Bool -> String -> String
debugEnvironment env code =
    if env then
        "<lia-keep><pre id='ls'><code style='background: #CCCCCC; white-space: pre;'>"
            ++ code
            ++ "</code></pre></lia-keep>"

    else
        code


debugReplace : String -> (Regex.Match -> String) -> String -> String
debugReplace pat fn string =
    case Regex.fromString pat of
        Just regex ->
            Regex.replace regex fn string

        Nothing ->
            string


add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


macro_parse : Context -> String -> ( Context, String )
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
