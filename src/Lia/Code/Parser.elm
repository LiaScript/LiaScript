module Lia.Code.Parser exposing (parse)

import Array
import Combine exposing (..)
import Dict
import Lia.Code.Types exposing (..)
import Lia.Inline.Parser exposing (stringTill, whitelines)
import Lia.PState exposing (PState)


type alias Data_ =
    { lang : String, code : String }


parse : Parser PState Code
parse =
    choice
        [ eval_js
        , block
        ]


border : Parser PState String
border =
    string "```"


header : Parser PState String
header =
    border *> whitespace *> regex "\\w*" <* regex "( *)\\n"


block : Parser PState Code
block =
    Highlight <$> header <*> stringTill border


listing : Parser PState Data_
listing =
    Data_ <$> header <*> stringTill border


comment =
    maybe (String.trim <$> regex "[ \\n]?<!--" *> stringTill (string "-->"))


eval_js : Parser PState Code
eval_js =
    Evaluate
        <$> header
        <*> (sequence
                [ stringTill border
                , String.trim <$> regex "[ \\n]?<!--" *> stringTill (regex "(>){3,}")
                ]
                >>= modify_PState
            )
        <*> ((\js -> js |> String.trim |> String.split "{X}") <$> stringTill (string "-->"))


modify_PState : List String -> Parser PState String
modify_PState code_idx =
    case code_idx of
        [ code_, idx ] ->
            let
                add_state s =
                    { s
                        | code_vector =
                            Dict.insert idx
                                { code = code_
                                , version = Array.fromList [ code_ ]
                                , version_active = 0
                                , result = Ok ""
                                , editing = False
                                , running = False
                                }
                                s.code_vector
                    }
            in
            withState (\s -> succeed idx) <* modifyState add_state

        _ ->
            fail "something went wrong"
