module Lia.Definition.Parser exposing (parse)

import Combine exposing (..)
import Lia.Definition.Types exposing (Definition)
import Lia.Inline.Parser exposing (comment, comments, whitelines)


parse : Parser Definition ()
parse =
    lazy <|
        \() ->
            definition
                *> many (choice [ whitelines, comments ])
                |> skip


definition : Parser Definition ()
definition =
    lazy <|
        \() ->
            let
                list =
                    choice
                        [ string "author:" *> (ending >>= author)
                        , string "date:" *> (ending >>= date)
                        , string "email:" *> (ending >>= email)
                        , string "language:" *> (ending >>= language)
                        , string "narrator:" *> (ending >>= narrator)
                        , string "script:" *> (ending >>= script)
                        , string "version:" *> (ending >>= version)
                        ]
            in
            (whitelines *> list <* whitelines)
                |> comment
                |> skip


ending : Parser s String
ending =
    String.trim <$> regex "[^\\n]+"


author x =
    modifyState (\s -> { s | author = x })


date x =
    modifyState (\s -> { s | date = x })


email x =
    modifyState (\s -> { s | email = x })


language x =
    modifyState (\s -> { s | language = x })


narrator x =
    modifyState (\s -> { s | narrator = x })


script x =
    modifyState (\s -> { s | scripts = x :: s.scripts })


version x =
    modifyState (\s -> { s | version = x })



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
-- formatError : List String -> InputStream -> String
-- formatError ms stream =
--     let
--         location =
--             currentLocation stream
--
--         separator =
--             "|> "
--
--         expectationSeparator =
--             "\n  * "
--
--         lineNumberOffset =
--             floor (logBase 10 (toFloat location.line)) + 1
--
--         separatorOffset =
--             String.length separator
--
--         padding =
--             location.column + separatorOffset + 2
--     in
--     "Parse error around line:\n\n"
--         ++ toString location.line
--         ++ separator
--         ++ location.source
--         ++ "\n"
--         ++ String.padLeft padding ' ' "^"
--         ++ "\nI expected one of the following:\n"
--         ++ expectationSeparator
--         ++ String.join expectationSeparator ms
