module Lia.Parser.Parser exposing
    ( parse_definition
    , parse_section
    , parse_subsection
    , parse_titles
    )

{-| Entry points for parsing a course: the main definitions, the splitting into
sections and the parsing of a section or a sub-section (used by effects).
-}

import Combine
    exposing
        ( InputStream
        , currentLocation
        , ignore
        , keep
        , or
        , regex
        , string
        )
import Error.Message
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Parser as Markdown
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Parser.Context exposing (Context, init)
import Lia.Parser.Helper exposing (stringTill)
import Lia.Parser.Preprocessor as Preprocessor
import Lia.Section as Section exposing (Section, SubSection(..))


{-| Parse the main definitions with the `base` URL and `appendix` query, the
result also contains the code that starts with the first title.
-}
parse_definition : String -> String -> String -> Result String ( Definition, String )
parse_definition base appendix code =
    case
        Combine.runParser
            -- used to prevent false outputs if the first line does not start with a comment
            (regex "\\s*"
                |> keep Lia.Definition.Parser.parse
                |> ignore
                    (or (string "#")
                        (stringTill (regex "\n#"))
                    )
            )
            (Lia.Definition.Types.default base appendix
                |> init Nothing Nothing
            )
            (code ++ "\n")
    of
        Ok ( state, data, _ ) ->
            Ok ( state.defines, "#" ++ data.input )

        Err ( _, stream, ms ) ->
            Err <|
                if String.trim code == "" then
                    Error.Message.emptyFile

                else
                    formatError ms stream
                        |> Error.Message.parseDefinition True ( code, currentLocation stream |> .line )


{-| Get the next section (title and body) and the remaining code.
-}
parse_titles : Definition -> String -> Result String ( Section.Base, String )
parse_titles defines code =
    case Combine.runParser Preprocessor.section (init Nothing Nothing defines) code of
        Ok ( _, data, rslt ) ->
            Ok ( rslt, data.input )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


{-| Parse the body of a section, with its own definitions if there are any.
-}
parse_section :
    (String -> String)
    -> Definition
    -> Section
    -> Result String Section
parse_section search_index global sec =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (init (Just sec.seed) (Just search_index) { global | section = sec.id })
            sec.code
    of
        Ok ( state, _, es ) ->
            return sec state es

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


{-| Parse the code of a sub-section, a single paragraph becomes a
`SubSubSection` of inline elements.
-}
parse_subsection : Maybe Definition -> Int -> String -> Result String SubSection
parse_subsection globals id code =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (globals
                |> Maybe.withDefault (Lia.Definition.Types.default "" "")
                -- TODO: random
                |> init Nothing Nothing
            )
            (String.trim code ++ "\n")
    of
        Ok ( state, _, es ) ->
            Ok <|
                case es of
                    [ Paragraph [] sub ] ->
                        SubSubSection
                            { id = id
                            , body = sub
                            , error = Nothing
                            , effect_model = state.effect_model
                            }

                    _ ->
                        SubSection
                            { id = id
                            , body = es
                            , error = Nothing
                            , code_model = state.code_model
                            , task_vector = state.task_vector
                            , quiz_vector = state.quiz_vector
                            , survey_vector = state.survey_vector
                            , table_vector = state.table_vector
                            , gallery_vector = state.gallery_vector
                            , effect_model = state.effect_model
                            , footnotes = state.footnotes
                            , footnote2show = Nothing
                            }

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


{-| Store the parsed body and all states of the `Context` in the section.
-}
return : Section -> Context -> Blocks -> Result String Section
return sec state es =
    Ok
        { sec
            | body = es
            , error = Nothing
            , code_model = state.code_model
            , task_vector = state.task_vector
            , quiz_vector = state.quiz_vector
            , survey_vector = state.survey_vector
            , table_vector = state.table_vector
            , gallery_vector = state.gallery_vector
            , effect_model = state.effect_model
            , footnotes = state.footnotes
            , definition =
                if state.defines_updated then
                    Just state.defines

                else
                    Nothing
            , parsed = True
        }


{-| An error message with the line, a marker at the column and all expected
alternatives.
-}
formatError : List String -> InputStream -> String
formatError ms stream =
    let
        location =
            currentLocation stream

        separator =
            "\n\n"

        expectationSeparator =
            "\n* "

        padding =
            location.column + String.length separator + 2
    in
    "Parse error around line: "
        ++ String.fromInt location.line
        ++ separator
        ++ location.source
        ++ "\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\nI expected one of the following:\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator (List.map (\s -> String.append s "\n") ms)
