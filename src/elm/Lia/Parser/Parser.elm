module Lia.Parser.Parser exposing
    ( parse_definition
    , parse_section
    , parse_subsection
    , parse_titles
    )

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
import Lia.Graph.Graph as Graph exposing (Graph)
import Lia.Markdown.Parser as Markdown
import Lia.Markdown.Types exposing (Block(..), Blocks)
import Lia.Parser.Context exposing (Context, init)
import Lia.Parser.Helper exposing (stringTill)
import Lia.Parser.Preprocessor as Preprocessor
import Lia.Section as Section exposing (Section, SubSection(..))


parse_definition : String -> String -> Result String ( Definition, String )
parse_definition base code =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse
                |> ignore
                    (or (string "#")
                        (stringTill (regex "\n#"))
                    )
            )
            (base
                |> Lia.Definition.Types.default
                |> init Graph.init Nothing
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
                        |> Error.Message.parseDefinition code



--<|formatError ms stream)


parse_titles : Definition -> String -> Result String ( Section.Base, String )
parse_titles defines code =
    case Combine.runParser Preprocessor.section (init Graph.init Nothing defines) code of
        Ok ( _, data, rslt ) ->
            Ok ( rslt, data.input )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section :
    Graph
    -> (String -> String)
    -> Definition
    -> Section
    -> Result String ( Graph, Section )
parse_section graph search_index global sec =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (init graph (Just search_index) { global | section = sec.id })
            sec.code
    of
        Ok ( state, _, es ) ->
            return sec state es

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


parse_subsection : Maybe Definition -> Int -> String -> Result String SubSection
parse_subsection globals id code =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (globals
                |> Maybe.withDefault (Lia.Definition.Types.default "")
                |> init Nothing
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


return : Section -> Context -> Blocks -> Result String ( Graph, Section )
return sec state es =
    Ok
        ( state.graph
        , { sec
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
        )


formatError : List String -> InputStream -> String
formatError ms stream =
    let
        location =
            currentLocation stream

        separator =
            "\n "

        expectationSeparator =
            "\n  * "

        --        lineNumberOffset =
        --            floor (logBase 10 (toFloat location.line)) + 1
        separatorOffset =
            String.length separator

        padding =
            location.column + separatorOffset + 2
    in
    "Parse error around line: "
        ++ String.fromInt location.line
        ++ separator
        ++ location.source
        ++ "\n"
        ++ String.padLeft padding ' ' "^"
        ++ "\nI expected one of the following:\n"
        ++ expectationSeparator
        ++ String.join expectationSeparator ms
