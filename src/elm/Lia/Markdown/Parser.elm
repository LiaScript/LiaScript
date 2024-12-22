module Lia.Markdown.Parser exposing (run)

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , fail
        , ignore
        , keep
        , lazy
        , lookAhead
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
        , regexWith
        , runParser
        , sepBy
        , sepBy1
        , skip
        , string
        , succeed
        , whitespace
        , withState
        )
import Combine.Char
import Lia.Markdown.Chart.Parser as Chart
import Lia.Markdown.Code.Parser as Code
import Lia.Markdown.Effect.Model exposing (set_annotation)
import Lia.Markdown.Effect.Parser as Effect
import Lia.Markdown.Footnote.Parser as Footnote
import Lia.Markdown.Gallery.Parser as Gallery
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.HTML.Parser as HTML
import Lia.Markdown.Inline.Parser exposing (comment, line, lineWithProblems)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, combine)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Parser as Quiz
import Lia.Markdown.Survey.Parser as Survey
import Lia.Markdown.Table.Parser as Table
import Lia.Markdown.Task.Parser as Task
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (c_frame, newline, newlines, spaces)
import Lia.Parser.Indentation as Indent
import Lia.Parser.Input as Input
import Lia.Parser.Preprocessor exposing (title_tag)
import SvgBob


run : Parser Context Markdown.Blocks
run =
    footnotes
        |> keep (or blocks problem)
        |> ignore newlines
        |> many
        |> ignore footnotes


footnotes : Parser Context ()
footnotes =
    (Footnote.block ident_blocks |> ignore newlines)
        |> many
        |> skip


blocks : Parser Context Markdown.Block
blocks =
    lazy <|
        \() ->
            Context.checkAbort
                |> ignore Indent.check
                |> keep macro
                |> ignore whitespace
                |> keep elements
                |> ignore
                    (whitespace
                        |> keep Effect.hidden_comment
                        |> many
                    )


elements : Parser Context Markdown.Block
elements =
    choice
        [ md_annotations
            |> map Markdown.Effect
            |> andMap (Effect.markdown blocks)
        , md_annotations
            |> map Tuple.pair
            |> andMap (Effect.comment paragraph)
            |> andThen to_comment
        , md_annotations
            |> map Markdown.Chart
            |> andMap Chart.parse
        , md_annotations
            |> map (\attr tab -> Table.classify attr tab >> Markdown.Table attr)
            |> ignore (Input.setPermission True)
            |> andMap Table.parse
            |> andMap
                (withState
                    (\state ->
                        succeed
                            ( state.effect_model.javascript
                            , if Input.isInput state.input then
                                Just state.input.blocks

                              else
                                Nothing
                            )
                    )
                )
            |> checkQuiz
        , Input.setGroupPermission True
            |> keep svgbob
            |> ignore (Input.setGroupPermission False)
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , map Markdown.Code (Code.parse md_annotations)
        , md_annotations
            |> map Markdown.Header
            |> andMap subHeader
        , horizontal_line
        , md_annotations
            |> map Markdown.Survey
            |> andMap Survey.parse
        , md_annotations
            |> andThen (\attr -> Quiz.parse attr |> map (Markdown.Quiz attr))
            |> andMap solution
        , md_annotations
            |> map Markdown.Task
            |> andMap Task.parse
        , Input.setGroupPermission True
            |> keep quote
            |> ignore (Input.setGroupPermission False)
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , md_annotations
            |> map Markdown.OrderedList
            |> andMap ordered_list
        , md_annotations
            |> map Markdown.BulletList
            |> andMap unordered_list
        , md_annotations
            |> map Markdown.HTML
            --|> ignore (Input.setGroupPermission True)
            |> andMap (HTML.parse blocks)
            |> ignore (regex "[ \t]*\n")

        --|> ignore (Input.setGroupPermission False)
        --|> ignore (Input.setPermission True)
        --|> checkQuiz
        , md_annotations
            |> ignore (Input.setPermission True)
            |> map Markdown.Gallery
            |> andMap Gallery.parse
            |> checkQuiz
        , md_annotations
            |> map checkForCitation
            |> ignore (Input.setPermission True)
            |> andMap paragraph
            |> checkQuiz
        , htmlComment
        ]


checkQuiz : Parser Context Markdown.Block -> Parser Context Markdown.Block
checkQuiz =
    map Tuple.pair
        >> andMap Input.isIdentified
        >> ignore (Input.setPermission False)
        >> andThen toQuiz


