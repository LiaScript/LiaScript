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
        , choice
        , fail
        , ignore
        , keep
        , many
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
import Lia.Markdown.HTML.Attributes exposing (toURL)
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, inlineCode, peek, startsWith, stringTill)
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
        |> andMap identifier
        |> andMap parameter_list


{-| `@[name](url)` or `@[name(p0, ...)](url "title")`, the url becomes the
last parameter, a title is dropped.
-}
reference_macro : Parser Context Call
reference_macro =
    start
        |> ignore (string "[")
        |> andMap identifier
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
        [ c_frame |> andThen (\n -> stringTill (string (String.repeat n "`")))
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
                |> andMap identifier
                |> andMap parameter_list
                |> ignore (regex "[\t ]*\n")
            )
        |> andThen
            (\( backticks, call ) ->
                code_block backticks
                    |> map (\code -> { call | params = call.params ++ [ code ] })
            )
        |> andThen (inject True)


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
inject : Bool -> Call -> Parser Context ()
inject ignoreIndentation call =
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
                            List.foldl eval_parameter ( state, [] ) call.params

                        code =
                            (if ignoreIndentation || state.indentation == [] then
                                body

                             else
                                body
                                    |> String.lines
                                    |> String.join
                                        (state.indentation
                                            |> String.concat
                                            |> String.replace "?" ""
                                            |> String.replace "*" ""
                                            |> (++) "\n"
                                        )
                            )
                                |> substitute (Array.fromList (List.reverse values))
                                |> unguard
                    in
                    (if call.escape then
                        toEscapeString code

                     else
                        code
                    )
                        |> present
                        |> (++)
                        |> modifyInput
                        |> ignore (putState newState)

                Nothing ->
                    fail "macro definition not found"
        )


{-| Split the prefix off a macro name and return how to present the result:
`@@` as debug code box, `@-@` as inline debug text, `@` as is.
-}
mode : String -> ( String -> String, String )
mode name =
    if String.startsWith "@@" name then
        ( debug True, String.dropLeft 2 name )

    else if String.startsWith "@-@" name then
        ( debug False, String.dropLeft 3 name )

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
whole body is done.
-}
eval_parameter : String -> ( Context, List String ) -> ( Context, List String )
eval_parameter param ( state, values ) =
    let
        ( newState, value ) =
            expand state (guard param)
    in
    ( newState, value :: values )


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


expandAll : Parser Context String
expandAll =
    macro
        |> keep (or (regex "[^@]+") (string "@"))
        |> many
        |> map String.concat
        |> ignore macro


{-| Show the expanded macro as text: markdown is escaped, line breaks become
`<br>`, nested macros are marked as `@-@name`. `box` puts it into a gray
code block.
-}
debug : Bool -> String -> String
debug box =
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
        >> (if box then
                \code -> "<lia-keep><pre id='ls'><code style='background: #CCCCCC; white-space: pre;'>" ++ code ++ "</code></pre></lia-keep>"

            else
                identity
           )


markdownChars : Regex.Regex
markdownChars =
    Regex.fromString "[*+`{}#^|$\\[\\]]"
        |> Maybe.withDefault Regex.never


macroNames : Regex.Regex
macroNames =
    Regex.fromString "@[a-zA-Z]+[\\w\\d._\\-]*"
        |> Maybe.withDefault Regex.never
