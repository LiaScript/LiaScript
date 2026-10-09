module Lia.Markdown.Survey.Parser exposing (parse)

{-| Parse the different survey types:

    [[___ ___]]                       -- Text with 2 lines

    [[ option 1 | option 2 ]]         -- Select

    [->[ option 1 | option 2 ]]       -- DragAndDrop

    [(id1)] option 1                  -- Vector (radio buttons)
    [(id2)] option 2

    [[id1]] option 1                  -- Vector (checkboxes)
    [[id2]] option 2

    [(id1)(id2)]                      -- Matrix (radio buttons)
    [ ] row 1
    [ ] row 2

    [[id1][id2]]                      -- Matrix (checkboxes)
    [ ] row 1

Every type can be followed by a `<script>`, which checks the answer, and every
line can start with a list marker (`-`, `+`, `*`).

-}

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
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (inlines, line, parse_inlines)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Block.Types as BlockTypes
import Lia.Markdown.Quiz.Parser exposing (maybeJS)
import Lia.Markdown.Survey.Types
    exposing
        ( Options
        , State(..)
        , Survey
        , Type(..)
        , analysisType
        )
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent
import PseudoRandom


{-| Parse a survey with the `attr` of its preceding HTML comment and push its
initial state to the `survey_vector`. `blocks` is the parser for the nested
Markdown of `Vector` options.

The order matters, a matrix header looks like a single vector option.

-}
parse : Parser Context Markdown.Block -> Parameters -> Parser Context (Survey Markdown.Block)
parse blocks attr =
    choice
        [ textSurvey
        , selectSurvey
        , vector blocks radioMarker |> map (toVector False)
        , vector blocks checkboxMarker |> map (toVector True)
        , radioMatrix
        , checkboxMatrix
        ]
        |> map Survey
        |> andMap (withState (.survey_vector >> Array.length >> succeed))
        |> andThen (addState attr)


{-| **private:** The parsers that do not depend on `blocks` are defined once,
since `regex` compiles its expression when the parser is created.
-}
textSurvey : Parser Context (Type body)
textSurvey =
    maybe Indent.check
        |> ignore spaces
        |> ignore (string "[")
        |> keep (many1 (regex "_{3,}[\t ]*"))
        |> ignore (string "]")
        |> pattern
        |> map (List.length >> Text)
        |> ignore newline


{-| **private:** A select or drag-and-drop quiz without a solution.
-}
selectSurvey : Parser Context (Type body)
selectSurvey =
    Block.parse parse_inlines
        |> andThen
            (\quiz ->
                case quiz.solution of
                    BlockTypes.Select _ [] ->
                        succeed (Select quiz.options)

                    BlockTypes.Drop _ _ [] ->
                        succeed (DragAndDrop quiz.options)

                    _ ->
                        fail ""
            )


radioMatrix : Parser Context (Type body)
radioMatrix =
    matrix False "(" ")"


checkboxMatrix : Parser Context (Type body)
checkboxMatrix =
    matrix True "[" "]"


radioMarker : Parser Context String
radioMarker =
    marker (parens id_str)


checkboxMarker : Parser Context String
checkboxMarker =
    marker (brackets id_str)


toVector : Bool -> List ( String, List body ) -> Type body
toVector checkbox definition =
    definition
        |> List.map Tuple.first
        |> analysisType
        |> Vector checkbox definition


{-| **private:** Wrap `p` into `[...]`, with an optional list marker in front.
-}
pattern : Parser Context a -> Parser Context a
pattern p =
    maybe Indent.check
        |> ignore (regex "[\t ]*(\\-|\\+|\\*)?[\t ]*\\[")
        |> keep p
        |> ignore (regex "\\][\t ]*")


{-| **private:** The id of an option, `X`, `x`, `!` and `?` are reserved for
quizzes.
-}
id_str : Parser s String
id_str =
    regex "\\S[^)\\]]*"
        |> andThen
            (\s ->
                if s == "X" || s == "x" || s == "!" || s == "?" then
                    fail ""

                else
                    succeed s
            )


{-| **private:** Parse the options of a `Vector`: each option's content is not
limited to a single line, it may contain Markdown blocks (paragraphs, code,
lists, ...), indented relative to the option's marker, exactly like task-list
items and quiz-vector options.
-}
vector : Parser Context Markdown.Block -> Parser Context String -> Parser Context (List ( String, Markdown.Blocks ))
vector blocks marker_ =
    item blocks marker_
        |> sepBy1 separator