toQuiz : ( Markdown.Block, Bool ) -> Parser Context Markdown.Block
toQuiz ( md, isQuiz ) =
    if isQuiz then
        case md of
            Markdown.Paragraph attr _ ->
                toQuiz_ attr md

            Markdown.Citation attr _ ->
                toQuiz_ attr md

            Markdown.Quote attr _ ->
                toQuiz_ attr md

            Markdown.Table attr _ ->
                toQuiz_ attr md

            Markdown.Gallery attr _ ->
                toQuiz_ attr md

            Markdown.ASCII attr _ ->
                toQuiz_ attr md

            --Markdown.HTML attr _ ->
            --    toQuiz_ attr md
            _ ->
                succeed md

    else
        succeed md


toQuiz_ attr =
    Quiz.gapText attr
        >> map (Markdown.Quiz attr)
        >> andMap solution


to_comment : ( Parameters, ( Int, Int ) ) -> Parser Context Markdown.Block
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
        |> onsuccess (Markdown.Comment ( id1, id2 ))


svgbody : Int -> Parser Context ( Maybe Inlines, String )
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
            regexWith { caseInsensitive = True, multiline = False } <|
                if len <= 8 then
                    "[\t ]*(ascii|art)[\t ]*"

                else
                    "([\t ]*(ascii|art))?[\t ]*"
    in
    ascii
        |> keep (maybe line)
        |> map Tuple.pair
        |> ignore newline
        |> andMap
            (manyTill
                (maybe Indent.check
                    |> keep (regex ("(?:.(?!" ++ control_frame ++ "))*\n"))
                )
                (Indent.check
                    |> keep (regex control_frame)
                )
                |> map (String.concat >> String.dropRight 1)
            )


svgbob : Parser Context Markdown.Block
svgbob =
    md_annotations
        |> map Markdown.ASCII
        |> andMap
            (c_frame
                |> andThen svgbody
                |> andThen svgbobSub
            )
        |> ignore spaces
        |> ignore newline


svgbobSub : ( Maybe Inlines, String ) -> Parser Context ( Maybe Inlines, SvgBob.Configuration Markdown.Blocks )
svgbobSub ( caption, str ) =
    let
        svg =
            SvgBob.getElements
                { fontSize = 14.0
                , lineWidth = 1.0
                , textWidth = 8.0
                , textHeight = 16.0
                , arcRadius = 4.0
                , color =
                    { stroke = "#222"
                    , text = "black"
                    , background = "white"
                    }
                , verbatim =
                    { string = "\""
                    , multiline = True
                    , height = Just "100%"
                    , width = Nothing
                    }
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
                        ( caption
                        , { svg = svg.svg
                          , foreign = foreign
                          , settings = svg.settings
                          , columns = svg.columns
                          , rows = svg.rows
                          }
                        )
                    )
    in
    withState fn


subHeader : Parser Context ( Int, Inlines )
subHeader =
    or subHeaderType1 subHeaderType2
        |> ignore (regex "[ \t]*\n?")


{-| This deals with all headers that are left within a slight, which occur
within HTML blocks or other nested elements:

    <details markdown="1">
        <summary>Solution</summary>

        ### A Header
        > 1. Yes, add explanation here
        >
        > **TODO**: add image

    </details>

-}
subHeaderType1 : Parser Context ( Int, Inlines )
subHeaderType1 =
    title_tag
        |> map Tuple.pair
        |> andMap line


{-| This is a special type of level 1 or level 2 headers in Markdown:

    Level one header
    ================

    Level two header
    ----------------

-}
subHeaderType2 : Parser Context ( Int, Inlines )
subHeaderType2 =
    line
        |> ignore (regex "[ \t]*\n")
        |> map (\i title -> ( title, i ))
        |> andMap underline


underline : Parser Context Int
underline =
    or
        (regex "={3,}[ \t]*" |> keep (succeed 1))
        (regex "-{3,}[ \t]*" |> keep (succeed 2))


solution : Parser Context (Maybe ( Markdown.Blocks, Int ))
solution =
    let
        rslt e1 blocks_ e2 =
            ( blocks_, e2 - e1 )
    in
    regex "[\t ]*\\*{3,}[\t ]*\n+"
        |> keep (withState (\s -> succeed s.effect_model.effects))
        |> map rslt
        |> andMap
            (manyTill (blocks |> ignore newlines)
                (regex "[\t ]*\\*{3,}[\t ]*")
            )
        |> andMap (withState (\s -> succeed s.effect_model.effects))
        |> maybe


