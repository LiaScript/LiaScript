module Lia.Code.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Code.Types exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Inline.Parser exposing (javascript, whitelines)
import Lia.PState exposing (..)
import Lia.Utils exposing (guess)


parse : Parser PState Code
parse =
    listing *> maybe (regex "[ \\n]?" *> maybe identation *> macro *> javascript) >>= result


result : Maybe String -> Parser PState Code
result comment =
    withState
        (\s ->
            let
                ( l, t, code ) =
                    s.code_temp

                lang =
                    if l == "" then
                        "cpp"
                    else
                        l

                title =
                    if t == "" then
                        lang
                    else
                        t
            in
            case comment of
                Just str ->
                    evaluate lang title code str

                Nothing ->
                    succeed <| Highlight lang title code
        )
        <* modify_temp ( "", "", "" )


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
    regex "[ \\t]*" *> regex "\\w*" <?> "language definition"


title : Parser PState String
title =
    regex "[ \\t]*" *> regex ".*" <* string "\n" <?> "code title"


code_line : Parser PState String
code_line =
    maybe identation *> regex "(.(?!```))*\\n?"


listing : Parser PState ()
listing =
    ((\h t s -> ( h, t, String.concat s )) <$> (border *> header) <*> title <*> manyTill code_line (identation *> border)) >>= modify_temp


modify_temp : ( String, String, String ) -> Parser PState ()
modify_temp lang_code =
    modifyState (\s -> { s | code_temp = lang_code })


evaluate : String -> String -> String -> String -> Parser PState Code
evaluate lang title code comment =
    let
        add_state s =
            { s
                | code_vector =
                    Array.push
                        { code = code
                        , version = Array.fromList [ ( code, Ok "" ) ]
                        , version_active = 0
                        , result = Ok ""
                        , editing = False
                        , visible = True
                        , running = False
                        }
                        s.code_vector
            }
    in
    withState
        (\s ->
            comment
                |> String.split "{X}"
                |> Evaluate lang title (Array.length s.code_vector)
                |> succeed
        )
        <* modifyState add_state
