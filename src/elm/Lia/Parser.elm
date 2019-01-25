module Lia.Parser exposing (formatError, parse_defintion, parse_section, parse_titles)

import Combine exposing (..)
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Parser as Markdown
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Preprocessor as Preprocessor
import Lia.Types exposing (Section)


parse_defintion : String -> String -> Result String ( Definition, String )
parse_defintion base code =
    case Combine.runParser Lia.Definition.Parser.parse (Lia.PState.init <| Lia.Definition.Types.default base) code of
        Ok ( state, data, _ ) ->
            Ok ( state.defines, data.input )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_titles : Definition -> String -> Result String (List ( Int, Inlines, String ))
parse_titles defines code =
    case Combine.runParser Preprocessor.run (Lia.PState.init defines) code of
        Ok ( _, _, rslt ) ->
            Ok rslt

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section :
    Definition
    -> Section
    -> Result String Section
parse_section global section =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (Lia.PState.init { global | section = section.idx })
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

        lineNumberOffset =
            floor (logBase 10 (toFloat location.line)) + 1

        separatorOffset =
            String.length separator

        padding =
            location.column + separatorOffset + 2
    in
    Debug.log "ERROR: "
        ("Parse error around line:\\n\\n"
            ++ String.fromInt location.line
            ++ separator
            ++ location.source
            ++ "\\n"
            ++ String.padLeft padding ' ' "^"
            ++ "\\nI expected one of the following:\\n"
            ++ expectationSeparator
            ++ String.join expectationSeparator ms
        )
