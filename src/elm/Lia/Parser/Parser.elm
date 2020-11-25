module Lia.Parser.Parser exposing
    ( parse_defintion
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
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Parser as Markdown
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Parser.Context exposing (Context, init)
import Lia.Parser.Helper exposing (stringTill)
import Lia.Parser.Preprocessor as Preprocessor
import Lia.Section as Section exposing (Section, SubSection(..))


parse_defintion : String -> String -> Result String ( Definition, String )
parse_defintion base code =
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
                |> init identity
            )
            (code ++ "\n")
    of
        Ok ( state, data, _ ) ->
            Ok ( state.defines, "#" ++ data.input )

        Err ( _, stream, ms ) ->
            if String.trim code == "" then
                parse_defintion base notification

            else
                Err (formatError ms stream)


parse_titles : Definition -> String -> Result String ( Section.Base, String )
parse_titles defines code =
    case Combine.runParser Preprocessor.section (init identity defines) code of
        Ok ( _, data, rslt ) ->
            Ok ( rslt, data.input )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section :
    (String -> String)
    -> Definition
    -> Section
    -> Result String Section
parse_section search_index global sec =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (init search_index { global | section = sec.idx })
            sec.code
    of
        Ok ( state, _, es ) ->
            return sec state es

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


parse_subsection : String -> Result String SubSection
parse_subsection code =
    case
        Combine.runParser
            (Lia.Definition.Parser.parse |> keep Markdown.run)
            (init identity (Lia.Definition.Types.default ""))
            (String.trim code ++ "\n")
    of
        Ok ( state, _, es ) ->
            Ok <|
                case es of
                    [ Paragraph [] sub ] ->
                        SubSubSection
                            { visible = True
                            , body = sub
                            , error = Nothing
                            , effect_model = state.effect_model
                            }

                    _ ->
                        SubSection
                            { visible = True
                            , body = es
                            , error = Nothing
                            , code_vector = state.code_vector
                            , quiz_vector = state.quiz_vector
                            , survey_vector = state.survey_vector
                            , table_vector = state.table_vector
                            , effect_model = state.effect_model
                            , footnotes = state.footnotes
                            , footnote2show = Nothing
                            }

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err


return : Section -> Context -> List Markdown -> Result String Section
return sec state es =
    Ok
        { sec
            | body = es
            , error = Nothing
            , visited = True
            , code_vector = state.code_vector
            , quiz_vector = state.quiz_vector
            , survey_vector = state.survey_vector
            , table_vector = state.table_vector
            , effect_model = state.effect_model
            , footnotes = state.footnotes
            , definition =
                if state.defines_updated then
                    Just state.defines

                else
                    Nothing
            , parsed = True
        }


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


notification : String
notification =
    """# Welcome to LiaScript (Ups)

> The file you have loaded does not contain any content or it is not a valid
> Markdown file.

LiaScript is domain specific language that is based on Markdown. For more
information visit:

* Project-website: https://LiaScript.github.io
* Documentation: https://github.com/liascript/docs
* YouTube: https://www.youtube.com/channel/UCyiTe2GkW_u05HSdvUblGYg
  """