ident_blocks : Parser Context Markdown.Blocks
ident_blocks =
    blocks
        |> ignore (regex "\n?")
        |> many1
        |> ignore Indent.pop


unordered_list : Parser Context (List Markdown.Blocks)
unordered_list =
    Indent.push "  "
        |> keep
            (regex "[ \t]*[*+-][ \t]+"
                |> keep (sepBy (many newlineWithIndentation) blocks)
            )
        |> ignore Indent.pop
        |> sepBy1
            (newlineWithIndentation
                |> many
                |> ignore Indent.check
            )


ordered_list : Parser Context (List ( String, Markdown.Blocks ))
ordered_list =
    Indent.push "   "
        |> keep
            (regex "[ \t]*-?\\d+"
                |> map Tuple.pair
                |> ignore (regex "\\.[ \t]*")
                |> andMap (sepBy (many newlineWithIndentation) blocks)
            )
        |> ignore Indent.pop
        |> sepBy1
            (newlineWithIndentation
                |> many
                |> ignore Indent.check
            )


newlineWithIndentation : Parser Context ()
newlineWithIndentation =
    Indent.maybeCheck
        |> ignore newline


quote : Parser Context Markdown.Block
quote =
    map Markdown.Quote md_annotations
        |> ignore (regex "> ?")
        |> ignore (Indent.push "> ?")
        |> ignore Indent.skip
        |> andMap (sepBy newlineWithIndentation blocks)
        |> ignore Indent.pop


checkForCitation : Parameters -> Inlines -> Markdown.Block
checkForCitation attr p =
    case p of
        (Chars chars cAttr) :: rest ->
            if String.startsWith "–" chars then
                Markdown.Citation attr (Chars (String.dropLeft 1 chars) cAttr :: rest)

            else
                Markdown.Paragraph attr p

        _ ->
            Markdown.Paragraph attr p



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


horizontal_line : Parser Context Markdown.Block
horizontal_line =
    md_annotations
        |> ignore (regex "-{3,}[ \t]*\n")
        |> map Markdown.HLine


paragraph : Parser Context Inlines
paragraph =
    checkParagraph
        |> ignore Indent.skip
        |> keep (many1 (Indent.check |> ignore allowedLine |> keep line |> ignore newline))
        |> map (List.intersperse [ Chars " " [] ] >> List.concat >> combine)


allowedLine : Parser Context ()
allowedLine =
    lookAhead
        (maybe
            (choice
                [ regex "\\*\\*\\*+\n"
                , string "[[?]]"
                ]
            )
            |> andThen
                (\e ->
                    case e of
                        Nothing ->
                            succeed ()

                        _ ->
                            fail ""
                )
        )


{-| A paragraph cannot start with a marker for Comments `--{{1}}--` or Effects
`{{1}}`. This parser checks both case, if the string pattern matches either
Comment or Effect it will fail.

_Note:_ This is mostly the case in ordered and unordered lists.

TODO: This shall be removed in the future, if a `paragraph` is directly used as
to for returning `Paragraph`, `Citation`, or `Comment`.

-}
checkParagraph : Parser Context ()
checkParagraph =
    lookAhead
        (maybe
            (or (regex "[ \t]*--{{\\d+}}--")
                (regex "[ \t]*{{\\d+}}")
            )
            |> andThen
                (\e ->
                    if e == Nothing then
                        succeed ()

                    else
                        fail ""
                )
        )


problem : Parser Context Markdown.Block
problem =
    Indent.skip
        |> ignore Indent.check
        |> keep lineWithProblems
        |> ignore newline
        |> map Markdown.Problem


htmlComment : Parser Context Markdown.Block
htmlComment =
    Indent.skip
        |> ignore Indent.check
        |> ignore (comment Combine.Char.anyChar)
        |> onsuccess Markdown.HtmlComment


md_annotations : Parser Context Parameters
md_annotations =
    let
        attr =
            withState (\c -> succeed ( c.defines.base, c.defines.appendix ))
                |> andThen Attributes.parse
    in
    spaces
        |> keep macro
        |> keep (comment attr)
        |> ignore
            (regex "[\t ]*\n"
                |> ignore Indent.check
                |> maybe
            )
        |> optional []
