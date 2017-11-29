module Lia.Parser exposing (..)

--exposing (run)

import Combine exposing (..)
import Lia.Code.Types exposing (Codes)
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Markdown.Parser exposing (section)
import Lia.PState exposing (PState)
import Lia.Preprocessor as Preprocessor
import Lia.Types exposing (..)


parse_defintion : String -> Result String ( String, Definition )
parse_defintion code =
    case Combine.runParser Lia.Definition.Parser.parse Lia.Definition.Types.default code of
        Ok ( definition, data, _ ) ->
            Ok ( data.input, definition )

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_titles : String -> Result String (List ( Int, String, String ))
parse_titles code =
    case Combine.runParser Preprocessor.run () code of
        Ok ( _, _, rslt ) ->
            Ok rslt

        Err ( _, stream, ms ) ->
            Err (formatError ms stream)


parse_section : ID -> String -> Result String ( List Block, Codes )
parse_section idx str =
    case Combine.runParser section (Lia.PState.init idx) str of
        Ok ( state, _, es ) ->
            Ok ( es, state.code_vector )

        Err ( _, stream, ms ) ->
            formatError ms stream |> Err



--
-- slide : Parser PState Slide
-- slide =
--     lazy <|
--         \() ->
--             let
--                 body =
--                     many (blocks <* newlines)
--
--                 effect_counter =
--                     let
--                         pp par =
--                             succeed par.num_effects
--
--                         reset_effect c =
--                             { c | num_effects = 0 }
--                     in
--                     withState pp <* modifyState reset_effect
--             in
--             Slide <$> title_tag <*> title_str <*> body <*> effect_counter
--
--
-- parse : Parser PState (List Slide)
-- parse =
--     whitelines *> define_comment *> many1 slide
--
--
--
--
-- run : String -> Result String ( List Slide, CodeVector, QuizVector, SurveyVector, String, List String )
-- run script =
--     case Combine.runParser parse Lia.PState.init script of
--         Ok ( state, _, es ) ->
--             Ok ( es, state.code_vector, state.quiz_vector, state.survey_vector, state.def_narrator, state.def_scripts )
--
--         Err ( _, stream, ms ) ->
--             Err <| formatError ms stream
--
--


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
