module Lia.Markdown.Macro.Parser exposing
    ( add
    , macro
    )

import Browser.Navigation exposing (back)
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
        , modifyPosition
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
import Lia.Markdown.HTML.Attributes exposing (toURL)
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, inlineCode, stringTill)
import Lia.Parser.Indentation as Indent
import Lia.Utils exposing (toEscapeString)
import Regex


identifier : Parser s String
identifier =
    regex "\\w[\\w\\d._]+"


start =
    regex "@-?@?"
        |> map (\ad escape name_ -> ( ad ++ name_, escape ))
        |> andMap
            (string "'"
                |> onsuccess True
                |> optional False
            )


pattern : Parser s ( String, Bool )
pattern =
    andMap identifier start


parameter : Parser Context String
parameter =
    [ c_frame
        |> andThen
            (\startLength ->
                stringTill (string (String.repeat startLength "`"))
            )
    , inlineCode
    , regex "[^),]+"
    ]
        |> choice


parameter_list : Parser Context (List String)
parameter_list =
    optional [] (parens (sepBy (string ",") parameter))


macro : Parser Context ()
macro =
    many1
        (choice
            [ uid_macro |> andThen inject_macro
            , simple_macro |> andThen inject_macro
            , reference_macro |> andThen inject_macro
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


reference_macro : Parser Context ( ( String, Bool ), List String )
reference_macro =
    start
        |> ignore (string "[")
        |> andMap identifier
        |> map Tuple.pair
        |> andMap
            (parameter_list
                |> ignore (string "](")
                |> map (\list url baseURL -> List.append list [ toURL baseURL url ])
                |> andMap (regex "[^) ]*")
                |> ignore (regex "(\\)|[^)]*\\))")
                |> andMap (withState (.defines >> .base >> succeed))
            )


code_block : Int -> Parser Context (List String)
code_block backticks_count =
    let
        backticks =
            String.repeat backticks_count "`"
    in
    manyTill
        (maybe Indent.check
            |> keep
                (regex
                    ("(.(?!"
                        ++ backticks
                        ++ "))*\n?"
                    )
                )
        )
        (maybe Indent.check
            |> keep (string backticks)
        )
        |> map
            (String.concat
                >> String.dropRight 1
                >> List.singleton
            )


macro_listing : Parser Context ()
macro_listing =
    (c_frame
        |> ignore (regex "[\t ]*[a-zA-Z0-9_]*[\t ]*")
        |> map Tuple.pair
        |> andMap pattern
    )
        |> andThen
            (\( backticks, name ) ->
                (parameter_list |> ignore (regex "[\t ]*\n"))
                    |> andThen
                        (\params ->
                            map (List.append params) (code_block backticks)
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
                            if state.indentation == [] then
                                code

                            else
                                code
                                    |> String.lines
                                    |> String.join
                                        (state.indentation
                                            |> String.concat
                                            |> String.replace "?" ""
                                            |> String.replace "*" ""
                                            |> (++) "\n"
                                        )

                        ( new_state, _, new_code ) =
                            List.foldl
                                eval_parameter
                                ( state, 0, code_ )
                                params

                        inject_code =
                            (if escape then
                                toEscapeString new_code

                             else
                                new_code
                            )
                                |> (if isDebug then
                                        debug deepDebug

                                    else
                                        identity
                                   )
                    in
                    (++)
                        inject_code
                        |> modifyInput
                        |> keep (modifyPosition ((+) (-1 * String.length inject_code)))
                        |> ignore (putState new_state)

                Nothing ->
                    fail "macro definition not found"
    in
    withState inject


eval_parameter : String -> ( Context, Int, String ) -> ( Context, Int, String )
eval_parameter param ( state, i, code ) =
    let
        ( new_state, new_param ) =
            param
                |> guard
                |> macro_parse state
    in
    ( new_state
    , i + 1
    , code
        |> guard
        |> String.replace ("@'" ++ String.fromInt i) (toEscapeString new_param)
        |> String.replace ("@" ++ String.fromInt i) new_param
        |> unguard
    )


{-| This pattern is used to replace escaped @-signs, otherwise LiaScript will also try to parse them as macros
-}
guard_pattern =
    "iex3OAQpP4u3QT9xq"


guard : String -> String
guard =
    String.replace "\\@" guard_pattern


unguard : String -> String
unguard =
    String.replace guard_pattern "\\@"


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
        Ok ( state, stream, s ) ->
            if stream.input == "" then
                ( state, s )

            else
                stream.input
                    |> macro_parse state
                    |> Tuple.mapSecond ((++) s)

        _ ->
            ( defines, str )
