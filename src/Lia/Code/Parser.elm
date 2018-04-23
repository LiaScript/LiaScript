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
    ((,)
        <$> sepBy1 (string "\n") listing
        <*> maybe (regex "[ \\n]?" *> maybe identation *> macro *> javascript)
    )
        >>= result


result_to_highlight : ( String, String, String, Bool ) -> ( String, String, String )
result_to_highlight ( lang, title, code, _ ) =
    ( lang, title, code )


result : ( List ( String, String, String, Bool ), Maybe String ) -> Parser PState Code
result ( lst, script ) =
    withState
        (\s ->
            case script of
                Just str ->
                    evaluate lst str

                Nothing ->
                    lst
                        |> List.map result_to_highlight
                        |> Highlight
                        |> succeed
        )


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


title : Parser PState ( Bool, String )
title =
    (,)
        <$> (regex "[ \\t]*"
                *> optional True
                    (choice
                        [ True <$ string "+"
                        , False <$ string "-"
                        ]
                    )
            )
        <*> regex ".*"
        <* string "\n"
        <?> "code title"


code_line : Parser PState String
code_line =
    maybe identation *> regex "(.(?!```))*\\n?"


listing : Parser PState ( String, String, String, Bool )
listing =
    (\h ( v, t ) s -> ( h, t, String.concat s |> String.dropRight 1, v )) <$> (border *> header) <*> title <*> manyTill code_line (identation *> border)


evaluate : List ( String, String, String, Bool ) -> String -> Parser PState Code
evaluate lang_title_code comment =
    let
        add_state s =
            { s
                | code_vector =
                    Array.push
                        { file =
                            lang_title_code
                                |> List.map (\( lang, name, code, visible ) -> File lang name code visible)
                                |> Array.fromList
                        , version =
                            Array.fromList
                                [ ( lang_title_code
                                        |> List.map (\( _, _, code, _ ) -> code)
                                        |> Array.fromList
                                  , Ok ""
                                  )
                                ]
                        , evaluation = comment
                        , version_active = 0
                        , result = Ok ""
                        , running = False
                        }
                        s.code_vector
            }
    in
    withState
        (\s ->
            s.code_vector
                |> Array.length
                |> Evaluate
                |> succeed
        )
        <* modifyState add_state
