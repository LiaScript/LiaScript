module Lia.Markdown.Parser exposing (run)

import Array
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
        , regexWithSub
        , runParser
        , sepBy
        , sepBy1
        , skip
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
import Lia.Parser.Helper exposing (c_frame, newline, newlines, peek, spaces, startsWith, trimSpaces)
import Lia.Parser.Indentation as Indent
import Lia.Parser.Input as Input
import Lia.Parser.Preprocessor exposing (title_tag)
import Regex
import SvgBob


{-| The blocks of a section, a line that is no block becomes a `Problem`.
Footnote definitions can appear between all blocks.
-}
run : Parser Context Markdown.Blocks
run =
    footnotes
        |> keep (or blocks problem)
        |> ignore newlines
        |> many
        |> ignore footnotes


{-| Footnote definitions `[^key]: ...`, they are stored in the context.
-}
footnotes : Parser Context ()
footnotes =
    (Footnote.block ident_blocks |> ignore newlines)
        |> many
        |> skip


{-| Parse a single block.

`blocks` is used recursively by many of its own sub-parsers, the `lazy` only
defers to `blockParser`, so that the parser itself is constructed only once
and not for every parsed block.

-}
blocks : Parser Context Markdown.Block
blocks =
    lazy (\() -> blockParser)


{-| A block: macros are expanded first, hidden comments `<!-- --{{1}}-- -->`
behind it are consumed.
-}
blockParser : Parser Context Markdown.Block
blockParser =
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


{-| All block types, the first one that matches wins. Most of them can have
annotations `<!-- ... -->` in front.

Tables, drawings, headers, quotes, lists, HTML, galleries and paragraphs that
contain quiz inputs `[[...]]` become gap-text quizzes (`checkQuiz`).
-}
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
        , md_annotations
            |> andThen (Input.setGroupPermission True)
            |> svgbob
            |> ignore (Input.setGroupPermission False [])
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , map Markdown.Code (Code.parse md_annotations)
        , md_annotations
            |> ignore (Input.setPermission True)
            |> map Markdown.Header
            |> andMap subHeader
            |> checkQuiz
        , horizontal_line
        , md_annotations
            |> andThen (\attr -> Survey.parse blocks attr |> map (Markdown.Survey attr))
            |> andMap (solution "survey" (.survey_vector >> Array.length))
        , md_annotations
            |> andThen (\attr -> Quiz.parse blocks attr |> map (Markdown.Quiz attr))
            |> andMap (solution "quiz" (.quiz_vector >> Array.length))
        , md_annotations
            |> map Markdown.Task
            |> andMap (Task.parse blocks)
        , md_annotations
            |> andThen (Input.setGroupPermission True)
            |> quote
            |> ignore (Input.setGroupPermission False [])
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , md_annotations
            |> andThen (Input.setGroupPermission False)
            |> map Markdown.OrderedList
            |> andMap ordered_list
            |> ignore (Input.setGroupPermission False [])
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , md_annotations
            |> andThen (Input.setGroupPermission False)
            |> map Markdown.BulletList
            |> andMap unordered_list
            |> ignore (Input.setGroupPermission False [])
            |> ignore (Input.setPermission True)
            |> checkQuiz
        , md_annotations
            |> andThen (Input.setGroupPermission False)
            |> map Markdown.HTML
            |> andMap (HTML.parse blocks)
            |> ignore (regex "[ \t]*\n")
            |> ignore (Input.setGroupPermission False [])
            |> ignore (Input.setPermission True)
            |> checkQuiz
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


{-| Turn the block into a gap-text quiz, if it contains quiz inputs. The
permission to define inputs, which the parser of the block has set, is reset.
-}
checkQuiz : Parser Context Markdown.Block -> Parser Context Markdown.Block
checkQuiz =
    map Tuple.pair
        >> andMap Input.isIdentified
        >> ignore (Input.setPermission False)
        >> andThen toQuiz


{-| A trailing script in a paragraph `[[x]] <script>...</script>` is the
script that checks the quiz.
-}
toQuiz : ( Markdown.Block, Bool ) -> Parser Context Markdown.Block
toQuiz ( md, isQuiz ) =
    if isQuiz then
        case md of
            Markdown.Paragraph attr md_ ->
                case List.reverse md_ of
                    (Script scriptID []) :: paragraph_ ->
                        paragraph_
                            |> List.reverse
                            |> Markdown.Paragraph attr
                            |> toQuiz_ (Just scriptID) attr

                    _ ->
                        toQuiz_ Nothing attr md

            Markdown.Citation attr _ ->
                toQuiz_ Nothing attr md

            Markdown.Quote attr _ _ ->
                toQuiz_ Nothing attr md

            Markdown.Table attr _ ->
                toQuiz_ Nothing attr md

            Markdown.Gallery attr _ ->
                toQuiz_ Nothing attr md

            Markdown.ASCII attr _ ->
                toQuiz_ Nothing attr md

            Markdown.HTML attr _ ->
                toQuiz_ Nothing attr md

            Markdown.OrderedList attr _ ->
                toQuiz_ Nothing attr md

            Markdown.BulletList attr _ ->
                toQuiz_ Nothing attr md

            Markdown.Header attr _ ->
                toQuiz_ Nothing attr md

            _ ->
                succeed md

    else
        succeed md


{-| Wrap the block with the collected inputs into a gap-text quiz.
-}
toQuiz_ : Maybe Int -> Parameters -> Markdown.Block -> Parser Context Markdown.Block
toQuiz_ scriptID attr =
    Quiz.gapText blocks scriptID attr
        >> map (Markdown.Quiz attr)
        >> andMap (solution "quiz" (.quiz_vector >> Array.length))


{-| A narrator comment `--{{1}}--`, its annotations are stored in the effect
model.
-}
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


{-| The caption and the body of an ASCII drawing, `len` is the number of
opening backticks. Up to 8 backticks the language `ascii` or `art` is
required, more backticks always start a drawing.
-}
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


{-| An ASCII drawing ```` ```ascii ````.
-}
svgbob : Parser Context Parameters -> Parser Context Markdown.Block
svgbob =
    map Markdown.ASCII
        >> andMap
            (c_frame
                |> andThen svgbody
                |> andThen svgbobSub
            )
        >> ignore spaces
        >> ignore newline


{-| Convert the drawing, verbatim parts `"..."` are parsed as LiaScript with the
current context.
-}
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


{-| A header within a section, either `## Title` or a setext header.
-}
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
    peek isSetext
        (line
            |> ignore (regex "[ \t]*\n")
            |> map (\i title -> ( title, i ))
            |> andMap underline
        )
        (fail "no underline")


{-| **@private:** Every paragraph is tried as a header first, which would parse
its first line twice. If the first line contains nothing that might span
multiple lines (HTML, comments, block formulas, open quiz inputs, footnotes,
effects, line breaks, or macros and macro listings), then the underline has to follow directly in
the next line.
-}
isSetext : String -> Bool
isSetext input =
    case Regex.findAtMost 1 firstLine input of
        [ { match } ] ->
            List.any (\token -> String.contains token match) [ "<", "$$", "[^", "{", "\\", "@" ]
                || openInput match
                || (input
                        |> String.dropLeft (String.length match)
                        |> (\next -> startsWith "===" next || startsWith "---" next)
                   )

        _ ->
            True


{-| **@private:** A quiz input `[[ ... ]]` or `[->[ ... ]]` is parsed until
the next `]]` (escaped brackets are excluded by `isSetext`), so it can only
span multiple lines, if there is no `]]` after its start.
-}
openInput : String -> Bool
openInput line_ =
    case List.maximum (String.indexes "[[" line_ ++ String.indexes "[->[" line_) of
        Just i ->
            not (String.contains "]]" (String.dropLeft i line_))

        Nothing ->
            False


firstLine : Regex.Regex
firstLine =
    Regex.fromString "^[^\\n]*\\n" |> Maybe.withDefault Regex.never


