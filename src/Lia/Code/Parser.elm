module Lia.Code.Parser exposing (code)

import Array exposing (Array)
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
        <$> ((header (regex "((js)|(javascript))( +)(x|X)")
                *> stringTill border
             )
                >>= modify_PState
            )


modify_PState : String -> Parser PState Int
modify_PState code_ =
    let
        add_state s =
            { s | code_vector = Array.push ( code_, Nothing, False ) s.code_vector }
    in
    withState (\s -> succeed (Array.length s.code_vector)) <* modifyState add_state
