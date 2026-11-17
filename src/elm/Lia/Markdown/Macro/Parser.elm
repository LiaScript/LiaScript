module Lia.Markdown.Macro.Parser exposing
    ( add
    , macro
    )

{-| Macro expansion. A macro call is replaced textually by the macro body
before the rest of the input is parsed, so the body can contain any markdown.

  - `@name`, `@name(p0, p1, ...)`: the body with `@0`, `@1`, ... replaced by
    the parameters (`@'0` inserts the parameter as an escaped JS string)
  - `@'name`: the whole result as an escaped JS string
  - `@@name`, `@-@name`: debug, show the expanded body as text (`@@` within a
    gray code box)
  - `@[name](url)`, `@[name(p0, ...)](url)`: the url (resolved against the
    course base) is appended as the last parameter
  - a code block whose first line contains `@name(...)`: its content is
    appended as the last parameter (macro listing)
  - `@author`, `@date`, `@email`, `@version`, `@section` and `@uid` are taken
    from the course definition

-}

import Array exposing (Array)
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , app
        , choice
        , fail
        , ignore
        , keep
        , many
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , optional
        , or
        , parens
        , primitive
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
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, inlineCode, peek, startsWith)
import Lia.Parser.Indentation as Indent
import Lia.Utils exposing (toEscapeString)
import Regex


{-| A parsed macro call. `name` keeps its `@`, `@@` or `@-@` prefix,
`escape` is set by `@'`.
-}
type alias Call =
    { name : String
    , escape : Bool
    , params : List String
    }


{-| Store a macro definition (from the course header).
-}
add : ( String, String ) -> Definition -> Definition
add ( name, code ) def =
    { def | macro = Dict.insert name code def.macro }


{-| Expand all macros at the current position. Every macro starts with `@`
or with a code block (macro listing).
-}
macro : Parser Context ()
macro =
    peek (\input -> startsWith "@" input || startsWith "```" input)
        macros
        (succeed ())


{-| Expand macro after macro, since an expansion may start with another
call. Stops at the first position that is not a known macro, or when an
expansion leaves the input unchanged (e.g. `@a` defined as `@a`).
-}
macros : Parser Context ()
macros =
    choice [ uid_macro, simple_macro, reference_macro ]
        |> withSource
        |> andThen (inject False)
        |> or macro_listing
        |> many
        |> skip


{-| The prefix of a call, `@`, `@@` or `@-@`, plus an optional `'`.
-}
start : Parser s (String -> List String -> Call)
start =
    regex "@-?@?"
        |> map (\prefix escape name -> Call (prefix ++ name) escape)
        |> andMap (optional False (onsuccess True (string "'")))


{-| A macro name, at least two characters.
-}
identifier : Parser s String
identifier =
    regex "\\w[\\w.]+"


{-| The name of a macro that can be expanded, it is defined and the budget is
not used up (see `Context.hasMacroBudget`). The parameters of other calls
like `@input(...)` are not parsed, an `@` is tried at every position.
-}
known : Parser Context String
known =
    identifier
        |> andThen
            (\name ->
                withState
                    (\state ->
                        if Context.hasMacroBudget state && get name state.defines /= Nothing then
                            succeed name

                        else
                            fail "unknown macro"
                    )
            )


{-| `@uid` counts up on every call, see `get`.
-}
uid_macro : Parser Context Call
uid_macro =
    string "@uid"
        |> keep (modifyState nextUid)
        |> onsuccess (Call "@uid" False [])


nextUid : Context -> Context
nextUid state =
    let
        def =
            state.defines
    in
    { state | defines = { def | uid = def.uid + 1 } }


{-| `@name` or `@name(p0, p1, ...)`.
-}
simple_macro : Parser Context Call
simple_macro =
    start
        |> andMap known
        |> andMap parameter_list


{-| `@[name](url)` or `@[name(p0, ...)](url "title")`, the url becomes the
last parameter, a title is dropped.
-}
reference_macro : Parser Context Call
reference_macro =
    start
        |> ignore (string "[")
        |> andMap known
        |> andMap
            (parameter_list
                |> ignore (string "](")
                |> map (\list url ( base, appendix ) -> list ++ [ toURL base appendix url ])
                |> andMap (regex "[^) ]*")
                |> ignore (regex "[^)]*\\)")
                |> andMap (withState (\c -> succeed ( c.defines.base, c.defines.appendix )))
            )


{-| An optional, comma separated parameter list in parentheses.
-}
parameter_list : Parser Context (List String)
parameter_list =
    optional [] (parens (sepBy (string ",") parameter))


