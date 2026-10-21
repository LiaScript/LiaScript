module Lia.Parser.Helper exposing
    ( c_frame
    , inlineCode
    , newline
    , newlines
    , peek
    , spaces
    , spaces1
    , startsWith
    , stringTill
    , trimSpaces
    )

{-| Small parsers and string functions shared by all LiaScript parsers.
-}

import Combine
    exposing
        ( Parser
        , app
        , ignore
        , keep
        , manyTill
        , map
        , primitive
        , regex
        , string
        )
import Combine.Char exposing (anyChar)


{-| Run `p` only if the remaining input passes `check`, otherwise run
`default`.

This is a shortcut for parsers that can only start with a few known prefixes:
the result is the same, but the alternatives within `p` do not have to fail one
after another on every position.

-}
peek : (String -> Bool) -> Parser s a -> Parser s a -> Parser s a
peek check p default =
    primitive
        (\state stream ->
            if check stream.input then
                app p state stream

            else
                app default state stream
        )


{-| Like `String.startsWith`, but that is implemented as
`indexOf(prefix) === 0`, which searches the whole string if it does not start
with `prefix`. On the remaining input of a parser this would be O(n) for every
check.
-}
startsWith : String -> String -> Bool
startsWith prefix str =
    String.left (String.length prefix) str == prefix


{-| Remove leading spaces and tabs.
-}
trimSpaces : String -> String
trimSpaces str =
    if startsWith " " str || startsWith "\t" str then
        trimSpaces (String.dropLeft 1 str)

    else
        str


{-| The opening backticks of a code block, the result is their number.
-}
c_frame : Parser s Int
c_frame =
    regex "(`){3,}" |> map String.length


{-| A single newline.
-}
newline : Parser s String
newline =
    string "\n"


{-| Any number of newlines.
-}
newlines : Parser s String
newlines =
    regex "\n*"


{-| Any number of spaces and tabs.
-}
spaces : Parser s String
spaces =
    regex "[\t ]*"


{-| At least one space or tab.
-}
spaces1 : Parser s String
spaces1 =
    regex "[\t ]+"


{-| Everything until `p` matches, `p` is consumed but not part of the result.
-}
stringTill : Parser s p -> Parser s String
stringTill p =
    manyTill anyChar p |> map String.fromList


{-| Inline code surrounded by single backticks, a backslash escapes a backtick.
-}
inlineCode : Parser s String
inlineCode =
    string "`"
        |> keep (regex "([^`\n\\\\]*|\\\\`|\\\\)+")
        |> ignore (string "`")
        |> map (String.replace "\\`" "`")
