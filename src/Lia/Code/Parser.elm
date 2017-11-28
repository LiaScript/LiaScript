module Lia.Code.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Code.Types exposing (..)
import Lia.Inline.Parser exposing (comment_string, stringTill, whitelines)
import Lia.PState exposing (PState)
import Lia.Utils exposing (guess)


parse : Parser PState Code
parse =
    listing *> maybe (regex "[ \\n]?" *> comment_string) >>= result


result : Maybe String -> Parser PState Code
result comment =
    withState
        (\s ->
            let
                ( l, code ) =
                    s.code_temp

                lang =
                    if l == "" then
                        "cpp"
                    else
                        l
            in
            case comment of
                Just str ->
                    evaluate lang code str

                Nothing ->
                    succeed <| Highlight lang code
        )
        <* modify_temp ( "", "" )


check_lang : ( String, String ) -> ( String, String )
check_lang ( lang, code ) =
    if lang == "" then
        ( guess lang, code )
    else
        ( lang, code )


border : Parser PState String
border =
    string "```"


header : Parser PState String
header =
    whitespace *> regex "\\w*" <* regex "[ ]*\\n" <?> "language definition"


listing : Parser PState ()
listing =
    ((\h s -> ( h, s )) <$> (border *> header) <*> stringTill border) >>= modify_temp


modify_temp : ( String, String ) -> Parser PState ()
modify_temp lang_code =
    modifyState (\s -> { s | code_temp = lang_code })


evaluate : String -> String -> String -> Parser PState Code
evaluate lang code comment =
    let
        add_state s =
            { s
                | code_vector =
                    Array.push
                        { code = code
                        , version = Array.fromList [ code ]
                        , version_active = 0
                        , result = Ok ""
                        , editing = False
                        , running = False
                        }
                        s.code_vector
            }
    in
    withState
        (\s ->
            comment
                |> String.split "{X}"
                |> Evaluate lang ( s.slide, Array.length s.code_vector )
                |> succeed
        )
        <* modifyState add_state
