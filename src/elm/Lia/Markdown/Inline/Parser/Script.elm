module Lia.Markdown.Inline.Parser.Script exposing (body, length)

{-| The JavaScript code of a `<script>` element ends at the first `</script>`
that is not part of a string, a template string (including nested `${...}`),
a block comment or a regular expression literal. Everything else, also other
closing tags like `</div>` in a regex or comment, belongs to the code.

The code is scanned token by token in linear time. Whether a `/` starts a
regular expression or is a division is decided by the previous token, as in
JavaScript itself: after a value (identifier, number, `)`, `]`, string, ...) it
is a division.

-}

import Combine exposing (Parser, primitive)
import Regex exposing (Regex)


{-| Everything up to the closing `</script>`, which is consumed, but not part
of the result.
-}
body : Parser s String
body =
    primitive
        (\state stream ->
            case length stream.input of
                Just n ->
                    ( state
                    , { stream
                        | input = String.dropLeft (n + 9) stream.input
                        , position = stream.position + n + 9
                      }
                    , Ok (String.left n stream.input)
                    )

                Nothing ->
                    ( state, stream, Err [ "no closing </script>" ] )
        )


{-| The length of the code in front of the closing `</script>`:

    length "let s = '</script>'</script>" == Just 19

    length "1 + 1" == Nothing

-}
length : String -> Maybe Int
length code =
    scan code False Statement [] 0


{-| The kind of the previous token decides what a `/` or `{` means:

  - `Value`: a `/` is a division (after identifiers, numbers, strings, `)`,
    `]`, regular expressions, and object literals)
  - `Operator`: a `/` starts a regular expression and a `{` an object
    literal (after `=`, `(`, `,`, `return`, ...)
  - `Statement`: a `/` starts a regular expression and a `{` a block (at
    the beginning, after `;`, `)`, `=>`, `else`, and blocks)

-}
type Prev
    = Value
    | Operator
    | Statement


{-| Scan JavaScript code from `pos`. On the top level (`inBraces` is false) the
result is the position of `</script>`, within `${...}` it is the position
after the matching `}`. The `braces` stack marks the open braces that are
object literals (`True`) or blocks (`False`).
-}
scan : String -> Bool -> Prev -> List Bool -> Int -> Maybe Int
scan src inBraces prev braces pos =
    let
        rest =
            String.dropLeft pos src
    in
    -- only direct calls of scan in tail position, so that Elm turns the
    -- recursion into a loop (scripts can be long)
    case String.uncons rest of
        Nothing ->
            Nothing

        Just ( char, _ ) ->
            case char of
                '<' ->
                    if String.toLower (String.left 9 rest) == "</script>" then
                        if inBraces then
                            Nothing

                        else
                            Just pos

                    else if String.startsWith "<!--" rest then
                        -- an HTML-like comment is a line comment in JavaScript
                        scan src inBraces prev braces (pos + matchLength lineComment rest)

                    else
                        scan src inBraces Operator braces (pos + 1)

                '/' ->
                    if String.startsWith "//" rest then
                        scan src inBraces prev braces (pos + matchLength lineComment rest)

                    else
                        case ( matchLength blockComment rest, prev ) of
                            ( 0, Value ) ->
                                scan src inBraces Operator braces (pos + 1)

                            ( 0, _ ) ->
                                case matchLength regexLiteral rest of
                                    0 ->
                                        scan src inBraces Operator braces (pos + 1)

                                    n ->
                                        scan src inBraces Value braces (pos + n)

                            ( n, _ ) ->
                                scan src inBraces prev braces (pos + n)

                '\'' ->
                    -- strings end at the latest at the end of the line, an
                    -- unclosed string at the end cannot be followed by </script>
                    case matchLength singleQuoted rest of
                        0 ->
                            Nothing

                        n ->
                            scan src inBraces Value braces (pos + n)

                '"' ->
                    case matchLength doubleQuoted rest of
                        0 ->
                            Nothing

                        n ->
                            scan src inBraces Value braces (pos + n)

                '`' ->
                    case template src (pos + 1) of
                        Just end ->
                            scan src inBraces Value braces end

                        Nothing ->
                            -- an unclosed backtick is a single character
                            scan src inBraces Operator braces (pos + 1)

                '@' ->
                    -- a macro parameter like `@input` is a value, `@'` is no string
                    scan src
                        inBraces
                        Value
                        braces
                        (if String.startsWith "@'" rest then
                            pos + 2

                         else
                            pos + 1
                        )

                '{' ->
                    if prev == Operator then
                        scan src inBraces Operator (True :: braces) (pos + 1)

                    else
                        scan src inBraces Statement (False :: braces) (pos + 1)

                '}' ->
                    case braces of
                        True :: outer ->
                            scan src inBraces Value outer (pos + 1)

                        False :: outer ->
                            scan src inBraces Statement outer (pos + 1)

                        [] ->
                            if inBraces then
                                Just (pos + 1)

                            else
                                scan src inBraces Statement [] (pos + 1)

                ')' ->
                    scan src inBraces Value braces (pos + 1)

                ']' ->
                    scan src inBraces Value braces (pos + 1)

                ';' ->
                    scan src inBraces Statement braces (pos + 1)

                _ ->
                    if String.startsWith "=>" rest then
                        scan src inBraces Statement braces (pos + 2)

                    else
                        case ( matchLength whitespace rest, matchLength word rest ) of
                            ( 0, 0 ) ->
                                -- operators and punctuation
                                scan src inBraces Operator braces (pos + String.length (String.fromChar char))

                            ( 0, n ) ->
                                scan src inBraces (wordKind (String.left n rest)) braces (pos + n)

                            ( n, _ ) ->
                                scan src inBraces prev braces (pos + n)


