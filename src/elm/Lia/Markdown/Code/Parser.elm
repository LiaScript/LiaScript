module Lia.Markdown.Code.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , optional
        , or
        , regex
        , sepBy1
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Code.Log as Log
import Lia.Markdown.Code.Types exposing (Code(..), Snippet, initProject)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (javascript)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Parser.Context exposing (Context, indentation)
import Lia.Parser.Helper exposing (c_frame, newline, spaces)
import Port.Eval exposing (Eval)


parse : Parser Context Parameters -> Parser Context Code
parse attr =
    sepBy1 newline (attr |> andThen listing)
        |> map Tuple.pair
        |> andMap
            (regex "[ \n]?"
                |> ignore (maybe indentation)
                |> keep macro
                |> keep javascript
                |> maybe
            )
        |> andThen result


result : ( List ( Snippet, Bool ), Maybe String ) -> Parser Context Code
result ( lst, script ) =
    case script of
        Just str ->
            evaluate lst str

        Nothing ->
            lst
                |> List.map Tuple.first
                |> Highlight
                |> succeed


header : Parser Context String
header =
    spaces
        |> keep (regex "\\w*")
        |> map String.toLower


title : Parser Context ( Bool, String )
title =
    spaces
        |> keep
            (choice
                [ string "+" |> onsuccess True
                , string "-" |> onsuccess False
                ]
            )
        |> optional True
        |> map Tuple.pair
        |> andMap (regex ".*")
        |> ignore newline


code_body : String -> Int -> Parser Context String
code_body char len =
    let
        control_frame =
            char ++ "{" ++ String.fromInt len ++ "}"
    in
    manyTill
        (maybe indentation |> keep (regex ("(?:.(?!" ++ control_frame ++ "))*\\n")))
        (indentation |> keep (regex control_frame |> ignore spaces))
        |> map (String.concat >> String.dropRight 1)


listing : Parameters -> Parser Context ( Snippet, Bool )
listing attr =
    let
        body len =
            header
                |> map (\h ( v, t ) c -> ( Snippet attr h (String.trim t) c, v ))
                |> andMap title
                |> andMap (or (code_body "`" len) (code_body "~" len))
    in
    c_frame |> andThen body


evaluate : List ( Snippet, Bool ) -> String -> Parser Context Code
evaluate lang_title_code comment =
    let
        ar =
            Array.fromList lang_title_code

        ( output, array ) =
            case Array.get (Array.length ar - 1) ar of
                Just ( snippet, vis ) ->
                    if String.toLower snippet.name == "@output" then
                        ( Log.add_Eval (Eval vis snippet.code []) Log.empty
                        , Array.slice 0 -1 ar
                        )

                    else
                        ( Log.empty, ar )

                _ ->
                    ( Log.empty, ar )

        add_state s =
            { s
                | code_vector =
                    Array.push (initProject array comment output) s.code_vector
            }
    in
    (\s ->
        s.code_vector
            |> Array.length
            |> Evaluate
            |> succeed
    )
        |> withState
        |> ignore (modifyState add_state)
