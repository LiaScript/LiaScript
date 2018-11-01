module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition, add_translation)
import Lia.Helper exposing (..)
import Lia.Macro.Parser as Macro
import Lia.Markdown.Inline.Parser exposing (comment, comments)
import Lia.PState exposing (PState, ident_skip, identation, identation_append, identation_pop)
import Lia.Utils exposing (string_replace)


parse : Parser PState ()
parse =
    lazy <|
        \() ->
            maybe (definition *> modifyState (\s -> { s | defines_updated = True }))
                *> whitespace
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
                            *> (ending >>= (\x -> set (\def -> { def | comment = string_replace ( "\n", " " ) x })))
                        , string "date:"
                            *> (ending >>= (\x -> set (\def -> { def | date = x })))
                        , string "email:"
                            *> (ending >>= (\x -> set (\def -> { def | email = x })))
                        , string "language:"
                            *> (ending >>= (\x -> set (\def -> { def | language = x })))
                        , string "logo:"
                            *> (ending >>= (\x -> set (\def -> { def | logo = x })))
                        , string "narrator:"
                            *> (ending >>= (\x -> set (\def -> { def | narrator = x })))
                        , string "script:"
                            *> (ending >>= (\x -> set (\def -> { def | links = append_to x def.base def.scripts })))
                        , string "link:"
                            *> (ending >>= (\x -> set (\def -> { def | links = append_to x def.base def.links })))
                        , string "translation:"
                            *> (ending >>= (\x -> set (add_translation x)))
                        , string "version:"
                            *> (ending >>= (\x -> set (\def -> { def | version = x })))
                        , ((,)
                            <$> (Macro.pattern <* regex "[ \\t]*:[ \\t]*")
                            <*> (regex ".+" <* newline)
                          )
                            >>= (\x -> set (Macro.add x))
                        , ((,)
                            <$> (Macro.pattern <* regex "[ \\t]*\\n")
                            <*> stringTill (string "\n@end")
                          )
                            >>= (\x -> set (Macro.add x))
                        ]
            in
            (many1 (whitespace *> list) <* whitespace)
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
            { def | base = toURL def.base x }
        )


toURL : String -> String -> String
toURL base url =
    if String.startsWith "http" url then
        url

    else
        base ++ url


set : (Definition -> Definition) -> Parser PState ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })


append_to : String -> String -> List String -> List String
append_to x base list =
    x
        |> String.split "\n"
        |> List.map (toURL base)
        |> List.append list
