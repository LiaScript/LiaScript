module Lia.Definition.Parser exposing (parse)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , lazy
        , many1
        , map
        , maybe
        , modifyState
        , regex
        , regexWith
        , skip
        , string
        , whitespace
        )
import Lia.Definition.Types
    exposing
        ( Definition
        , Resource(..)
        , addToResources
        , add_imports
        , add_translation
        )
import Lia.Markdown.Inline.Parser exposing (comment, inlines)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context
    exposing
        ( Context
        , getLine
        , indentation
        , indentation_append
        , indentation_pop
        , indentation_skip
        , init
        )
import Lia.Parser.Helper exposing (newline, stringTill)


parse : Parser Context Int
parse =
    lazy <|
        \() ->
            definition
                |> keep (modifyState (\s -> { s | defines_updated = True }))
                |> maybe
                |> ignore whitespace
                |> keep getLine


inline_parser : Definition -> String -> Inlines
inline_parser defines str =
    case
        str
            |> String.replace "\n" " "
            |> Combine.runParser (many1 inlines) (init identity defines)
    of
        Ok ( _, _, rslt ) ->
            rslt

        Err _ ->
            []


definition : Parser Context ()
definition =
    lazy <|
        \() ->
            let
                list =
                    choice
                        [ store "author:" (\x d -> { d | author = x })
                        , store "base:" (\x d -> { d | base = x })
                        , store "comment:" (\x d -> { d | comment = String.replace "\n" " " x })
                        , store "attribute:" (\x d -> { d | attributes = [ inline_parser d x ] |> List.append d.attributes })
                        , store "date:" (\x d -> { d | date = x })
                        , store "email:" (\x d -> { d | email = x })
                        , store "language:" (\x d -> { d | language = x })
                        , store "logo:" (\x d -> { d | logo = x })
                        , store "narrator:" (\x d -> { d | narrator = x })
                        , store "script:" (addToResources Script)
                        , store "import:" add_imports
                        , store "link:" (addToResources Link)
                        , store "translation:" add_translation
                        , store "version:" (\x d -> { d | version = x })
                        , store "debug:"
                            (\x d ->
                                { d
                                    | debug =
                                        if x == "true" then
                                            True

                                        else
                                            False
                                }
                            )
                        , regex "@onload[\t ]*\\n"
                            |> keep (stringTill (string "\n@end"))
                            |> andThen (\x -> set (\def -> { def | onload = String.trim x }))
                        , Macro.pattern
                            |> ignore (regex "[\t ]*:[\t ]*")
                            |> map Tuple.pair
                            |> andMap (regex ".+")
                            |> ignore newline
                            |> andThen (\x -> set (Macro.add x))
                        , Macro.pattern
                            |> ignore (regex "[\t ]*\\n")
                            |> map Tuple.pair
                            |> andMap (stringTill (string "\n@end"))
                            |> andThen (\x -> set (Macro.add x))
                        ]
            in
            (whitespace |> keep list)
                |> many1
                |> ignore whitespace
                |> comment
                |> skip


store : String -> (String -> Definition -> Definition) -> Parser Context ()
store str fn =
    regexWith True False str |> keep (ending |> andThen (fn >> set))


ending : Parser Context String
ending =
    indentation_append "  "
        |> ignore indentation_skip
        |> keep (many1 (indentation |> keep (regex ".+\\n")))
        |> ignore indentation_pop
        |> map (\list -> list |> List.map String.trimLeft |> String.concat |> String.trimRight)


set : (Definition -> Definition) -> Parser Context ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })
