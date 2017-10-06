module Lia.Parser exposing (run)

import Combine exposing (..)
import Lia.Chart.Parser as Chart
import Lia.Code.Parser exposing (..)
import Lia.Code.Types exposing (CodeVector)
import Lia.Effect.Parser exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Inline(..))
import Lia.PState exposing (PState)
import Lia.Quiz.Parser as Quiz
import Lia.Quiz.Types exposing (QuizVector)
import Lia.Survey.Parser as Survey
import Lia.Survey.Types exposing (SurveyVector)
import Lia.Types exposing (..)


identation : Parser PState ()
identation =
    let
        ident s =
            if s.skip_identation then
                skip (succeed ())
            else
                String.repeat s.identation " "
                    |> string
                    |> skip

        reset s =
            { s | skip_identation = False }
    in
    withState ident <* modifyState reset


blocks : Parser PState Block
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ eblock blocks
                        , ecomment paragraph
                        , Chart <$> Chart.parse
                        , table
                        , CodeBlock <$> code
                        , quote_block
                        , horizontal_line
                        , SurveyBlock <$> Survey.parse
                        , Quiz <$> Quiz.parse <*> solution
                        , ordered_list
                        , unordered_list
                        , Paragraph <$> paragraph
                        ]
            in
            comments *> b


solution : Parser PState (Maybe ( List Block, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    maybe
        (rslt
            <$> (regex "( *)\\[\\[\\[[\\n]+"
                    *> withState (\s -> succeed s.num_effects)
                )
            <*> manyTill (blocks <* regex "[ \\n\\t]*") (regex "\\]\\]\\]")
            <*> withState (\s -> succeed s.num_effects)
        )


unordered_list : Parser PState Block
unordered_list =
    let
        mod_s b s =
            if b then
                { s | skip_identation = True, identation = s.identation + 2 }
            else
                { s | skip_identation = False, identation = s.identation - 2 }
    in
    BulletList
        <$> many1
                (identation
                    *> regex "[*+-]( )"
                    *> (modifyState (mod_s True)
                            *> many1 (blocks <* regex "[\\n]?")
                            <* modifyState (mod_s False)
                       )
                )


ordered_list : Parser PState Block
ordered_list =
    let
        mod_s b s =
            if b then
                { s | skip_identation = True, identation = s.identation + 3 }
            else
                { s | skip_identation = False, identation = s.identation - 3 }
    in
    OrderedList
        <$> many1
                (identation
                    *> regex "[0-9]+\\. "
                    *> (modifyState (mod_s True)
                            *> many1 (blocks <* regex "[\\n]?")
                            <* modifyState (mod_s False)
                       )
                )


horizontal_line : Parser PState Block
horizontal_line =
    HLine <$ (identation *> regex "--[\\-]+")


paragraph : Parser PState Paragraph
paragraph =
    (\l -> combine <| List.concat l) <$> many1 (identation *> line <* newline)


table : Parser PState Block
table =
    let
        ending =
            regex "\\|[ \\t]*" *> newline

        row =
            identation *> manyTill (string "|" *> many inlines) ending

        format =
            identation
                *> string "|"
                *> sepBy1 (string "|")
                    (choice
                        [ regex "[ \\t]*:--[\\-]+:[ \\t]*" $> "center"
                        , regex "[ \\t]*:--[\\-]+[ \\t]*" $> "left"
                        , regex "[ \\t]*--[\\-]+:[ \\t]*" $> "right"
                        , regex "[ \\t]*--[\\-]+[ \\t]*" $> "left"
                        ]
                    )
                <* ending

        simple_table =
            (Table [] [] <$> many1 row) <* newline

        format_table =
            (Table <$> row <*> format <*> many row) <* newline
    in
    choice [ format_table, simple_table ]


quote_block : Parser PState Block
quote_block =
    let
        p =
            identation *> string ">" *> optional [ Chars "" ] line <* newline
    in
    (\q -> Quote <| combine <| List.concat q) <$> many1 p


title_tag : Parser PState Int
title_tag =
    String.length <$> (newlines *> regex "#+" <* whitespace)


title_str : Parser PState String
title_str =
    String.trim <$> regex ".+[\\n]+"


slide : Parser PState Slide
slide =
    lazy <|
        \() ->
            let
                body =
                    many (blocks <* newlines)

                effect_counter =
                    let
                        pp par =
                            succeed par.num_effects

                        reset_effect c =
                            { c | num_effects = 0 }
                    in
                    withState pp <* modifyState reset_effect
            in
            Slide <$> title_tag <*> title_str <*> body <*> effect_counter


parse : Parser PState (List Slide)
parse =
    whitelines *> define_comment *> many1 slide


define_comment : Parser PState ()
define_comment =
    let
        ending =
            String.trim <$> regex "[^\\n]*"

        author x =
            modifyState (\s -> { s | def_author = x })

        date x =
            modifyState (\s -> { s | def_date = x })

        email x =
            modifyState (\s -> { s | def_email = x })

        language x =
            modifyState (\s -> { s | def_language = x })

        narrator x =
            modifyState (\s -> { s | def_narrator = x })

        script x =
            modifyState (\s -> { s | def_scripts = x :: s.def_scripts })

        version x =
            modifyState (\s -> { s | def_version = x })

        list =
            [ string "author:" *> (ending >>= author)
            , string "date:" *> (ending >>= date)
            , string "email:" *> (ending >>= email)
            , string "language:" *> (ending >>= language)
            , string "narrator:" *> (ending >>= narrator)
            , string "script:" *> (ending >>= script)
            , string "version:" *> (ending >>= version)
            ]
    in
    skip (comment (regex "[ \\t\\n]*" *> choice list <* regex "[\n]+"))


run : String -> Result String ( List Slide, CodeVector, QuizVector, SurveyVector, String, List String )
run script =
    case Combine.runParser parse Lia.PState.init script of
        Ok ( state, _, es ) ->
            Ok ( es, state.code_vector, state.quiz_vector, state.survey_vector, state.def_narrator, state.def_scripts )

        Err ( _, stream, ms ) ->
            Err <| formatError ms stream


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
