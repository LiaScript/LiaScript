module Lia.Markdown.Quiz.Vector.Parser exposing
    ( blockGroup
    , checkButton
    , either
    , group
    , groupBy
    , parse
    , radioButton
    )

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , keep
        , lookAhead
        , many
        , many1
        , map
        , maybe
        , onsuccess
        , or
        , regex
        , sepBy1
        , string
        , succeed
        , withColumn
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


{-| Identify Quiz-Vectors that can either be `SingleChoice` or `MultipleChoice`.
Both types of quizzes are identified by starting **brackets**, that either
contain a `radioButton` or `checkButton` notation:

    """ -- SingleChoice
    [( )] some Markdown text
    [(X)] this is **checked** radio-button
    [(x)] this one is also checked
    """

    """ -- MultipleChoice
    [[ ]] some Markdown text
    [[X]] this is a **checked** check-box
    [[x]] this one is also checked
    """"

Each option's content is no longer limited to a single line of inline text, it may
contain full Markdown-block content (multiple paragraphs, code blocks, nested lists,
...), indented by 4 spaces relative to the option's marker - exactly like Task-list
items.

-}
parse : Parser Context Markdown.Block -> Parser Context (Quiz Markdown.Block)
parse blocks =
    or
        (radioButton
            |> blockGroup blocks
            |> map (toQuiz SingleChoice)
        )
        (checkButton
            |> blockGroup blocks
            |> map (toQuiz MultipleChoice)
        )


{-| This is the block-based counterpart of `group`: instead of a single `Inlines`
line, each entry's content is zero-or-more full Markdown `Block`s, indented by 4
spaces relative to the entry's marker. The provided `button`-parser is used to parse
the part within the starting brackets, exactly as in `group` (i.e. it can just as
well be a fixed literal like `string "[?]"`, as used by `Quiz.Parser.hints`).

A leading blank line before the first entry is tolerated: unlike `Vector.parse`
itself (reached through `Lia.Markdown.Parser.blocks`'s own `whitespace`-eating
dispatch, which already strips any such blank line before this parser even
starts), `Quiz.Parser.hints` is called directly, right after a quiz's own type
has been parsed, with no such step in between - so a hint block separated from
the preceding option list by a blank line needs `blockGroup` to skip it itself.
-}
blockGroup : Parser Context Markdown.Block -> Parser Context a -> Parser Context ( List a, List Markdown.Blocks )
blockGroup blocks button =
    (many newlineWithIndentation |> keep (item blocks button))
        |> sepBy1 separator
        |> map List.unzip


{-| **@private:** Parse a single entry: its marker (optional `-`/`+`/`*` prefix,
`button`-content within brackets), followed by its (possibly multi-block) content,
indented relative to the marker.

The required continuation indent is measured *dynamically*, relative to how far
this particular entry's own marker is indented (its own leading whitespace,
captured below before pushing), rather than a fixed absolute amount - this is
what lets a group of sibling entries that are all uniformly offset under a
preceding paragraph (to visually nest them under a question, with no genuine
nesting intended) stay flat siblings of each other, while content indented
*further than that shared baseline* still nests as a sub-entry - exactly like
CommonMark's own list-item content-indentation rule.
-}
item : Parser Context Markdown.Block -> Parser Context a -> Parser Context ( a, Markdown.Blocks )
item blocks button =
    regex "[ \t]*"
        |> keep
            (withColumn
                (\col ->
                    Indent.push (String.repeat (col + 4) " ")
                        |> keep
                            (marker button
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


{-| **@private:** Parse the `[...]`/`- [...]` marker of a single entry, returning the
`button`-parser's result.
-}
marker : Parser Context a -> Parser Context a
marker button =
    regex "(?:(\\-|\\+|\\*)[ \t]?)?\\["
        |> keep button
        |> ignore (string "]")
        |> ignore spaces


{-| **@private:** Separates consecutive entries, re-checking the indentation of the
surrounding context before the next entry's marker.
-}
separator : Parser Context (List ())
separator =
    many newlineWithIndentation
        |> ignore Indent.check


newlineWithIndentation : Parser Context ()
newlineWithIndentation =
    Indent.maybeCheck
        |> ignore newline


{-| Parse an ASCII like radio-button "(X|x)" | "[ ]". The result is either
`True` or `False`, if the button is checked or not.

    parse checkButton "(X)" == Ok True

    parse checkButton "(x)" == Ok True

    parse checkButton "( )" == Ok False

-}
radioButton : Parser Context Bool
radioButton =
    either "\\([xX]\\)" "( )"


{-| Parse an ASCII like check-button "[X|x]" | "[ ]". The result is either `True` or `False`, if the button is checked or not.

    parse checkButton "[X]" == Ok True

    parse checkButton "[x]" == Ok True

    parse checkButton "[ ]" == Ok False

-}
checkButton : Parser Context Bool
checkButton =
    either "\\[[xX]\\]" "[ ]"


{-| This parser can be used for some kind of enumerations that start with a
certain pattern (i.e. `[X]` or `[ ]`), which is then followed by a `Inlines`:

    parse
        (groupBy (string "- [")
            (string "]")
            (or
                (string "X" |> onsuccess True)
                (string " " |> onsuccess False)
            )
        )
        """- [ ] task not checked
        - [X] task checked
        """
    == Ok [(False, [...]), (True, [...])]

-}
groupBy : Parser Context x -> Parser Context y -> Parser Context a -> Parser Context (List ( a, Inlines ))
groupBy begin end parser =
    maybe Indent.check
        |> ignore spaces
        |> ignore begin
        |> keep parser
        |> map Tuple.pair
        |> ignore end
        |> ignore spaces
        |> andMap line
        |> ignore newline
        |> many1


{-| This defines the basic Quiz-group, that are identified by starting brackets
that are followed by some Markdown inline elements. The provided
parser-parameter is used to parse the part within the starting brackets.

    parse (group checkButton)
        """[[X]] is __checked__
        [[ ]] **not checked**
        """
    == Ok [(True, [...]), (False, [...])]

-}
group : Parser Context a -> Parser Context ( List a, List Inlines )
group =
    groupBy (regex "(?:(\\-|\\+|\\*)[ \t]?)?\\[") (string "]")
        >> map List.unzip


{-| This parser requires two patterns that in either `True` or `False`. The
first true-pattern requires a regex-string, while the second false-pattern is
parsed as an normal string.

    parse (either "[xX]" " ") "x" == Ok True

    parse (either "[xX]" " ") "X" == Ok True

    parse (either "[xX]" " ") " " == Ok False

This comes handy for checked representations like `radioButton` or `checkButton`.

**Note:** The first parameter is a regex, which comes handy if you want to allow
multiple options, such as upper- and lowercase or different "strings" that will
return `True`.

-}
either : String -> String -> Parser Context Bool
either true false =
    or
        (string false |> onsuccess False)
        (regex true |> onsuccess True)


{-| Transforms a list of options `(List Bool, List Markdown.Blocks)` into a
Vector-Quiz.
-}
toQuiz : (List Bool -> State) -> ( List Bool, List Markdown.Blocks ) -> Quiz Markdown.Block
toQuiz fn ( booleans, options ) =
    fn booleans
        |> Quiz options
