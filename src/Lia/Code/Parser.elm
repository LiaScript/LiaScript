module Lia.Code.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Code.Types exposing (..)
import Lia.Helper exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Inline.Parser exposing (javascript)
import Lia.PState exposing (..)


parse : Parser PState Code
parse =
    ((,)
        <$> sepBy1 newline listing
        <*> maybe
                (regex "[ \\n]?"
                    *> maybe identation
                    *> macro
                    *> javascript
                )
    )
        >>= result


result_to_highlight : ( String, String, String, Bool ) -> ( String, String, String )
result_to_highlight ( lang, title, code, _ ) =
    ( lang, title, code )


result : ( List ( String, String, String, Bool ), Maybe String ) -> Parser PState Code
result ( lst, script ) =
    case script of
        Just str ->
            evaluate lst str

        Nothing ->
            lst
                |> List.map result_to_highlight
                |> Highlight
                |> succeed


header : Parser PState String
header =
    spaces *> regex "\\w*" <?> "language definition"


title : Parser PState ( Bool, String )
title =
    (,)
        <$> (spaces
                *> optional True
                    (choice
                        [ True <$ string "+"
                        , False <$ string "-"
                        ]
                    )
            )
        <*> regex ".*"
        <* newline
        <?> "code title"


code_body : Parser PState String
code_body =
    String.concat
        >> String.dropRight 1
        <$> manyTill
                (maybe identation *> regex "(.(?!```))*\\n?")
                (identation *> c_frame)


listing : Parser PState ( String, String, String, Bool )
listing =
    (\h ( v, t ) c -> ( h, t, c, v ))
        <$> (c_frame *> header)
        <*> title
        <*> code_body


toFile : ( String, String, String, Bool ) -> File
toFile ( lang, name, code, visible ) =
    File lang name code visible


extract_code : ( String, String, String, Bool ) -> String
extract_code ( _, _, code, _ ) =
    code


evaluate : List ( String, String, String, Bool ) -> String -> Parser PState Code
evaluate lang_title_code comment =
    let
        array =
            Array.fromList lang_title_code

        add_state s =
            { s
                | code_vector =
                    Array.push
                        { file = Array.map toFile array
                        , version =
                            Array.fromList
                                [ ( Array.map extract_code array, noResult ) ]
                        , evaluation = comment
                        , version_active = 0
                        , result = noResult
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
