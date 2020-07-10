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
        , or
        , regex
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
        , toURL
        )
import Lia.Markdown.Inline.Parser exposing (comment, line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser as Macro
import Lia.Parser.Context
    exposing
        ( Context
        , init
        )
import Lia.Parser.Helper exposing (stringTill)
import Lia.Settings.Model exposing (Mode(..))


parse : Parser Context ()
parse =
    definition
        |> keep (modifyState (\s -> { s | defines_updated = True }))
        |> maybe
        |> ignore whitespace
        |> skip


inline_parser : Definition -> String -> Inlines
inline_parser defines str =
    case
        str
            |> String.replace "\n" " "
            |> Combine.runParser line (init identity defines)
    of
        Ok ( _, _, rslt ) ->
            rslt

        Err _ ->
            []


definition : Parser Context ()
definition =
    lazy <|
        \() ->
            whitespace
                |> keep defs
                |> many1
                |> ignore whitespace
                |> comment
                |> skip


store : ( String, String ) -> Parser Context ()
store ( key_, value_ ) =
    case key_ of
        "attribute" ->
            set
                (\c ->
                    { c
                        | attributes =
                            [ inline_parser c value_ ]
                                |> List.append c.attributes
                    }
                )

        "author" ->
            set (\c -> { c | author = value_ })

        "base" ->
            set (\c -> { c | base = value_ })

        "comment" ->
            set
                (\c ->
                    let
                        singleLineComment =
                            reduce value_
                    in
                    Macro.add
                        ( "comment"
                        , singleLineComment
                        )
                        { c | comment = inline_parser c singleLineComment }
                )

        "dark" ->
            set
                (\c ->
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
                )

        "date" ->
            set (\c -> { c | date = value_ })

        "email" ->
            set (\c -> { c | email = value_ })

        "import" ->
            set (add_imports value_)

        "language" ->
            set (\c -> { c | language = value_ })

        "link" ->
            set (addToResources Link value_)

        "logo" ->
            set (\c -> { c | logo = toURL c.base value_ })

        "narrator" ->
            set (\c -> { c | narrator = value_ })

        "script" ->
            set (addToResources Script value_)

        "translation" ->
            set (add_translation value_)

        "version" ->
            set (\c -> { c | version = value_ })

        "mode" ->
            set
                (\c ->
                    { c
                        | mode =
                            case value_ |> String.toLower of
                                "textbook" ->
                                    Just Textbook

                                "presentation" ->
                                    Just Presentation

                                "slides" ->
                                    Just Slides

                                _ ->
                                    Nothing
                    }
                )

        "debug" ->
            set (\c -> { c | debug = value_ == "true" })

        "onload" ->
            set (\c -> { c | onload = value_ })

        _ ->
            set (Macro.add ( key_, value_ ))


defs : Parser Context ()
defs =
    choice
        [ regex "@@@.*\n" |> ignore multiline |> skip
        , regex "@@.*\n" |> ignore lines |> skip
        , key_value |> andThen store
        ]


key_value : Parser Context ( String, String )
key_value =
    key
        |> map Tuple.pair
        |> andMap value


start : Parser Context (Maybe String)
start =
    string "@"
        |> maybe


key : Parser Context String
key =
    start
        |> keep (regex "\\w+[\\w\\-.\\d]*")


value : Parser Context String
value =
    or
        (regex "[\\t ]*:" |> keep lines)
        (regex "[\t ]*\\n" |> keep multiline)


lines : Parser Context String
lines =
    regex "([ \\t].*|[ \\t]*\\n)+"
        |> map reduce


reduce : String -> String
reduce =
    String.words >> List.intersperse " " >> String.concat


multiline : Parser Context String
multiline =
    stringTill (string "\n@end")
        |> map
            (\x ->
                if String.startsWith "\n" x then
                    " " ++ x

                else
                    x
            )


set : (Definition -> Definition) -> Parser Context ()
set fct =
    modifyState (\s -> { s | defines = fct s.defines })
