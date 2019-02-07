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
        , regex
        , sepBy1
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Code.Types exposing (Code(..), File, Snippet, noLog)
import Lia.Markdown.Inline.Parser exposing (javascript)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Parser.Helper exposing (c_frame, newline, spaces)
import Lia.Parser.State exposing (State, identation)


parse : Parser State Code
parse =
    sepBy1 newline listing
        |> map Tuple.pair
        |> andMap
            (regex "[ \n]?"
                |> ignore (maybe identation)
                |> keep macro
                |> keep javascript
                |> maybe
            )
        |> andThen result


result : ( List ( Snippet, Bool ), Maybe String ) -> Parser State Code
result ( lst, script ) =
    case script of
        Just str ->
            evaluate lst str

        Nothing ->
            lst
                |> List.map Tuple.first
                |> Highlight
                |> succeed


header : Parser State String
header =
    spaces
        |> keep (regex "\\w*")
        |> map String.toLower


title : Parser State ( Bool, String )
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


code_body : Int -> Parser State String
code_body len =
    let
        control_frame =
            "`{" ++ String.fromInt len ++ "}"
    in
    manyTill
        (maybe identation |> keep (regex ("(?:.(?!" ++ control_frame ++ "))*\\n")))
        (identation |> keep (regex control_frame))
        |> map (String.concat >> String.dropRight 1)


listing : Parser State ( Snippet, Bool )
listing =
    let
        body len =
            header
                |> map (\h ( v, t ) c -> ( Snippet h t c, v ))
                |> andMap title
                |> andMap (code_body len)
    in
    c_frame |> andThen body


toFile : ( Snippet, Bool ) -> File
toFile ( { lang, name, code }, visible ) =
    File lang name code visible False


evaluate : List ( Snippet, Bool ) -> String -> Parser State Code
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
                                [ ( Array.map (Tuple.first >> .code) array, noLog ) ]
                        , evaluation = comment
                        , version_active = 0
                        , log = noLog
                        , running = False
                        , terminal = Nothing
                        }
                        s.code_vector
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
