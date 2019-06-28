module Lia.Markdown.Parser exposing (run)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , lazy
        , many
        , many1
        , manyTill
        , map
        , maybe
        , modifyState
        , onsuccess
        , regex
        , sepEndBy
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Dict
import Lia.Markdown.Chart.Parser as Chart
import Lia.Markdown.Code.Parser as Code
import Lia.Markdown.Effect.Model exposing (set_annotation)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Inline.Parser exposing (attribute, combine, comment, line)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Parser as Quiz
import Lia.Markdown.Survey.Parser as Survey
import Lia.Markdown.Types exposing (Markdown(..), MarkdownS)
import Lia.Parser.Context exposing (Context, indentation, indentation_append, indentation_pop, indentation_skip)
import Lia.Parser.Helper exposing (c_frame, newline, newlines, spaces)
import SvgBob


run : Parser Context (List Markdown)
run =
    footnotes
        |> keep blocks
        |> ignore newlines
        |> many
        |> ignore footnotes


footnotes : Parser Context ()
footnotes =
    (Footnote.block ident_blocks |> ignore newlines)
        |> many
        |> skip


blocks : Parser Context Markdown
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
                        , svgbob
                        , md_annotations
                            |> map Code
                            |> andMap Code.parse
                        , quote
                        , horizontal_line
                        , md_annotations
                            |> map Quiz
                            |> andMap Quiz.parse
                            |> andMap solution
                        , md_annotations
                            |> map Survey
                            |> andMap Survey.parse
                        , ordered_list
                        , unordered_list
                        , md_annotations
                            |> map Paragraph
                            |> andMap paragraph
                        ]
            in
            indentation
                |> keep macro
                |> keep b
                |> ignore (maybe (whitespace |> keep Effect.hidden_comment))


to_comment : ( Annotation, ( Int, Int ) ) -> Parser Context Markdown
to_comment ( attr, ( id1, id2 ) ) =
    (case attr of
        Just _ ->
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


svgbody : Int -> Parser Context String
svgbody len =
    let
        control_frame =
            "`{"
                ++ String.fromInt len
                ++ (if len <= 8 then
                        "}"

                    else
                        ",}"
                   )

        ascii =
            if len <= 8 then
                regex "[\t ]*(ascii|art)[\t ]*\\n"

            else
                regex "([\t ]*(ascii|art))?[\t ]*\\n"
    in
    ascii
        |> keep
            (manyTill
                (maybe indentation
                    |> keep (regex ("(?:.(?!" ++ control_frame ++ "))*\\n"))
                )
                (indentation
                    |> keep (regex control_frame)
                )
                |> map (String.concat >> String.dropRight 1)
            )


svgbob : Parser Context Markdown
svgbob =
    md_annotations
        |> map (\attr txt -> ASCII attr (SvgBob.init txt))
        |> andMap (c_frame |> andThen svgbody)


solution : Parser Context (Maybe ( List Markdown, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    indentation
        |> ignore (regex "[\t ]*\\*{3,}[\t ]*\\n+")
        |> keep (withState (\s -> succeed s.effect_model.effects))
        |> map rslt
        |> andMap (manyTill (blocks |> ignore newlines) (indentation |> ignore (regex "[\t ]*\\*{3,}[\t ]*")))
        |> andMap (withState (\s -> succeed s.effect_model.effects))
        |> maybe


ident_blocks : Parser Context MarkdownS
ident_blocks =
    blocks
        |> ignore (regex "\\n?")
        |> many1
        |> ignore indentation_pop


unordered_list : Parser Context Markdown
unordered_list =
    map BulletList md_annotations
        |> andMap
            (regex "[*+-] "
                |> ignore (indentation_append "  ")
                |> keep
                    (blocks
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore indentation_pop
                |> many1
            )


ordered_list : Parser Context Markdown
ordered_list =
    map OrderedList md_annotations
        |> andMap
            (regex "\\d+\\. "
                |> ignore (indentation_append "   ")
                |> keep
                    (blocks
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore indentation_pop
                |> many1
            )


horizontal_line : Parser Context Markdown
horizontal_line =
    md_annotations
        |> ignore (regex "-{3,}")
        |> map HLine


paragraph : Parser Context Inlines
paragraph =
    indentation_skip
        |> keep (many1 (indentation |> keep line |> ignore newline))
        |> map (List.concat >> combine)


table_row : Parser Context MultInlines
table_row =
    indentation
        |> keep
            (manyTill
                (string "|" |> keep line)
                (regex "\\|[\t ]*\\n")
            )


simple_table : Parser Context Markdown
simple_table =
    indentation_skip
        |> keep md_annotations
        |> map (\a b -> Table a [] [] b)
        |> andMap (many1 table_row)


formated_table : Parser Context Markdown
formated_table =
    let
        format =
            indentation
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
    indentation_skip
        |> keep md_annotations
        |> map Table
        |> andMap table_row
        |> andMap format
        |> andMap (many table_row)


quote : Parser Context Markdown
quote =
    map Quote md_annotations
        |> andMap
            (string "> "
                |> ignore (indentation_append "> ?")
                |> keep
                    (blocks
                        |> ignore (maybe indentation)
                        |> ignore (regex "\\n?")
                        |> many1
                    )
                |> ignore indentation_pop
            )


md_annotations : Parser Context Annotation
md_annotations =
    spaces
        |> keep macro
        |> keep (comment attribute)
        |> map Dict.fromList
        |> ignore
            (regex "[\t ]*\\n"
                |> ignore indentation
                |> maybe
            )
        |> maybe
