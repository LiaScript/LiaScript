module Lia.Markdown.Survey.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , brackets
        , choice
        , fail
        , ignore
        , keep
        , lookAhead
        , many
        , many1
        , manyTill
        , map
        , maybe
        , modifyState
        , parens
        , regex
        , sepBy1
        , string
        , succeed
        , withColumn
        , withState
        )
import Dict
import Lia.Markdown.Inline.Parser exposing (inlines, line, parse_inlines)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Block.Types as BlockTypes
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Survey.Types exposing (State(..), Survey, Type(..), analysisType)
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


parse : Parser Context Markdown.Block -> Parser Context (Survey Markdown.Block)
parse blocks =
    survey blocks |> andThen modify_State


survey : Parser Context Markdown.Block -> Parser Context (Survey Markdown.Block)
survey blocks =
    choice
        [ text_lines |> map Text
        , Block.parse parse_inlines |> andThen toSelect
        , vector blocks parens |> map (toVector False)
        , vector blocks brackets |> map (toVector True)
        , header "(" ")" |> map (toMatrix False) |> andMap questions
        , header "[" "]" |> map (toMatrix True) |> andMap questions
        ]
        |> map Survey
        |> andMap (withState (.survey_vector >> Array.length >> succeed))


toVector : Bool -> List ( String, List body ) -> Type body
toVector bool definition =
    definition
        |> List.map Tuple.first
        |> analysisType
        |> Vector bool definition


toMatrix : Bool -> List Inlines -> (List Inlines -> Type body)
toMatrix bool ids =
    ids
        |> List.map stringify
        |> Matrix bool ids


text_lines : Parser Context Int
text_lines =
    maybe Indent.check
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (regex "_{3,}[\t ]*"))
        |> ignore (string "]")
        |> pattern
        |> map List.length
        |> ignore newline


toSelect : BlockTypes.Quiz Inlines -> Parser Context (Type body)
toSelect quiz =
    case quiz.solution of
        BlockTypes.Select _ [] ->
            succeed <| Select quiz.options

        BlockTypes.Drop _ _ [] ->
            succeed <| DragAndDrop quiz.options

        _ ->
            fail ""


pattern : Parser Context a -> Parser Context a
pattern p =
    maybe Indent.check
        |> ignore (regex "[\t ]*(\\-|\\+|\\*)?[\t ]*\\[")
        |> keep p
        |> ignore (regex "\\][\t ]*")


id_str : Parser s String
id_str =
    "\\S[^)\\]]*"
        |> regex
        |> andThen
            (\s ->
                if s == "X" || s == "x" || s == "!" || s == "?" then
                    fail ""

                else
                    succeed s
            )


{-| Parse a Survey-Vector's options: each option's content is no longer limited
to a single line of inline text, it may contain full Markdown-block content
(multiple paragraphs, code blocks, nested lists, ...), indented by 4 spaces
relative to the option's marker - exactly like Task-list items and
Quiz-Vector options.
-}
vector : Parser Context Markdown.Block -> (Parser Context String -> Parser Context a) -> Parser Context (List ( a, Markdown.Blocks ))
vector blocks p =
    item blocks (p id_str)
        |> sepBy1 separator


{-| **@private:** Parse a single entry: its marker (optional `-`/`+`/`*` prefix,
`p`-content within brackets), followed by its (possibly multi-block) content,
indented relative to the marker.

The required continuation indent is measured _dynamically_, as the exact
physical column right after this entry's marker, minus however much of that
is already accounted for by the currently-active `Indent` stack (e.g. an
enclosing list's/blockquote's own pushed level) - so nested content must line
up directly under the marker's own text, exactly like a Task-list item, while
never double-counting an ancestor's contribution and never under-counting a
shared leading whitespace this entry's group happens to carry (e.g. when the
whole group is visually offset under a preceding question) that never made it
onto the stack anywhere. The two failure modes this specifically guards
against: (1) an absolute column on its own double-counts already-active
indentation (an option one level inside a list would require the list's own
width twice); (2) a *marker-width-only* measurement (ignoring the current
absolute column entirely) works for constructs reached through
`Lia.Markdown.Parser.blocks`'s own dispatch, which already strips ambient
indentation before this parser ever runs - but breaks for the (structurally
identical) `Quiz.Parser.hints` case over in `Vector.Parser`, which calls its
own `item` directly, with no such stripping step in between, silently baking
a still-unconsumed ancestor prefix into what should have been just the
marker's own width.

