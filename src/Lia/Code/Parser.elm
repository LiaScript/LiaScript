module Lia.Code.Parser exposing (code)

import Array
import Combine exposing (..)
import Combine.Char exposing (anyChar)
import Lia.Code.Types exposing (..)
import Lia.Inline.Parser exposing (comment, stringTill)
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
    Evaluate
        <$> header (regex "([a-z,A-Z,0-9])*")
        <*> (stringTill border >>= modify_PState)
        <*> (regex "[ \\n]?" *> ((\c -> c |> String.fromList |> String.trim |> String.split "{X}") <$> comment anyChar))


modify_PState : String -> Parser PState Int
modify_PState code_ =
    let
        add_state s =
            { s | code_vector = Array.push { code = code_, result = Ok "", editing = False, running = False } s.code_vector }
    in
    withState (\s -> succeed (Array.length s.code_vector)) <* modifyState add_state
