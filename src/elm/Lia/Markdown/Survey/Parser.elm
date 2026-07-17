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
        |> ignore (regex "(\\-|\\+|\\*)?[\t ]*\\[")
        |> keep p
        |> ignore (regex "\\][\t ]*")


id_str : Parser s String
id_str =
    "\\S[^)\\]]*"
        |> regex
        |> andThen
            (\s ->
                if s == "X" || s == "x" then
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

The required continuation indent is measured *dynamically*, relative to how far
this particular entry's own marker is indented (its own column, captured below
before pushing), rather than a fixed absolute amount - this is what lets a
group of sibling entries that are all uniformly offset under a preceding
paragraph (to visually nest them under a question, with no genuine nesting
intended) stay flat siblings of each other, while content indented *further
than that shared baseline* still nests as a sub-entry - exactly like
CommonMark's own list-item content-indentation rule. The leading whitespace is
eaten explicitly here (rather than relying on it already having been eaten by
`Lia.Markdown.Parser.blocks`'s own `whitespace` step, which only runs for the
very first entry of the group, reached via `elements` - subsequent entries are
reached directly via `separator`/`sepBy1` and never go through that step) so
the column measurement is consistent across every entry in the group.
-}
item : Parser Context Markdown.Block -> Parser Context a -> Parser Context ( a, Markdown.Blocks )
item blocks p =
    regex "[ \t]*"
        |> keep
            (withColumn
                (\col ->
                    Indent.push (String.repeat (col - 1 + 4) " ")
                        |> keep
                            (marker p
                                |> ignore emptyMarkerLine
                                |> map Tuple.pair
                                |> andMap (sepBy1 (many newlineWithIndentation) blocks)
                            )
                        |> ignore Indent.pop
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
    string begin
        |> keep (manyTill inlines (string end))
        |> many1
        |> pattern
        |> ignore newline


questions : Parser Context (List Inlines)
questions =
    maybe Indent.check
        |> ignore (regex "\\-?[\t ]*\\[[\t ]+\\]")
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
