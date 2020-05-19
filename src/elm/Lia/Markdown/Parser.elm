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
        , optional
        , regex
        , sepBy1
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
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.HTML.Parser as HTML
import Lia.Markdown.Inline.Parser exposing (combine, comment, line, lineWithProblems)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Parser as Quiz
import Lia.Markdown.Survey.Parser as Survey
import Lia.Markdown.Table.Parser as Table
import Lia.Markdown.Types exposing (Markdown(..), MarkdownS)
import Lia.Parser.Context exposing (Context, indentation, indentation_append, indentation_pop, indentation_skip)
import Lia.Parser.Helper exposing (c_frame, debug, newline, newlines, spaces)


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
                        , md_annotations
                            |> map Table
                            |> andMap Table.parse
                        , svgbob
                        , md_annotations
                            |> map Code
                            |> andMap Code.parse
                        , quote
                        , horizontal_line
                        , md_annotations
                            |> map Survey
                            |> andMap Survey.parse
                        , md_annotations
                            |> map Quiz
                            |> andMap Quiz.parse
                            |> andMap solution
                        , md_annotations
                            |> map OrderedList
                            |> andMap ordered_list
                        , md_annotations
                            |> map BulletList
                            |> andMap unordered_list
                        , md_annotations
                            |> map HTML
                            |> andMap (HTML.parse blocks)
                        , md_annotations
                            |> map Paragraph
                            |> andMap paragraph
                        , md_annotations
                            |> map Paragraph
                            |> andMap problem
                        ]
            in
            indentation
                |> keep macro
                |> keep b
                |> ignore (maybe (whitespace |> keep Effect.hidden_comment))


to_comment : ( Parameters, ( Int, Int ) ) -> Parser Context Markdown
to_comment ( attr, ( id1, id2 ) ) =
    (case attr of
        [] ->
            succeed ()

        _ ->
            modifyState
                (\s ->
                    let
                        e =
                            s.effect_model
                    in
                    { s | effect_model = { e | comments = set_annotation id1 id2 e.comments attr } }
                )
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
        |> map ASCII
        |> andMap (c_frame |> andThen svgbody)


solution : Parser Context (Maybe ( List Markdown, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    regex "[\t ]*\\*{3,}[\t ]*\\n+"
        |> keep (withState (\s -> succeed s.effect_model.effects))
        |> map rslt
        |> andMap
            (manyTill (blocks |> ignore newlines)
                (regex "[\t ]*\\*{3,}[\t ]*")
            )
        |> andMap (withState (\s -> succeed s.effect_model.effects))
        |> maybe


ident_blocks : Parser Context MarkdownS
ident_blocks =
    blocks
        |> ignore (regex "\\n?")
        |> many1
        |> ignore indentation_pop


unordered_list : Parser Context (List MarkdownS)
unordered_list =
    indentation_append "  "
        |> keep
            (regex "[ \\t]*[*+\\-][ \\t]+"
                |> keep (sepBy1 (regex "\\n?") blocks)
                |> many1
            )
        |> ignore indentation_pop
        |> many1
        |> map List.concat


ordered_list : Parser Context (List ( String, MarkdownS ))
ordered_list =
    indentation_append "   "
        |> keep
            (regex "-?\\d+"
                |> map Tuple.pair
                |> ignore (string ". ")
                |> andMap (sepBy1 (regex "\\n?") blocks)
                |> many1
            )
        |> ignore indentation_pop
        |> many1
        |> map List.concat


horizontal_line : Parser Context Markdown
horizontal_line =
    md_annotations
        |> ignore (regex "-{3,}")
        |> map HLine


paragraph : Parser Context Inlines
paragraph =
    indentation_skip
        |> keep (many1 (indentation |> keep line |> ignore newline))
        |> map (List.intersperse [ Chars " " [] ] >> List.concat >> combine)


problem : Parser Context Inlines
problem =
    indentation_skip
        |> ignore indentation
        |> keep lineWithProblems
        |> ignore newline


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
            )
        |> ignore indentation_pop


md_annotations : Parser Context Parameters
md_annotations =
    spaces
        |> keep macro
        |> keep (comment Attributes.parse)
        |> ignore
            (regex "[\t ]*\\n"
                |> ignore indentation
                |> maybe
            )
        |> optional []