{-| **private:** Parse a single option: its marker, followed by its (possibly
multi-block) content.

The continuation indent is the column right after the marker, minus the
indentation that is already on the `Indent` stack. Thus, nested content must
line up under the marker's own text, an enclosing list or blockquote is not
counted twice and leading whitespace of the whole group (that never made it
onto the stack) is not ignored. The same measurement is used by
`Quiz.Vector.Parser`, whose hints call their own `item` without the stripping
of `Lia.Markdown.Parser.blocks`.

-}
item : Parser Context Markdown.Block -> Parser Context a -> Parser Context ( a, Markdown.Blocks )
item blocks marker_ =
    spaces
        |> keep marker_
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


{-| **private:** `Indent.push` skips the indentation check for content on the
marker's own line. If that line is empty, the skip must not extend across the
following newline to the next block, regardless of its indentation. A no-op
`Indent.check` consumes the skip in that case, so the option's first block
gets a real indentation check.
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


{-| **private:** The `[(...)]` or `- [[...]]` marker of a single option.
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


{-| **private:** A matrix header with one `(id)` or `[id]` per column (`begin`
and `end`), followed by one `[ ]` row per statement.
-}
matrix : Bool -> String -> String -> Parser Context (Type body)
matrix checkbox begin end =
    spaces
        |> keep (string begin)
        |> keep (manyTill inlines (string end |> ignore spaces))
        |> many1
        |> pattern
        |> ignore newline
        |> map (\ids -> Matrix checkbox ids (List.map stringify ids))
        |> andMap rows


rows : Parser Context (List Inlines)
rows =
    maybe Indent.check
        |> ignore (regex "[\t ]*\\-?[\t ]*\\[[\t ]+\\]")
        |> keep line
        |> ignore newline
        |> many1


{-| **private:** Push the initial state of the survey to the `survey_vector`,
together with a script that directly follows the survey.
-}
addState : Parameters -> Survey body -> Parser Context (Survey body)
addState attr survey =
    maybeJS
        |> map
            (\scriptID context ->
                { context
                    | survey_vector =
                        Array.push
                            { submitted = False
                            , state = initState survey.survey
                            , errorMsg = Nothing
                            , scriptID = scriptID
                            , opt = getOptions context.seed survey.survey attr
                            }
                            context.survey_vector
                }
            )
        |> andThen modifyState
        |> keep (succeed survey)


initState : Type body -> State
initState survey =
    let
        unchecked =
            List.map (\id -> ( id, False )) >> Dict.fromList
    in
    case survey of
        Text _ ->
            Text_State ""

        Select _ ->
            Select_State False -1

        DragAndDrop _ ->
            DragAndDrop_State False False -1

        Vector checkbox options _ ->
            options
                |> List.map Tuple.first
                |> unchecked
                |> Vector_State checkbox

        Matrix checkbox _ ids questions ->
            ids
                |> unchecked
                |> Array.repeat (List.length questions)
                |> Matrix_State checkbox


getOptions : Int -> Type body -> Parameters -> Options
getOptions seed survey attr =
    let
        isSet =
            List.any (\name -> Attributes.isSet name attr)
    in
    { randomize =
        if Attributes.isSet "data-randomize" attr then
            randomize survey seed

        else
            Nothing
    , score =
        attr
            |> Attributes.get "data-score"
            |> Maybe.andThen String.toFloat
    , updates_allowed =
        isSet [ "data-updates-allowed", "data-updates", "data-update" ]
    , incompleteness_allowed =
        isSet [ "data-incompleteness-allowed", "data-incompleteness", "data-incomplete" ]
    }


{-| **private:** A random order of the options or rows (`data-randomize`).
-}
randomize : Type body -> Int -> Maybe (List Int)
randomize survey seed =
    Maybe.map (\n -> PseudoRandom.integerSequence n seed) <|
        case survey of
            Text _ ->
                Nothing

            Select options ->
                Just (List.length options)

            DragAndDrop options ->
                Just (List.length options)

            Vector _ options _ ->
                Just (List.length options)

            Matrix _ _ _ questions ->
                Just (List.length questions)
