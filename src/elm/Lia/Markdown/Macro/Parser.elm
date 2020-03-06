module Lia.Markdown.Macro.Parser exposing (add, get, macro, pattern)

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
        , modifyState
        , modifyStream
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
import Lia.Parser.Helper exposing (c_frame, spaces)
import Lia.Utils exposing (toJSstring)
import Regex


pattern : Parser s String
pattern =
    spaces |> keep (regex "@@?\\w+[\\w\\d.\\-]*")


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


uid_macro : Parser Context ( String, List String )
uid_macro =
    string "@uid"
        |> keep (modifyState uid_update)
        |> onsuccess ( "@uid", [] )


uid_update : Context -> Context
uid_update state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


simple_macro : Parser Context ( String, List String )
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


inject_macro : ( String, List String ) -> Parser Context ()
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


eval_parameter : String -> ( Context, Int, String ) -> ( Context, Int, String )
eval_parameter param ( state, i, code ) =
    let
        ( new_state, new_param ) =
            macro_parse state param
    in
    ( new_state, i + 1, String.replace ("@" ++ String.fromInt i) new_param code )


get : String -> Definition -> Maybe String
get name def =
    let
        ( isDebug, id ) =
            if String.startsWith "@@" name then
                ( True, String.dropLeft 2 name )

            else
                ( False, String.dropLeft 1 name )
    in
    Maybe.map
        (if isDebug then
            debug

         else
            identity
        )
    <|
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



--      |> Maybe.map debug


debug : String -> String
debug =
    String.replace "\\" "\\\\"
        >> String.replace "*" "\\*"
        >> String.replace "_" "\\_"
        >> String.replace "+" "\\+"
        >> String.replace "-" "\\-"
        >> String.replace "^" "\\^"
        >> String.replace "~" "\\~"
        >> String.replace "$" "\\$"
        >> String.replace "{" "\\{"
        >> String.replace "}" "\\}"
        >> String.replace "[" "\\["
        >> String.replace "]" "\\]"
        >> String.replace "|" "\\|"
        >> String.replace "#" "\\#"
        >> String.replace "<" "\\<"
        >> String.replace ">" "\\>"
        >> debugReplace
        >> debugEnvironment


debugEnvironment : String -> String
debugEnvironment code =
    "<pre style='background: #CCCCCC'><code>\n"
        ++ code
        ++ "\n</code></pre>"


debugReplace : String -> String
debugReplace string =
    case Regex.fromString "@[a-zA-Z]+[\\w\\d.\\-]*" of
        Just regex ->
            Regex.replace regex (.match >> (++) "@") string

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
