module Lia.Markdown.Parser exposing (run)

import Combine exposing (..)
import Dict
import Lia.Chart.Parser as Chart
import Lia.Code.Parser as Code
import Lia.Effect.Parser as Effect
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (Annotation, Inlines, MultInlines)
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
                        [ Effect <$> md_annotations <*> Effect.markdown blocks
                        , Effect.comment paragraph
                        , Chart <$> Chart.parse
                        , formated_table
                        , simple_table
                        , Code <$> md_annotations <*> Code.parse
                        , quote
                        , horizontal_line
                        , Survey <$> Survey.parse
                        , Quiz <$> Quiz.parse <*> solution
                        , ordered_list
                        , unordered_list
                        , Paragraph <$> md_annotations <*> paragraph
                        ]
            in
            identation *> b


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
        <$> md_annotations
        <*> many1
                (regex "[*+-]( )"
                    *> (identation_append "  "
                            *> many1 (blocks <* regex "[\\n]?")
                            <* identation_pop
                       )
                )


ordered_list : Parser PState Markdown
ordered_list =
    OrderedList
        <$> md_annotations
        <*> many1
                (regex "[0-9]+\\. "
                    *> (identation_append "   "
                            *> many1 (blocks <* regex "[\\n]?")
                            <* identation_pop
                       )
                )


horizontal_line : Parser PState Markdown
horizontal_line =
    HLine <$> md_annotations <* regex "--[\\-]+"


paragraph : Parser PState Inlines
paragraph =
    ident_skip *> ((\l -> combine <| List.concat l) <$> many1 (identation *> line <* newline))


table_row : Parser PState MultInlines
table_row =
    identation *> manyTill (string "|" *> line) (regex "\\|[ \\t]*\\n")


simple_table : Parser PState Markdown
simple_table =
    ident_skip *> ((\a b -> Table a [] [] b) <$> md_annotations <*> many1 table_row) <* newline


formated_table : Parser PState Markdown
formated_table =
    let
        format =
            identation
                *> string "|"
                *> sepEndBy (string "|")
                    (choice
                        [ regex "[ \\t]*:--[\\-]+:[ \\t]*" $> "center"
                        , regex "[ \\t]*:--[\\-]+[ \\t]*" $> "left"
                        , regex "[ \\t]*--[\\-]+:[ \\t]*" $> "right"
                        , regex "[ \\t]*--[\\-]+[ \\t]*" $> "left"
                        ]
                    )
                <* regex "[ \\t]*\\n"
    in
    ident_skip *> (Table <$> md_annotations <*> table_row <*> format <*> many table_row) <* newline


quote : Parser PState Markdown
quote =
    Quote
        <$> md_annotations
        <*> (string "> "
                *> (identation_append ">( )?"
                        *> many1 (blocks <* maybe identation <* regex "[\\n]?")
                        <* identation_pop
                   )
            )


md_annotations : Parser PState Annotation
md_annotations =
    maybe (Dict.fromList <$> (regex "[ \\t]*" *> comment attribute <* maybe (regex "[ \\t]*\\n" <* identation)))
