module Lia.Markdown.Parser exposing (run)

import Combine exposing (..)
import Dict
import Lia.Chart.Parser as Chart
import Lia.Code.Parser as Code
import Lia.Effect.Model exposing (set_annotation)
import Lia.Effect.Parser as Effect
import Lia.Helper exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Inline.Parser exposing (..)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Types exposing (..)
import Lia.PState exposing (..)
import Lia.Quiz.Parser as Quiz
import Lia.Survey.Parser as Survey
import SvgBob


run : Parser PState (List Markdown)
run =
    many (footnotes *> blocks <* newlines) <* footnotes


footnotes : Parser PState ()
footnotes =
    (Footnote.block ident_blocks <* newlines)
        |> many
        |> skip


blocks : Parser PState Markdown
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ Effect <$> md_annotations <*> Effect.markdown blocks
                        , ((,) <$> md_annotations <*> Effect.comment paragraph) >>= to_comment
                        , Chart <$> md_annotations <*> Chart.parse
                        , formated_table
                        , simple_table
                        , svgbob
                        , Code <$> md_annotations <*> Code.parse
                        , quote
                        , horizontal_line
                        , Survey <$> md_annotations <*> Survey.parse
                        , Quiz <$> md_annotations <*> Quiz.parse <*> solution
                        , ordered_list
                        , unordered_list
                        , Paragraph <$> md_annotations <*> paragraph
                        ]
            in
            identation *> macro *> b <* maybe (whitespace *> Effect.hidden_comment)


to_comment : ( Annotation, ( ID, ID ) ) -> Parser PState Markdown
to_comment ( attr, ( id1, id2 ) ) =
    (case attr of
        Just a ->
            modifyState
                (\s ->
                    let
                        e =
                            s.effect_model
                    in
                    { s | effect_model = { e | comments = set_annotation id1 id2 e.comments attr } }
                )

        Nothing ->
            succeed ()
    )
        $> Comment ( id1, id2 )



--identation_append : String -> Parser PState ()
--to_comment : Annotation -> ( Int, Int ) -> Parser PState Markdown
--to_comment attr ( id1, id2 ) =
--    modifyState
--        (\s ->
--            { s | comment_map = set_annotation id1 id2 s.comment_map attr }
--        )
--        >>= (\x -> Comment ( id1, id2 ))


svgbob : Parser PState Markdown
svgbob =
    (\attr txt -> ASCII attr (txt |> String.concat |> SvgBob.init))
        <$> md_annotations
        <*> (regex "```[`]+\\n"
                *> manyTill
                    (maybe identation
                        *> regex "(?:.(?!````))*\\n"
                    )
                    (identation *> regex "```[`]+")
            )


solution : Parser PState (Maybe ( List Markdown, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    maybe
        (rslt
            <$> (identation
                    *> regex "[\\t ]*\\*{3,}[\\t ]*[\\n]+"
                    *> withState (\s -> succeed s.effect_model.effects)
                )
            <*> manyTill (blocks <* newlines) (identation *> regex "[ \\t]*\\*{3,}[\\t ]*")
            <*> withState (\s -> succeed s.effect_model.effects)
        )


ident_blocks : Parser PState MarkdownS
ident_blocks =
    many1 (blocks <* regex "\\n?") <* identation_pop


unordered_list : Parser PState Markdown
unordered_list =
    BulletList
        <$> md_annotations
        <*> many1
                (regex "[*+-] "
                    *> (identation_append "  " *> many1 (blocks <* regex "\\n?") <* identation_pop)
                )


ordered_list : Parser PState Markdown
ordered_list =
    OrderedList
        <$> md_annotations
        <*> many1
                (regex "\\d+\\. "
                    *> (identation_append "   " *> many1 (blocks <* regex "\\n?") <* identation_pop)
                )


horizontal_line : Parser PState Markdown
horizontal_line =
    HLine <$> md_annotations <* regex "-{3,}"


paragraph : Parser PState Inlines
paragraph =
    ident_skip *> ((List.concat >> combine) <$> many1 (identation *> line <* newline))


table_row : Parser PState MultInlines
table_row =
    identation *> manyTill (string "|" *> line) (regex "\\|[ \\t]*\\n")


simple_table : Parser PState Markdown
simple_table =
    ident_skip
        *> ((\a b -> Table a [] [] b)
                <$> md_annotations
                <*> many1 table_row
           )


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
    ident_skip
        *> (Table
                <$> md_annotations
                <*> table_row
                <*> format
                <*> many table_row
           )


quote : Parser PState Markdown
quote =
    Quote
        <$> md_annotations
        <*> (string "> "
                *> (identation_append ">( )?"
                        *> many1 (blocks <* maybe identation <* regex "\\n?")
                        <* identation_pop
                   )
            )


md_annotations : Parser PState Annotation
md_annotations =
    maybe
        (spaces
            *> macro
            *> (Dict.fromList <$> comment attribute)
            <* maybe (regex "[ \\t]*\\n" <* identation)
        )
