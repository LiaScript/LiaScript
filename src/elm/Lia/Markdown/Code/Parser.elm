module Lia.Markdown.Code.Parser exposing (parse)

{-| Parser for code blocks: one or more consecutive listings, optionally
followed by a macro that expands to a `<script>`, which makes the block
executable. A last listing titled `@output` is not shown as a file but as
the initial output of the terminal.
-}

import Array exposing (Array)
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
        , withState
        )
import Lia.Markdown.Code.Log as Log exposing (Log)
import Lia.Markdown.Code.Types exposing (Code(..), Snippet, initProject)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (javascript)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, newline, spaces)
import Lia.Parser.Indentation as Indent
import Service.Script exposing (Eval)


{-| Parse a code block, every listing can be preceded by annotations (`attr`)
and macros. The result points to the project that was added to the
`code_model` of the parser state.
-}
parse : Parser Context Parameters -> Parser Context Code
parse attr =
    sepBy1 Indent.check
        (maybe macro
            |> keep attr
            |> ignore (maybe macro)
            |> andThen listing
        )
        |> map store
        |> andMap
            (maybe Indent.check
                |> keep macro
                |> keep javascript
                |> maybe
            )
        |> andThen identity


{-| Add the listings as a new project, executable if there is a script.
-}
store : List ( Snippet, Bool ) -> Maybe String -> Parser Context Code
store listings script =
    let
        ( snippets, log ) =
            output listings
    in
    withState
        (\state ->
            let
                model =
                    state.code_model
            in
            case script of
                Just evaluation ->
                    modifyState (\s -> { s | code_model = { model | evaluate = Array.push (initProject False snippets evaluation log) model.evaluate } })
                        |> onsuccess (Evaluate (Array.length model.evaluate))

                Nothing ->
                    modifyState (\s -> { s | code_model = { model | highlight = Array.push (initProject True snippets "" log) model.highlight } })
                        |> onsuccess (Highlight (Array.length model.highlight))
        )


{-| Split off a last listing titled `@output` (case-insensitive) as log.
-}
output : List ( Snippet, Bool ) -> ( Array ( Snippet, Bool ), Log )
output listings =
    case List.reverse listings of
        ( snippet, visible ) :: rest ->
            if String.toLower snippet.name == "@output" then
                ( Array.fromList (List.reverse rest)
                , Log.add_Eval (Eval visible snippet.code []) Log.empty
                )

            else
                ( Array.fromList listings, Log.empty )

        [] ->
            ( Array.empty, Log.empty )


{-| A single listing: fence, language, optional `+`/`-` (visible/hidden)
with title and the body up to a closing fence of the same length.
-}
listing : Parameters -> Parser Context ( Snippet, Bool )
listing attr =
    c_frame
        |> andThen
            (\len ->
                header
                    |> map (\lang ( visible, name ) code -> ( Snippet attr lang (String.trim name) code, visible ))
                    |> andMap title
                    |> andMap (or (body "`" len) (body "~" len))
            )


{-| The language, lowercased.
-}
header : Parser Context String
header =
    spaces
        |> keep (regex "\\w*")
        |> map String.toLower


{-| Visibility (`+` is the default) and title, the rest of the line.
-}
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


{-| All lines up to a closing fence of `len` times `char`, alone on its line.
A line that contains the fence anywhere after its first character fails the
whole body.
-}
body : String -> Int -> Parser Context String
body char len =
    let
        fence =
            char ++ "{" ++ String.fromInt len ++ "}"
    in
    manyTill
        (Indent.maybeCheck |> keep (regex ("(?:.(?!" ++ fence ++ "))*\n")))
        (Indent.check
            |> ignore (regex "[ \t]*")
            |> keep (regex fence)
            |> ignore spaces
            |> ignore newline
        )
        |> map (String.concat >> String.dropRight 1)
