module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition, add_macro, add_translation)
import Lia.Markdown.Inline.Parser exposing (comment, comments, stringTill, whitelines)
import Lia.PState exposing (PState, ident_skip, identation, identation_append, identation_pop)


parse : Parser PState ()
parse =
    lazy <|
        \() ->
            maybe (definition *> modifyState (\s -> { s | defines_updated = True }))
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
                            *> (ending >>= (\x -> set (\def -> { def | comment = x |> String.split "\n" |> String.join " " })))
                        , string "date:"
                            *> (ending >>= (\x -> set (\def -> { def | date = x })))
                        , string "email:"
                            *> (ending >>= (\x -> set (\def -> { def | email = x })))
                        , string "language:"
                            *> (ending >>= (\x -> set (\def -> { def | language = x })))
                        , string "narrator:"
                            *> (ending >>= (\x -> set (\def -> { def | narrator = x })))
                        , string "script:"
                            *> (ending >>= (\x -> set (\def -> { def | scripts = List.append def.scripts (String.split "\n" x) })))
                        , string "translation:"
                            *> (ending >>= (\x -> set (add_translation x)))
                        , string "version:"
                            *> (ending >>= (\x -> set (\def -> { def | version = x })))
                        , ((\name body -> ( name, body ))
                            <$> (macro <* regex "[ \\t]*\\n")
                            <*> stringTill (string "\n@end")
                          )
                            >>= (\x -> set (add_macro x))
                        ]
            in
            (many1 (whitelines *> list) <* whitelines)
                |> comment
                |> skip


ending : Parser PState String
ending =
    (\list -> list |> List.map String.trimLeft |> String.concat |> String.trimRight)
        <$> (identation_append "  "
                *> ident_skip
                *> many1 (identation *> regex ".+\\n")
                <* identation_pop
            )


base : String -> Parser PState ()
base x =
    set
        (\def ->
            { def
                | base =
                    if String.startsWith "http" x then
                        x
                    else
                        def.base ++ x
            }
        )


set : (Definition -> Definition) -> Parser PState ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })


macro : Parser PState String
macro =
    regex "@[a-zA-Z0-9_]+"



--eval_macro name =
--  let
--    inject state input context =
--
--  in
--  pri
