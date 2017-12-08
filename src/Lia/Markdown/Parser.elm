module Lia.Markdown.Parser exposing (run)

import Combine exposing (..)
import Lia.Chart.Parser as Chart
import Lia.Code.Parser as Code
import Lia.Effect.Parser exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Types exposing (..)
import Lia.PState exposing (..)
import Lia.Quiz.Parser as Quiz
import Lia.Survey.Parser as Survey


run : Parser PState (List Markdown)
run =
    lazy <|
        \() ->
            many (blocks <* newlines)


blocks : Parser PState Markdown
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ eblock blocks
                        , ecomment paragraph
                        , Chart <$> Chart.parse
                        , formated_table
                        , simple_table
                        , Code <$> Code.parse
                        , quote
                        , horizontal_line
                        , Survey <$> Survey.parse
                        , Quiz <$> Quiz.parse <*> solution
                        , ordered_list
                        , unordered_list
                        , Paragraph <$> paragraph
                        ]
            in
            comments *> identation *> b


solution : Parser PState (Maybe ( List Markdown, Int ))
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


unordered_list : Parser PState Markdown
unordered_list =
    BulletList
        <$> many1
                (regex "[*+-]( )"
                    *> (identation_append "  "
                            *> many1 (blocks <* regex "[\\n]?")
                            <* identation_pop
                       )
                )


ordered_list : Parser PState Markdown
ordered_list =
    OrderedList
        <$> many1
                (regex "[0-9]+\\. "
                    *> (identation_append "   "
                            *> many1 (blocks <* regex "[\\n]?")
                            <* identation_pop
                       )
                )


horizontal_line : Parser PState Markdown
horizontal_line =
    HLine <$ regex "--[\\-]+"


paragraph : Parser PState Inlines
paragraph =
    ident_skip *> ((\l -> combine <| List.concat l) <$> many1 (identation *> line <* newline))


table_row : Parser PState MultInlines
table_row =
    identation *> manyTill (string "|" *> line) (regex "\\|[ \\t]*\\n")


simple_table : Parser PState Markdown
simple_table =
    ident_skip *> (Table [] [] <$> many1 table_row) <* newline


formated_table : Parser PState Markdown
formated_table =
    let
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
                <* regex "\\|[ \\t]*\\n"
    in
    ident_skip *> (Table <$> table_row <*> format <*> many table_row) <* newline


quote : Parser PState Markdown
quote =
    string "> "
        *> identation_append "> "
        *> (Quote
                <$> many1 blocks
           )
        <* identation_pop