{-| The underline of a setext header, `===` is level 1, `---` level 2.
-}
underline : Parser Context Int
underline =
    or
        (regex "={3,}[ \t]*" |> keep (succeed 1))
        (regex "-{3,}[ \t]*" |> keep (succeed 2))


{-| A solution block `*****` below a quiz or survey, which gets visible after the
quiz has been solved or the survey has been submitted. The name and counter are
used to mark all comments within the solution with the class
`lia-tts-{name}-{id}`, so that they can be read out loud at that moment. All
scripts within the solution are only executed at that moment too.
-}
solution : String -> (Context -> Int) -> Parser Context (Maybe ( Markdown.Blocks, Int ))
solution name count =
    regex "[\t ]*\\*{3,}[\t ]*\n+"
        |> keep
            (withState
                (\s ->
                    succeed
                        ( "lia-tts-" ++ name ++ "-" ++ String.fromInt (count s - 1)
                        , s.effect_model.effects
                        , Array.length s.effect_model.javascript
                        )
                )
            )
        |> andThen
            (\( class, effects, scripts ) ->
                manyTill (blocks |> ignore newlines)
                    (regex "[\t ]*\\*{3,}[\t ]*")
                    |> andThen
                        (\blocks_ ->
                            modifyState (markSolution class scripts blocks_)
                                |> keep (withState (\s -> succeed ( blocks_, s.effect_model.effects - effects )))
                        )
            )
        |> maybe


markSolution : String -> Int -> Markdown.Blocks -> Context -> Context
markSolution class scripts blocks_ state =
    let
        e =
            state.effect_model
    in
    { state
        | effect_model =
            { e
                | javascript =
                    Array.indexedMap
                        (\id js ->
                            if id >= scripts && js.solution == Nothing then
                                { js | solution = Just class }

                            else
                                js
                        )
                        e.javascript
                , comments =
                    List.foldl
                        (\block comments ->
                            case block of
                                Markdown.Comment ( id1, id2 ) ->
                                    set_annotation id1 id2 comments [ ( "class", class ) ]

                                _ ->
                                    comments
                        )
                        e.comments
                        blocks_
            }
    }


{-| The indented blocks of a footnote definition.
-}
ident_blocks : Parser Context Markdown.Blocks
ident_blocks =
    blocks
        |> ignore (regex "\n?")
        |> many1
        |> ignore Indent.pop


{-| An unordered list `-`, `*` or `+`, the items are indented by 2 spaces.
-}
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


