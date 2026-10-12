module Lia.Definition.Parser exposing (parse)

{-| Parser for the definitions in the main comment of a course and in the
comment at the beginning of a section:

    <!--
    author: Some Author
            continued by indented lines
    @macro
    multi-line value until
    @end
    @@ ignored, continued by indented lines
    @@@ ignored until
    @end
    -->

Known keys set the corresponding field of the `Definition`, all others are
stored as macros.

-}

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , many1
        , map
        , maybe
        , modifyState
        , or
        , regex
        , skip
        , string
        , whitespace
        )
import Dict
import I18n.Quotation exposing (quotation)
import Lia.Definition.Types exposing (Definition, Resource(..))
import Lia.Markdown.HTML.Attributes exposing (toURL)
import Lia.Markdown.Inline.Parser exposing (comment, line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context exposing (Context, getLine, init)
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Mode(..))


{-| Parse an optional definition comment and the following whitespace. A
parsed comment marks the definitions as updated, which turns them into the
definitions of the current section. Returns the current editor line.
-}
parse : Parser Context Int
parse =
    definition
        |> keep (modifyState (\s -> { s | defines_updated = True }))
        |> maybe
        |> ignore whitespace
        |> keep getLine


{-| The comment with all definitions, `<!--- ... -->` is ignored completely.
-}
definition : Parser Context ()
definition =
    whitespace
        |> keep defs
        |> many1
        |> ignore whitespace
        |> comment
        |> skip


{-| A single definition or an ignored `@@` / `@@@` block.
-}
defs : Parser Context ()
defs =
    choice
        [ regex "@@@.*\n" |> ignore multiline |> skip
        , regex "@@.*\n" |> ignore lines |> skip
        , key
            |> map Tuple.pair
            |> andMap value
            |> andThen store
        ]


{-| A key with an optional leading `@`.
-}
key : Parser Context String
key =
    maybe (string "@")
        |> keep (regex "\\w+[\\w\\-.\\d]*")


{-| `key: value` with indented continuation lines or `key` followed by a
multi-line value until `@end`.
-}
value : Parser Context String
value =
    or
        (regex "[\t ]*:" |> keep lines)
        (regex "[\t ]*\n" |> keep multiline)


{-| The rest of the line and all following indented or empty lines, joined by
single spaces.
-}
lines : Parser Context String
lines =
    regex "([ \t].*|[ \t]*\n)+"
        |> map reduce


{-| Everything until the next line that starts with `@end`, kept verbatim.
-}
multiline : Parser Context String
multiline =
    regex "[\\s\\S]*?\n@end"
        |> map (String.dropRight 5)


{-| Join all words by single spaces.
-}
reduce : String -> String
reduce =
    String.words >> String.join " "


{-| Store a definition, unknown keys become macros.
-}
store : ( String, String ) -> Parser Context ()
store ( key_, value_ ) =
    set <|
        case key_ of
            "attribute" ->
                \c -> { c | attributes = c.attributes ++ [ inlines c value_ ] }

            "author" ->
                \c -> { c | author = value_ }

            "base" ->
                \c -> { c | base = value_ }

            "comment" ->
                let
                    singleLine =
                        reduce value_
                in
                \c -> Macro.add ( "comment", singleLine ) { c | comment = inlines c singleLine }

            "dark" ->
                \c ->
                    { c
                        | lightMode =
                            case String.toLower value_ of
                                "true" ->
                                    Just False

                                "false" ->
                                    Just True

                                _ ->
                                    Nothing
                    }

            "date" ->
                \c -> { c | date = value_ }

            "debug" ->
                -- no longer used, but should not become a macro
                identity

            "email" ->
                \c -> { c | email = value_ }

            "formula" ->
                case String.split " " (String.trim value_) of
                    name :: formula ->
                        \c ->
                            { c
                                | formulas =
                                    Dict.insert
                                        (if String.startsWith "\\" name then
                                            name

                                         else
                                            "\\" ++ name
                                        )
                                        (formula |> String.join " " |> String.trim)
                                        c.formulas
                            }

                    [] ->
                        identity

            "icon" ->
                \c -> Macro.add ( "icon", url c value_ ) c

            "import" ->
                \c -> { c | imports = c.imports ++ urls link c value_ }

            "language" ->
                \c -> { c | language = value_, typographic_quotation = quotation value_ }

            "link" ->
                \c -> { c | resources = c.resources ++ urls Link c value_ }

            "logo" ->
                \c -> { c | logo = url c value_ }

            "mode" ->
                \c ->
                    { c
                        | mode =
                            case String.toLower value_ of
                                "textbook" ->
                                    Just Textbook

                                "presentation" ->
                                    Just Presentation

                                "slides" ->
                                    Just Slides

                                _ ->
                                    Nothing
                    }

            "narrator" ->
                \c -> { c | narrator = value_ }

            "onload" ->
                \c -> { c | onload = value_ }

            "script" ->
                \c -> { c | resources = c.resources ++ urls Script c value_ }

            "SCRIPT" ->
                \c -> { c | resources = c.resources ++ urls Module c value_ }

            "translation" ->
                case String.words value_ of
                    [ lang, file ] ->
                        \c -> { c | translation = Dict.insert lang (url c file) c.translation }

                    _ ->
                        identity

            "version" ->
                \c -> { c | version = value_ }

            _ ->
                Macro.add ( key_, value_ )


{-| Parse a value like `comment` or `attribute` as a single line of inline
elements.
-}
inlines : Definition -> String -> Inlines
inlines defines str =
    case
        str
            |> String.replace "\n" " "
            |> Combine.runParser line (init Dict.empty Nothing Nothing 0 defines)
    of
        Ok ( _, _, rslt ) ->
            rslt

        Err _ ->
            []


{-| Make a relative URL absolute.
-}
url : Definition -> String -> String
url def =
    toURL def.base def.appendix


{-| All whitespace separated URLs of a value, made absolute and passed to `to`.
-}
urls : (String -> a) -> Definition -> String -> List a
urls to def =
    String.words >> List.map (url def >> to)


{-| Update the definitions.
-}
set : (Definition -> Definition) -> Parser Context ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })
