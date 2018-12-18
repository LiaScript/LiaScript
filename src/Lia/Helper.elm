module Lia.Helper exposing (ID, c_frame, ignore, ignore1_, ignore1_3, ignore_2, keep, newline, newlines, newlines1, spaces, spaces1, stringTill)

import Combine exposing (..)
import Combine.Char exposing (..)


type alias ID =
    Int


c_frame : Parser s String
c_frame =
    --regex "`{3,}"
    string "```"


newline : Parser s Char
newline =
    --(char '\n' <|> eol) |> skip
    char '\n'


newlines : Parser s String
newlines =
    --many newline |> skip
    regex "\\n*"


newlines1 : Parser s String
newlines1 =
    --many newline |> skip
    regex "\\n+"


spaces : Parser s String
spaces =
    regex "[ \\t]*"


spaces1 : Parser s String
spaces1 =
    regex "[ \\t]+"


stringTill : Parser s p -> Parser s String
stringTill p =
    String.fromList <$> manyTill anyChar p


ignore1_ : Parser s x -> Parser s a -> Parser s a
ignore1_ p1 p2 =
    p1
        |> map (flip always)
        |> andMap p2


ignore : Parser s x -> Parser s a -> Parser s a
ignore p1 p2 =
    p1
        |> map (flip always)
        |> andMap p2


keep : Parser s a -> Parser s x -> Parser s a
keep p1 p2 =
    p1
        |> map always
        |> andMap p2


ignore_2 : Parser s a -> Parser s x -> Parser s a
ignore_2 p1 p2 =
    p1
        |> map always
        |> andMap p2


ignore1_3 : Parser s x1 -> Parser s a -> Parser s x2 -> Parser s a
ignore1_3 p1 p2 p3 =
    p1
        |> map (flip always)
        |> andMap p2
        |> map always
        |> andMap p3



{-
   parser

   p1
   |> ignore (pxxx)
   |> keep (sss)

-}
