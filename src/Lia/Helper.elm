module Lia.Helper exposing (ID, c_frame, newline, newlines, newlines1, spaces, spaces1, stringTill)

import Combine exposing (..)
import Combine.Char exposing (..)


type alias ID =
    Int


c_frame : Parser s String
c_frame =
    string "```"


newline : Parser s String
newline =
    string "\n"


newlines : Parser s String
newlines =
    regex "\\n*"


newlines1 : Parser s String
newlines1 =
    regex "\\n+"


spaces : Parser s String
spaces =
    regex "[\t ]*"


spaces1 : Parser s String
spaces1 =
    regex "[\t ]+"


stringTill : Parser s p -> Parser s String
stringTill p =
    manyTill anyChar p |> map String.fromList