{-| A parameter is either a backtick block (may contain `,` and `)`),
inline code or plain text.
-}
parameter : Parser Context String
parameter =
    choice
        [ c_frame |> andThen (\n -> regex ("[\\s\\S]*?`{" ++ String.fromInt n ++ "}") |> map (String.dropRight n))
        , inlineCode
        , regex "[^),]+"
        ]


{-| A code block whose first line names a macro, e.g. ```` ```js @run(x) ````.
The block content becomes the last parameter.
-}
macro_listing : Parser Context ()
macro_listing =
    c_frame
        |> ignore (regex "[\t ]*[a-zA-Z0-9_]*[\t ]*")
        |> map Tuple.pair
        |> andMap
            (start
                |> andMap known
                |> andMap parameter_list
                |> ignore (regex "[\t ]*\n")
            )
        |> andThen
            (\( backticks, call ) ->
                code_block backticks
                    |> map (\code -> { call | params = call.params ++ [ code ] })
            )
        |> withSource
        |> andThen (inject True)


{-| The parsed call and its text.
-}
withSource : Parser Context Call -> Parser Context ( String, Call )
withSource p =
    primitive
        (\state stream ->
            case app p state stream of
                ( newState, newStream, Ok call ) ->
                    ( newState
                    , newStream
                    , Ok ( String.left (newStream.position - stream.position) stream.input, call )
                    )

                ( newState, newStream, Err e ) ->
                    ( newState, newStream, Err e )
        )


{-| The block content up to the closing backticks, without the last
newline. Indentation is removed from every line.
-}
code_block : Int -> Parser Context String
code_block n =
    let
        backticks =
            String.repeat n "`"
    in
    manyTill
        (maybe Indent.check |> keep (regex ("(.(?!" ++ backticks ++ "))*\n?")))
        (maybe Indent.check |> keep (string backticks))
        |> map (String.concat >> String.dropRight 1)


{-| Put the expanded macro in front of the remaining input. Fails for unknown
macros. Unless `ignoreIndentation`, every new line of the body gets the
current indentation (list items, quotes, ...), so the result stays within
the surrounding block.
-}
inject : Bool -> ( String, Call ) -> Parser Context ()
inject ignoreIndentation ( source, call ) =
    withState
        (\state ->
            let
                ( present, id ) =
                    mode call.name
            in
            case get id state.defines of
                Just body ->
                    let
                        ( newState, values ) =
                            List.foldl eval_parameter ( Context.countMacro 100 state, [] ) call.params

                        args =
                            Array.fromList (List.reverse values)

                        charged =
                            Context.countMacro (expandedLength args body) newState
                    in
                    if Context.hasMacroBudget charged then
                        let
                            expansion =
                                body
                                    |> indent ignoreIndentation state.indentation
                                    |> substitute args
                                    |> unguard
                                    |> escapeIf call.escape
                        in
                        expansion
                            |> present
                            |> prepend
                            |> ignore (putState (Context.countMacro (String.length expansion) newState))

                    else
                        -- the call does not fit into the budget, it stays as
                        -- text, failing would undo the count and every
                        -- following macro would try again
                        prepend source
                            |> ignore (putState charged)

                Nothing ->
                    fail "macro definition not found"
        )


{-| Unless `ignoreIndentation`, every new line of the body gets the current
indentation (list items, quotes, ...).
-}
indent : Bool -> List String -> String -> String
indent ignoreIndentation indentation body =
    if ignoreIndentation || indentation == [] then
        body

    else
        body
            |> String.lines
            |> String.join
                (indentation
                    |> String.concat
                    |> String.replace "?" ""
                    |> String.replace "*" ""
                    |> (++) "\n"
                )


escapeIf : Bool -> String -> String
escapeIf isEscaped code =
    if isEscaped then
        toEscapeString code

    else
        code


{-| Put the expansion in front of the remaining input. `modifyInput` would
leave `data` at the original text, so lines and columns (`withColumn` in quiz
and survey items) were measured against text the parser never saw, see
issue #325. `data` stays the consumed text plus the new input.
-}
prepend : String -> Parser Context ()
prepend code =
    primitive
        (\state stream ->
            let
                input =
                    code ++ stream.input
            in
            ( state
            , { stream | input = input, data = String.left stream.position stream.data ++ input }
            , Ok ()
            )
        )


{-| Split the prefix off a macro name and return how to present the result:
`@@` as debug code box, `@-@` as inline debug text, `@` as is.
-}
mode : String -> ( String -> String, String )
mode name =
    if String.startsWith "@@" name then
        ( debugBox, String.dropLeft 2 name )

    else if String.startsWith "@-@" name then
        ( debugInline, String.dropLeft 3 name )

    else
        ( identity, String.dropLeft 1 name )


{-| The body of a macro, built-in values first.
-}
get : String -> Definition -> Maybe String
get id def =
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


{-| Expand the macros within a parameter, in order, since `@uid` counts up.
The values are collected in reverse. Escaped `\@` stay guarded until the
whole body is done. Parameters nested too deep, e.g. by `@aa: @aa(@aa)`, stay
as they are, see `Context.nestedMacro`.
-}
eval_parameter : String -> ( Context, List String ) -> ( Context, List String )
eval_parameter param ( state, values ) =
    case Context.nestedMacro (\s -> expand s (guard param)) state of
        Just ( newState, value ) ->
            ( newState, value :: values )

        Nothing ->
            ( state, param :: values )


{-| Replace `@0`, `@1`, ... and the escaped `@'0`, ... by the parameter
values in one pass, so `@10` is not taken for `@1` and inserted values are
not searched again. `\@0` and unknown indices are kept.
-}
substitute : Array String -> String -> String
substitute values =
    Regex.replace parameterRef
        (\m ->
            case m.submatches of
                [ quote, Just i ] ->
                    case String.toInt i |> Maybe.andThen (\j -> Array.get j values) of
                        Just value ->
                            if quote == Just "'" then
                                toEscapeString value

                            else
                                value

                        Nothing ->
                            m.match

                _ ->
                    m.match
        )


{-| The length of `body` with the parameters substituted, without building it.
-}
expandedLength : Array String -> String -> Int
expandedLength values body =
    Regex.find parameterRef body
        |> List.foldl
            (\m sum ->
                case m.submatches of
                    [ _, Just i ] ->
                        String.toInt i
                            |> Maybe.andThen (\j -> Array.get j values)
                            |> Maybe.map (String.length >> (+) sum)
                            |> Maybe.withDefault sum

                    _ ->
                        sum
            )
            (String.length body)


parameterRef : Regex.Regex
parameterRef =
    Regex.fromString "\\\\@|@('?)(\\d+)"
        |> Maybe.withDefault Regex.never


{-| Replaces `\@` so it is neither expanded nor taken for a parameter.
-}
guard_pattern : String
guard_pattern =
    "iex3OAQpP4u3QT9xq"


guard : String -> String
guard =
    String.replace "\\@" guard_pattern


unguard : String -> String
unguard =
    String.replace guard_pattern "\\@"


{-| Expand all macros within a string (a parameter). An `@` that is no known
macro (e.g. `@input`) is kept as text. The rest of the input is only left if
a recursive macro stops the expansion.
-}
expand : Context -> String -> ( Context, String )
expand state str =
    case runParser expandAll state str of
        Ok ( newState, stream, expanded ) ->
            ( newState, expanded ++ stream.input )

        _ ->
            ( state, str )


{-| Text and macros alternate. The text comes first in every repetition, at
the end of the input it fails before a macro is expanded. Otherwise the last
macro was expanded twice (and once more on every level of `@aa: @aa(@aa)`),
the first time was undone by the failure.
-}
expandAll : Parser Context String
expandAll =
    macro
        |> keep
            (or (regex "[^@]+") (string "@")
                |> ignore macro
                |> many
            )
        |> map String.concat


{-| `@@`: show the expanded macro in a gray code box. `<lia-keep>` is not
parsed any further, so only HTML is escaped.
-}
debugBox : String -> String
debugBox code =
    "<lia-keep><pre id='ls'><code style='background: #CCCCCC; white-space: pre;'>"
        ++ (code
                |> String.replace "&" "&amp;"
                |> String.replace "<" "&lt;"
                |> String.replace ">" "&gt;"
                |> String.replace "\n" "<br id='ls'>"
           )
        ++ "</code></pre></lia-keep>"


{-| `@-@`: show the expanded macro as inline text. Markdown is escaped, line
breaks become `<br>`, nested macros are marked as `@-@name`.
-}
debugInline : String -> String
debugInline =
    Regex.replace markdownChars (.match >> (++) "\\")
        >> String.replace "<" "\\<"
        >> String.replace ">" "\\>"
        >> String.replace "\\\\`" "`"
        >> String.replace "\n" "<br id='ls'>"
        >> Regex.replace macroNames
            (\x ->
                if x.match /= "@input" then
                    "@-" ++ x.match

                else
                    x.match
            )
        >> String.replace "\\<br id='ls'\\>" "<br id='ls'>"


markdownChars : Regex.Regex
markdownChars =
    Regex.fromString "[*+`{}#^|$\\[\\]]"
        |> Maybe.withDefault Regex.never


macroNames : Regex.Regex
macroNames =
    Regex.fromString "@[a-zA-Z]+[\\w\\d._\\-]*"
        |> Maybe.withDefault Regex.never
