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
        , or
        , putState
        , regex
        , runParser
        , sepBy
        , sepBy1
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
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
                        , md_annotations
                            |> map (\attr tab -> Table.classify attr tab >> Table attr)
                            |> andMap Table.parse
                            |> andMap (withState (.effect_model >> .javascript >> succeed))
                        , svgbob
                        , map Code (Code.parse md_annotations)
                        , md_annotations
                            |> map Header
                            |> andMap subHeader
                        , horizontal_line
                        , md_annotations
                            |> map Survey
                            |> andMap Survey.parse
                        , md_annotations
                            |> map Quiz
                            |> andMap Quiz.parse
                            |> andMap solution
                        , quote
                        , md_annotations
                            |> map OrderedList
                            |> andMap ordered_list
                        , md_annotations
                            |> map BulletList
                            |> andMap unordered_list
                        , md_annotations
                            |> map HTML
                            |> andMap (HTML.parse blocks)
                            |> ignore (regex "[ \t]*\n")
                        , md_annotations
                            |> map Paragraph
                            |> andMap paragraph
                        , md_annotations
                            |> map Paragraph
                            |> andMap problem

                        --, comments
                        --    |> onsuccess Skip
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
            "(`){"
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
        |> andMap
            (c_frame
                |> andThen svgbody
                |> andThen svgbobSub
            )


svgbobSub : String -> Parser Context (SvgBob.Configuration (List Markdown))
svgbobSub str =
    let
        svg =
            SvgBob.getElements
                { fontSize = 14.0
                , lineWidth = 1.0
                , textWidth = 8.0
                , textHeight = 16.0
                , arcRadius = 4.0
                , strokeColor = "black"
                , textColor = "black"
                , backgroundColor = "white"
                , verbatim = '"'
                , multilineVerbatim = True
                , heightVerbatim = Just "100%"
                , widthVerbatim = Nothing
                }
                str

        fn context =
            let
                ( newContext, foreign ) =
                    svg.foreign
                        |> List.foldl
                            (\( code, pos ) ( c, list ) ->
                                case runParser run c (code ++ "\n") of
                                    Ok ( state, _, md ) ->
                                        ( state, ( md, pos ) :: list )

                                    Err _ ->
                                        ( c, list )
                            )
                            ( context, [] )
            in
            putState newContext
                |> keep
                    (succeed
                        { svg = svg.svg
                        , foreign = foreign
                        , settings = svg.settings
                        , columns = svg.columns
                        , rows = svg.rows
                        }
                    )
    in
    withState fn


subHeader : Parser Context ( Inlines, Int )
subHeader =
    line
        |> ignore (regex "[ \t]*\n")
        |> map Tuple.pair
        |> andMap underline
        |> ignore (regex "[ \t]*\n")



--|> ignore (regex "[ \t]*\n")


underline : Parser Context Int
underline =
    or
        (regex "={3,}[ \t]*" |> keep (succeed 1))
        (regex "-{3,}[ \t]*" |> keep (succeed 2))


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
        |> ignore (regex "\n?")
        |> many1
        |> ignore indentation_pop


unordered_list : Parser Context (List MarkdownS)
unordered_list =
    indentation_append "  "
        |> keep
            (regex "[ \t]*[*+-][ \t]+"
                |> keep (sepBy1 (maybe newlineWithIndentation) blocks)
            )
        |> ignore indentation_pop
        |> sepBy1
            (maybe indentation
                |> ignore (maybe newline)
                |> ignore indentation
            )


ordered_list : Parser Context (List ( String, MarkdownS ))
ordered_list =
    indentation_append "   "
        |> keep
            (regex "[ \t]*-?\\d+"
                |> map Tuple.pair
                |> ignore (regex "\\.[ \t]*")
                |> andMap (sepBy1 (maybe newlineWithIndentation) blocks)
            )
        |> ignore indentation_pop
        |> sepBy1
            (maybe indentation
                |> ignore (maybe newline)
                |> ignore indentation
            )


newlineWithIndentation : Parser Context (Maybe ())
newlineWithIndentation =
    maybe indentation
        |> ignore (string "\n")


quote : Parser Context Markdown
quote =
    map Quote md_annotations
        |> ignore (regex "> ?")
        |> ignore (indentation_append "> ?")
        |> andMap (sepBy (many (indentation |> ignore (string "\n"))) blocks)
        |> ignore indentation_pop



--quote : Parser Context Markdown
--quote =
--    map Quote md_annotations
--        |> ignore (indentation_append "> ?")
--        |> andMap
--            (regex "> ?"
--                |> keep
--                    (blocks
--                        |> ignore (maybe indentation)
--                        |> ignore (regex "\\n?")
--                        |> many1
--                    )
--            )
--        |> ignore indentation_pop


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


md_annotations : Parser Context Parameters
md_annotations =
    let
        attr =
            withState (.defines >> .base >> succeed)
                |> andThen Attributes.parse
    in
    spaces
        |> keep macro
        |> keep (comment attr)
        |> ignore
            (regex "[\t ]*\\n"
                |> ignore indentation
                |> maybe
            )
        |> optional []
