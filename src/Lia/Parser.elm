module Lia.Parser exposing (..)

--exposing (run)

import Combine exposing (..)
import Lia.Code.Types as Code
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Parser as Markdown
import Lia.Markdown.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Preprocessor as Preprocessor
import Lia.Quiz.Types as Quiz
import Lia.Survey.Types as Survey


parse_defintion : String -> Result String ( String, Definition )
parse_defintion code =
    case Combine.runParser Lia.Definition.Parser.parse Lia.Definition.Types.default code of
        Ok ( definition, data, _ ) ->
            Ok ( data.input, definition )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_titles : String -> Result String (List ( Int, Inlines, String ))
parse_titles code =
    case Combine.runParser Preprocessor.run Lia.PState.init code of
        Ok ( _, _, rslt ) ->
            Ok rslt

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section : String -> Result String ( List Markdown, Code.Vector, Quiz.Vector, Survey.Vector, Int )
parse_section str =
    case Combine.runParser Markdown.run Lia.PState.init str of
        Ok ( state, _, es ) ->
            Ok
                ( es
                , state.code_vector
                , state.quiz_vector
                , state.survey_vector
                , state.num_effects
                )

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
    "Parse error around line:\n\n"
        ++ toString location.line
        ++ separator
        ++ location.source
        ++ "\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\nI expected one of the following:\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator ms
