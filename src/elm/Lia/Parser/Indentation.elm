module Lia.Parser.Indentation exposing
    ( check
    , maybeCheck
    , pop
    , push
    , skip
    )

{-| The indentation of nested blocks (lists, quotes, footnotes, ...) is a stack
of regular expressions in the `Context`, every line within such a block has to
start with all of them.
-}

import Combine
    exposing
        ( Parser
        , app
        , ignore
        , maybe
        , modifyState
        , primitive
        , regex
        , string
        )
import Lia.Parser.Context exposing (Context)


{-| Check the defined indentation on the `InputStream` and ignore it.
-}
check : Parser Context ()
check =
    indentation strict


{-| Like `check`, but trailing spaces of the indentation are optional, so that
an empty line or a line with less indentation passes. An indentation of spaces
only is optional completely.
-}
maybeCheck : Parser Context ()
maybeCheck =
    indentation optional


{-| Nothing to check if there is no indentation or if it is skipped once,
otherwise check the concatenated indentation. Afterwards the indentation is
not skipped anymore.

This runs on every line, therefore it is a single `primitive` that does not
copy the `Context` if nothing changes.

-}
indentation : (String -> Parser Context ()) -> Parser Context ()
indentation checkPattern =
    primitive
        (\state stream ->
            if state.indentation_skip then
                ( skip_ False state, stream, Ok () )

            else if state.indentation == [] then
                ( state, stream, Ok () )

            else
                app (checkPattern (String.concat state.indentation)) state stream
        )


{-| The whole pattern has to match.
-}
strict : String -> Parser Context ()
strict =
    regex >> Combine.skip


{-| The pattern without its trailing spaces has to match, the spaces are
optional. A pattern of spaces only is therefore optional completely.
-}
optional : String -> Parser Context ()
optional pattern =
    let
        subPattern =
            String.trimRight pattern
    in
    regex subPattern
        |> ignore
            (String.repeat (String.length pattern - String.length subPattern) " "
                |> string
                |> maybe
            )
        |> Combine.skip


{-| Add indentation to the `Context`, it is not checked on the current line.
-}
push : String -> Parser Context ()
push str =
    modifyState
        (\state ->
            { state
                | indentation_skip = True
                , indentation = state.indentation ++ [ str ]
            }
        )


{-| Pop the last indentation from the `Context`.
-}
pop : Parser Context ()
pop =
    modifyState
        (\state ->
            { state
                | indentation_skip = False
                , indentation = List.take (List.length state.indentation - 1) state.indentation
            }
        )


{-| Ignore the indentation on the next check.
-}
skip : Parser Context ()
skip =
    modifyState (skip_ True)


{-| Set `indentation_skip`.
-}
skip_ : Bool -> Context -> Context
skip_ bool state =
    { state | indentation_skip = bool }
