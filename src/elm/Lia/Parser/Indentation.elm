module Lia.Parser.Indentation exposing
    ( check
    , maybeCheck
    , pop
    , push
    , skip
    )

import Combine
    exposing
        ( Parser
        , ignore
        , maybe
        , modifyState
        , regex
        , string
        , succeed
        , withState
        )
import Lia.Parser.Context exposing (Context)


{-| **@private:** Skip the indentation on the `InputStream`, depending on the
current `Context` of the parser.
-}
par_ : Context -> Parser Context ()
par_ s =
    if s.indentation == [] then
        succeed ()

    else if s.indentation_skip then
        Combine.skip (succeed ())

    else
        String.concat s.indentation
            |> regex
            |> Combine.skip


maybePar_ : Context -> Parser Context ()
maybePar_ s =
    if s.indentation == [] then
        succeed ()

    else if s.indentation_skip then
        Combine.skip (succeed ())

    else
        let
            pattern =
                String.concat s.indentation
        in
        if String.trim pattern == "" then
            pattern
                |> regex
                |> maybe
                |> Combine.skip

        else
            let
                subPattern =
                    String.trimRight pattern
            in
            subPattern
                |> regex
                |> (String.repeat
                        (String.length pattern
                            - String.length subPattern
                        )
                        " "
                        |> string
                        |> maybe
                        |> ignore
                   )
                |> Combine.skip


{-| Check defined indentation on the `InputStream` and ignore it.
-}
check : Parser Context ()
check =
    withState par_
        |> ignore (modifyState (skip_ False))


maybeCheck : Parser Context ()
maybeCheck =
    withState maybePar_
        |> ignore (modifyState (skip_ False))


{-| Add indentation to the `Context`.
-}
push : String -> Parser Context ()
push str =
    modifyState
        (\state ->
            { state
                | indentation_skip = True
                , indentation = List.append state.indentation [ str ]
            }
        )


{-| Pop the last indentation-string from the `Context`.
-}
pop : Parser Context ()
pop =
    modifyState
        (\state ->
            { state
                | indentation_skip = False
                , indentation =
                    state.indentation
                        |> List.reverse
                        |> List.drop 1
                        |> List.reverse
            }
        )


{-| Ignore the indentation on the next check.
-}
skip : Parser Context ()
skip =
    modifyState (skip_ True)


skip_ : Bool -> Context -> Context
skip_ bool state =
    { state | indentation_skip = bool }