{-| An ordered list `1.`, the items are indented by 3 spaces, the number is
kept as the value of the item.
-}
ordered_list : Parser Context (List ( String, Markdown.Blocks ))
ordered_list =
    Indent.push "   "
        |> keep
            (regex "[ \t]*"
                |> keep (regex "-?\\d+")
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


{-| A newline, the indentation (if there is any) is consumed in front of it.
-}
newlineWithIndentation : Parser Context ()
newlineWithIndentation =
    Indent.maybeCheck
        |> ignore newline


{-| A quote `> ...`, optionally starting with an alert `> [!NOTE]`.
-}
quote : Parser Context Parameters -> Parser Context Markdown.Block
quote =
    map Markdown.Quote
        >> ignore (regex "> ?")
        >> ignore (Indent.push "> ?")
        >> ignore Indent.skip
        >> andMap
            (maybe
                (regex "[ \t]*\\[!"
                    |> keep alert
                    |> ignore (regex "[ \t]*")
                    |> ignore (many1 newlineWithIndentation)
                )
            )
        >> andMap (sepBy (many newlineWithIndentation) blocks)
        >> ignore Indent.pop


{-| The type of an alert `> [!NOTE]` (after `[!`, case insensitive) with an
optional title in the same line.
-}
alert : Parser Context ( Markdown.Alert, Maybe Inlines )
alert =
    regexWithSub { caseInsensitive = True, multiline = False } "(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\\][ \t]*"
        |> map (\( _, sub ) -> Tuple.pair (toAlert (sub |> List.head |> Maybe.andThen identity |> Maybe.withDefault "" |> String.toUpper)))
        |> andMap (maybe line)


toAlert : String -> Markdown.Alert
toAlert name =
    case name of
        "NOTE" ->
            Markdown.NOTE

        "TIP" ->
            Markdown.TIP

        "IMPORTANT" ->
            Markdown.IMPORTANT

        "WARNING" ->
            Markdown.WARNING

        _ ->
            Markdown.CAUTION


{-| A paragraph starting with `–` is a citation.
-}
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


{-| A horizontal line `---`.
-}
horizontal_line : Parser Context Markdown.Block
horizontal_line =
    md_annotations
        |> ignore (regex "-{3,}[ \t]*\n")
        |> map Markdown.HLine


{-| Lines of inlines, joined by spaces.
-}
paragraph : Parser Context Inlines
paragraph =
    checkParagraph
        |> ignore Indent.skip
        |> keep (many1 (Indent.check |> ignore (regex "[ \t]*") |> ignore allowedLine |> keep line |> ignore newline))
        |> map (List.intersperse [ Chars " " [] ] >> List.concat >> combine)


{-| A paragraph line cannot be empty and cannot start another block: a
solution `***`, a hint `[[?]]`, a list, a code block or a quote.
-}
allowedLine : Parser Context ()
allowedLine =
    notFollowedBy (regexStart "[ \t]*\n|\\*\\*\\*+\n|\\[\\[\\?\\]\\]|[+*-] |```|>|\\d+\\. ")


{-| A paragraph cannot start with a marker for Comments `--{{1}}--` or Effects
`{{1}}`. This parser checks both case, if the string pattern matches either
Comment or Effect it will fail.

_Note:_ This is mostly the case in ordered and unordered lists.

TODO: This shall be removed in the future, if a `paragraph` is directly used as
to for returning `Paragraph`, `Citation`, or `Comment`.

-}
checkParagraph : Parser Context ()
checkParagraph =
    notFollowedBy (regexStart "[ \t]*(?:--{{\\d+}}--|{{\\d+}})")


{-| Fails without consuming anything, if the remaining input matches.
-}
notFollowedBy : Regex.Regex -> Parser Context ()
notFollowedBy pattern =
    peek (Regex.contains pattern) (fail "") (succeed ())


{-| A regex that only matches at the beginning of the input.
-}
regexStart : String -> Regex.Regex
regexStart pattern =
    Regex.fromString ("^(?:" ++ pattern ++ ")") |> Maybe.withDefault Regex.never


{-| A line that could not be parsed as a block, it is shown with all errors.
-}
problem : Parser Context Markdown.Block
problem =
    Indent.skip
        |> ignore Indent.check
        |> keep lineWithProblems
        |> ignore newline
        |> map Markdown.Problem


{-| An HTML comment that is not an annotation.
-}
htmlComment : Parser Context Markdown.Block
htmlComment =
    Indent.skip
        |> ignore Indent.check
        |> ignore (comment Combine.Char.anyChar)
        |> onsuccess Markdown.HtmlComment


{-| Annotations `<!-- key="value" -->` in front of a block. This is tried by
almost every block parser, without a comment (which might also be the result
of a macro) the result is `[]` and nothing is consumed.
-}
md_annotations : Parser Context Parameters
md_annotations =
    peek
        (trimSpaces >> (\input -> startsWith "<!--" input || startsWith "@" input || startsWith "```" input))
        (spaces
            |> keep macro
            |> keep (comment md_attribute)
            |> ignore
                (regex "[\t ]*\n"
                    |> ignore Indent.check
                    |> maybe
                )
            |> optional []
        )
        (succeed [])


{-| An annotation attribute, URLs are resolved with the base of the course.
-}
md_attribute : Parser Context ( String, String )
md_attribute =
    withState (\c -> succeed ( c.defines.base, c.defines.appendix ))
        |> andThen Attributes.parse
