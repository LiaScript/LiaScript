module Lia.Markdown.Parser exposing (section)

--exposing (run)

import Combine exposing (..)
import Lia.Chart.Parser as Chart
import Lia.Code.Parser as Code
import Lia.Code.Types exposing (Codes)
import Lia.Definition.Parser
import Lia.Definition.Types exposing (Definition)
import Lia.Effect.Parser exposing (..)
import Lia.Helper exposing (ID)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Inline(..))
import Lia.PState exposing (PState)
import Lia.Preprocessor as Preprocessor
import Lia.Quiz.Parser as Quiz
import Lia.Quiz.Types exposing (QuizVector)
import Lia.Survey.Parser as Survey
import Lia.Survey.Types exposing (SurveyVector)
import Lia.Types exposing (..)


section : Parser PState (List Block)
section =
    lazy <|
        \() ->
            many (blocks <* newlines)


identation : Parser PState ()
identation =
    lazy <|
        \() ->
            let
                ident s =
                    if s.identation == 0 then
                        succeed ()
                    else if s.skip_identation then
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
                        , Code <$> Code.parse
                        , quote_block
                        , horizontal_line
                        , Survey <$> Survey.parse
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
