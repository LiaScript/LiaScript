module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Parser exposing (comment, comments, whitelines)
import Lia.PState exposing (PState)


parse : Parser PState ()
parse =
    lazy <|
        \() ->
            maybe definition
                *> many (choice [ whitelines, comments ])
                |> skip


definition : Parser PState ()
definition =
    lazy <|
        \() ->
            let
                list =
                    choice
                        [ string "author:"
                            *> (ending >>= (\x -> set (\def -> { def | author = x })))
                        , string "base:"
                            *> (ending >>= (\x -> set (\def -> { def | base = x })))
                        , string "comment:"
                            *> (ending >>= (\x -> set (\def -> { def | comment = x })))
                        , string "date:"
                            *> (ending >>= (\x -> set (\def -> { def | date = x })))
                        , string "email:"
                            *> (ending >>= (\x -> set (\def -> { def | email = x })))
                        , string "language:"
                            *> (ending >>= (\x -> set (\def -> { def | language = x })))
                        , string "narrator:"
                            *> (ending >>= (\x -> set (\def -> { def | narrator = x })))
                        , string "script:"
                            *> (ending >>= (\x -> set (\def -> { def | scripts = x :: def.scripts })))
                        , string "version:"
                            *> (ending >>= (\x -> set (\def -> { def | author = x })))
                        ]
            in
            (whitelines *> list <* whitelines)
                |> comment
                |> skip


ending : Parser s String
ending =
    String.trim <$> regex "[^\\n]+"


set : (Definition -> Definition) -> Parser PState ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })
