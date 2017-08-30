module Lia.Code.Parser exposing (..)

import Combine exposing (..)
import Combine.Char
import Lia.Code.Types exposing (..)
import Lia.PState exposing (PState)


code : Parser PState Code
code =
    choice [ eval_js, block ]


block : Parser PState Code
block =
    let
        lang =
            regex "```( *)" *> regex "([a-z,A-Z,0-9])*" <* regex "( *)\\n"

        block =
            String.fromList <$> manyTill Combine.Char.anyChar (string "```")
    in
    Highlight <$> lang <*> block


eval_js : Parser PState Code
eval_js =
    let
        block =
            String.fromList <$> manyTill Combine.Char.anyChar (string "```")
    in
    EvalJS <$> (regex "```( *)((js)|(javascript))( +)(x|X)" *> block) <*> inc_counter


inc_counter : Parser PState Int
inc_counter =
    let
        pp par =
            succeed par.code

        increment_counter c =
            { c | code = c.code + 1 }
    in
    withState pp <* modifyState increment_counter
