module Lia.Parser.Parser exposing
    ( formatError
    , parse_defintion
    , parse_section
    , parse_titles
    )

import Combine exposing (InputStream, currentLocation, keep)
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Parser as Markdown
import Lia.Parser.Context exposing (init)
import Lia.Parser.Preprocessor as Preprocessor
import Lia.Types exposing (Section, SectionBase)


parse_defintion : String -> String -> Result String ( Definition, String )
parse_defintion base code =
    case Combine.runParser Lia.Definition.Parser.parse (init identity <| Lia.Definition.Types.default base) code of
        Ok ( state, data, _ ) ->
            Ok ( state.defines, data.input )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_titles : Definition -> String -> Result String (List SectionBase)
parse_titles defines code =
    case Combine.runParser Preprocessor.run (init identity defines) code of
        Ok ( _, _, rslt ) ->
            Ok rslt

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section :
    (String -> String)
    -> Definition
    -> Section
    -> Result String Section
parse_section search_index global section =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (init search_index { global | section = section.idx })
            section.code
    of
        Ok ( state, _, es ) ->
            Ok
                { section
                    | body = es
                    , error = Nothing
                    , visited = True
                    , code_vector = state.code_vector
                    , quiz_vector = state.quiz_vector
                    , survey_vector = state.survey_vector
                    , effect_model = state.effect_model
                    , footnotes = state.footnotes
                    , definition =
                        if state.defines_updated then
                            Just state.defines

                        else
                            Nothing
                    , parsed = True
                }

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


formatError : List String -> InputStream -> String
formatError ms stream =
    let
        location =
            currentLocation stream

        separator =
            "|> "

        expectationSeparator =
            "\n  * "

        --        lineNumberOffset =
        --            floor (logBase 10 (toFloat location.line)) + 1
        separatorOffset =
            String.length separator

        padding =
            location.column + separatorOffset + 2
    in
    "Parse error around line:\\n\\n"
        ++ String.fromInt location.line
        ++ separator
        ++ location.source
        ++ "\\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\\nI expected one of the following:\\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator ms
