module Lia.Markdown.Parser exposing (run)

--import Lia.Code.Parser as Code

import Combine exposing (..)
import Dict
import Lia.Chart.Parser as Chart
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



--import SvgBob


run : Parser PState (List Markdown)
run =
    footnotes
        |> keep blocks
        |> ignore newlines
        |> many
        |> ignore footnotes


footnotes : Parser PState ()
footnotes =
    (Footnote.block ident_blocks |> ignore newlines)
        |> many
        |> skip


blocks : Parser PState Markdown
blocks =
    lazy <|
        \() ->
            let
                b =
                    choice
                        [ md_annotations
                            |> map Effect
                            |> andMap (Effect.markdown blocks)
                        , md_annotations
                            |> map Tuple.pair
                            |> andMap (Effect.comment paragraph)
                            |> andThen to_comment
                        , md_annotations
                            |> map Chart
                            |> andMap Chart.parse
                        , formated_table
                        , simple_table

                        --, svgbob
                        --, md_annotations
                        --    |> map Code
                        --    |> andMap Code.parse
                        , quote
                        , horizontal_line
                        , md_annotations
                            |> map Survey
                            |> andMap Survey.parse
                        , md_annotations
                            |> map Quiz
                            |> andMap Quiz.parse
                            |> andMap solution
                        , ordered_list
                        , unordered_list
                        , md_annotations
                            |> map Paragraph
                            |> andMap paragraph
                        ]
            in
            identation
                |> keep macro
                |> keep b
                |> ignore (maybe (whitespace |> keep Effect.hidden_comment))


to_comment : ( Annotation, ( Int, Int ) ) -> Parser PState Markdown
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
        |> onsuccess (Comment ( id1, id2 ))



{-
   svgbob : Parser PState Markdown
   svgbob =
       md_annotations
           |> map (\attr txt -> ASCII attr (txt |> String.concat |> SvgBob.init))
           |> ignore (regex "```[`]+\\n")
           |> andMap
               (manyTill
                   (maybe identation |> keep (regex "(?:.(?!````))*\\n"))
                   (identation |> ignore (regex "```[`]+"))
               )
-}


solution : Parser PState (Maybe ( List Markdown, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    identation
        |> ignore (regex "[\t ]*\\*{3,}[\t ]*\\n+")
        |> keep (withState (\s -> succeed s.effect_model.effects))
        |> map rslt
        |> andMap (manyTill (blocks |> ignore newlines) (identation |> ignore (regex "[\t ]*\\*{3,}[\t ]*")))
        |> andMap (withState (\s -> succeed s.effect_model.effects))
        |> maybe


ident_blocks : Parser PState MarkdownS
ident_blocks =
    blocks
        |> ignore (regex "\\n?")
        |> many1
        |> ignore identation_pop


unordered_list : Parser PState Markdown
unordered_list =
    map BulletList md_annotations
        |> andMap
            (regex "[*+-] "
                |> ignore (identation_append "  ")
                |> keep
                    (blocks
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore identation_pop
                |> many1
            )


ordered_list : Parser PState Markdown
ordered_list =
    map OrderedList md_annotations
        |> andMap
            (regex "\\d+\\. "
                |> ignore (identation_append "   ")
                |> keep
                    (blocks
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore identation_pop
                |> many1
            )


horizontal_line : Parser PState Markdown
horizontal_line =
    md_annotations
        |> ignore (regex "-{3,}")
        |> map HLine


paragraph : Parser PState Inlines
paragraph =
    ident_skip
        |> keep (many1 (identation |> keep line |> ignore newline))
        |> map (List.concat >> combine)


table_row : Parser PState MultInlines
table_row =
    identation
        |> keep
            (manyTill
                (string "|" |> keep line)
                (regex "\\|[\t ]*\\n")
            )


simple_table : Parser PState Markdown
simple_table =
    ident_skip
        |> keep md_annotations
        |> map (\a b -> Table a [] [] b)
        |> andMap (many1 table_row)


formated_table : Parser PState Markdown
formated_table =
    let
        format =
            identation
                |> ignore (string "|")
                |> keep
                    (sepEndBy (string "|")
                        (choice
                            [ regex "[\t ]*:-{3,}:[\t ]*" |> onsuccess "center"
                            , regex "[\t ]*:-{3,}[\t ]*" |> onsuccess "left"
                            , regex "[\t ]*-{3,}:[\t ]*" |> onsuccess "right"
                            , regex "[\t ]*-{3,}[\t ]*" |> onsuccess "left"
                            ]
                        )
                    )
                |> ignore (regex "[\t ]*\\n")
    in
    ident_skip
        |> keep md_annotations
        |> map Table
        |> andMap table_row
        |> andMap format
        |> andMap (many table_row)


quote : Parser PState Markdown
quote =
    map Quote md_annotations
        |> andMap
            (string "> "
                |> ignore (identation_append "> ?")
                |> keep
                    (blocks
                        |> ignore (maybe identation)
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore identation_pop
            )


md_annotations : Parser PState Annotation
md_annotations =
    spaces
        |> keep macro
        |> keep (comment attribute)
        |> map Dict.fromList
        |> ignore
            (regex "[\t ]*\\n"
                |> ignore identation
                |> maybe
            )
        |> maybe
