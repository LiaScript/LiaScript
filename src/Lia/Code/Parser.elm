module Lia.Code.Parser exposing (code)

import Combine exposing (..)
import Lia.Code.Types exposing (..)
import Lia.Inline.Parser exposing (stringTill)
import Lia.PState exposing (PState)


code : Parser PState Code
code =
    choice [ eval_js, block ]


border : Parser PState String
border =
    string "```"


header : Parser PState a -> Parser PState a
header p =
    border *> whitespace *> p <* regex "( *)\\n"


block : Parser PState Code
block =
    Highlight <$> header (regex "([a-z,A-Z,0-9])*") <*> stringTill border


eval_js : Parser PState Code
eval_js =
    EvalJS
        <$> (header (regex "((js)|(javascript))( +)(x|X)") *> stringTill border)
        <*> inc_counter


inc_counter : Parser PState Int
inc_counter =
    let
        pp par =
            succeed par.code

        increment_counter c =
            { c | code = c.code + 1 }
    in
    withState pp <* modifyState increment_counter
