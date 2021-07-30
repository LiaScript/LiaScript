module Lia.Markdown.Quiz.Vector.Parser exposing
    ( checkButton
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
        , ignore
        , keep
        , many1
        , map
        , maybe
        , onsuccess
        , or
        , regex
        , string
        )
import Lia.Markdown.Inline.Parser exposing (line)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
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

-}
parse : Parser Context Quiz
parse =
    or
        (radioButton
            |> group
            |> map (toQuiz SingleChoice)
        )
        (checkButton
            |> group
            |> map (toQuiz MultipleChoice)
        )


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
    groupBy (string "[") (string "]")
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


{-| Transforms a list of options `(List Bool, List Inlines)` into a Vector-Quiz.
-}
toQuiz : (List Bool -> State) -> ( List Bool, List Inlines ) -> Quiz
toQuiz fn ( booleans, inlines ) =
    fn booleans
        |> Quiz inlines