-}
item : Parser Context Markdown.Block -> Parser Context a -> Parser Context ( a, Markdown.Blocks )
item blocks p =
    regex "[ \t]*"
        |> keep
            (marker p
                |> andThen
                    (\result ->
                        withColumn
                            (\after ->
                                withState
                                    (\state ->
                                        let
                                            active =
                                                state.indentation
                                                    |> String.concat
                                                    |> String.length
                                        in
                                        Indent.push (String.repeat (after - active) " ")
                                            |> ignore emptyMarkerLine
                                            |> keep (sepBy1 (many newlineWithIndentation) blocks)
                                            |> map (Tuple.pair result)
                                            |> ignore Indent.pop
                                    )
                            )
                    )
            )


{-| **@private:** If the marker's own line has no further content (nothing but
optional trailing whitespace before the newline), the "skip the indentation
check for same-line content" privilege armed by `Indent.push` must not
silently extend across a following blank line to whatever block happens to
come next, regardless of its actual indentation - force a real indentation
check for the option's first content block in that case, by consuming the
still-armed skip via a no-op `Indent.check` right here, while we still know
we're at the end of the marker's line.
-}
emptyMarkerLine : Parser Context ()
emptyMarkerLine =
    lookAhead (maybe (regex "[ \t]*\n"))
        |> andThen
            (\match ->
                case match of
                    Just _ ->
                        Indent.check

                    Nothing ->
                        succeed ()
            )


{-| **@private:** Parse the `[...]`/`- [...]` marker of a single entry.
-}
marker : Parser Context a -> Parser Context a
marker p =
    regex "(\\-|\\+|\\*)?[\t ]*\\["
        |> keep p
        |> ignore (regex "\\][\t ]*")


separator : Parser Context (List ())
separator =
    many newlineWithIndentation
        |> ignore Indent.check


newlineWithIndentation : Parser Context ()
newlineWithIndentation =
    Indent.maybeCheck
        |> ignore newline


header : String -> String -> Parser Context (List Inlines)
header begin end =
    spaces
        |> keep (string begin)
        |> keep (manyTill inlines (string end |> ignore spaces))
        |> many1
        |> pattern
        |> ignore newline


questions : Parser Context (List Inlines)
questions =
    maybe Indent.check
        |> ignore (regex "[\t ]*\\-?[\t ]*\\[[\t ]+\\]")
        |> keep line
        |> ignore newline
        |> many1


modify_State : Survey body -> Parser Context (Survey body)
modify_State survey_ =
    let
        state =
            let
                extractor fn v =
                    v
                        |> List.map fn
                        |> Dict.fromList
            in
            case survey_.survey of
                Text _ ->
                    Text_State ""

                Select _ ->
                    Select_State False -1

                DragAndDrop _ ->
                    DragAndDrop_State False False -1

                Vector bool vars _ ->
                    vars
                        |> extractor (\( v, _ ) -> ( v, False ))
                        |> Vector_State bool

                Matrix bool _ vars qs ->
                    vars
                        |> extractor (\v -> ( v, False ))
                        |> Array.repeat (List.length qs)
                        |> Matrix_State bool
    in
    succeed survey_
        |> ignore
            (maybeJS
                |> map (add_state state)
                |> andThen modifyState
            )


add_state : State -> Maybe Int -> Context -> Context
add_state state id c =
    { c
        | survey_vector =
            Array.push
                { submitted = False
                , state = state
                , errorMsg = Nothing
                , scriptID = id
                }
                c.survey_vector
    }
