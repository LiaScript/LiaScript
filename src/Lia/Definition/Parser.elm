module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition)
import Lia.Inline.Parser exposing (comment, comments, whitelines)


parse : Parser Definition ()
parse =
    lazy <|
        \() ->
            definition
                *> many (choice [ whitelines, comments ])
                |> skip


definition : Parser Definition ()
definition =
    lazy <|
        \() ->
            let
                list =
                    choice
                        [ string "author:" *> (ending >>= author)
                        , string "date:" *> (ending >>= date)
                        , string "email:" *> (ending >>= email)
                        , string "language:" *> (ending >>= language)
                        , string "narrator:" *> (ending >>= narrator)
                        , string "script:" *> (ending >>= script)
                        , string "version:" *> (ending >>= version)
                        ]
            in
            (whitelines *> list <* whitelines)
                |> comment
                |> skip


ending : Parser s String
ending =
    String.trim <$> regex "[^\\n]+"


author x =
    modifyState (\s -> { s | author = x })


date x =
    modifyState (\s -> { s | date = x })


email x =
    modifyState (\s -> { s | email = x })


language x =
    modifyState (\s -> { s | language = x })


narrator x =
    modifyState (\s -> { s | narrator = x })


script x =
    modifyState (\s -> { s | scripts = x :: s.scripts })


version x =
    modifyState (\s -> { s | version = x })