wordKind : String -> Prev
wordKind word_ =
    if List.member word_ [ "else", "do", "try", "finally" ] then
        Statement

    else if List.member word_ [ "return", "typeof", "instanceof", "in", "of", "new", "delete", "void", "throw", "case", "yield", "await" ] then
        Operator

    else
        Value


{-| Scan a template string from `pos` (after the opening backtick), the result
is the position after the closing backtick.
-}
template : String -> Int -> Maybe Int
template src pos =
    let
        rest =
            String.dropLeft pos src
    in
    case String.uncons rest of
        Nothing ->
            Nothing

        Just ( '`', _ ) ->
            Just (pos + 1)

        Just ( '\\', _ ) ->
            template src (pos + 2)

        Just ( '$', _ ) ->
            if String.startsWith "${" rest then
                scan src True Operator [] (pos + 2)
                    |> Maybe.andThen (template src)

            else
                template src (pos + 1)

        Just _ ->
            template src (pos + max 1 (matchLength templateChars rest))


matchLength : Regex -> String -> Int
matchLength regex str =
    case Regex.findAtMost 1 regex str of
        match :: _ ->
            String.length match.match

        [] ->
            0


toRegex : String -> Regex
toRegex =
    Regex.fromStringWith { caseInsensitive = True, multiline = False }
        >> Maybe.withDefault Regex.never


{-| Every alternative within a repetition starts with another character, so
that no regex can backtrack exponentially.
-}
lineComment : Regex
lineComment =
    toRegex "^(?:[^<\\n]|<(?!/script>))*"


blockComment : Regex
blockComment =
    toRegex "^/\\*[\\s\\S]*?\\*/"


regexLiteral : Regex
regexLiteral =
    toRegex "^/(?![*/])(?:[^/\\\\\\n\\[]|\\\\[^\\n]|\\[(?:[^\\]\\\\\\n]|\\\\[^\\n])*\\])+/[a-z]*"


singleQuoted : Regex
singleQuoted =
    toRegex "^'(?:[^'\\\\\\n]|\\\\[^\\n])*(?:'|\\\\?\\n)"


doubleQuoted : Regex
doubleQuoted =
    toRegex "^\"(?:[^\"\\\\\\n]|\\\\[^\\n])*(?:\"|\\\\?\\n)"


templateChars : Regex
templateChars =
    toRegex "^[^`\\\\$]+"


whitespace : Regex
whitespace =
    toRegex "^\\s+"


word : Regex
word =
    toRegex "^[\\w$\\u0080-\\uffff]+"
