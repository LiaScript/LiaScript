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
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, newline, spaces)
import Lia.Parser.Indentation as Indent
import Port.Eval exposing (Eval)


parse : Parser Context Parameters -> Parser Context Code
parse attr =
    sepBy1 newline (attr |> andThen listing)
        |> map Tuple.pair
        |> andMap
            (regex "[ \n]?"
                |> ignore (maybe Indent.check)
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
            highlight lst


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
        (maybe Indent.check |> keep (regex ("(?:.(?!" ++ control_frame ++ "))*\\n")))
        (Indent.check |> keep (regex control_frame |> ignore spaces))
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
            let
                model =
                    s.code_model
            in
            { s
                | code_model =
                    { model | evaluate = Array.push (initProject False array comment output) model.evaluate }
            }
    in
    (.code_model
        >> .evaluate
        >> Array.length
        >> Evaluate
        >> succeed
    )
        |> withState
        |> ignore (modifyState add_state)


highlight : List ( Snippet, Bool ) -> Parser Context Code
highlight lang_title_code =
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
            let
                model =
                    s.code_model
            in
            { s
                | code_model =
                    { model | highlight = Array.push (initProject True array "" output) model.highlight }
            }
    in
    (.code_model
        >> .highlight
        >> Array.length
        >> Highlight
        >> succeed
    )
        |> withState
        |> ignore (modifyState add_state)
