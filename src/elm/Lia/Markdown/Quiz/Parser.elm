module Lia.Markdown.Quiz.Parser exposing
    ( gapText
    , maybeJS
    , parse
    )

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , map
        , maybe
        , modifyState
        , onsuccess
        , optional
        , regex
        , skip
        , string
        , succeed
        , withState
        )
import Helper.Array as Array
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Types exposing (Script)
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (eScript, parse_inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Matrix.Parser as Matrix
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types
    exposing
        ( Hints
        , Options
        , Quiz
        , Type(..)
        , initState
        )
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent
import Lia.Parser.Input as Input
import Lia.Section exposing (SubSection)
import Lia.Utils as Utils
import PseudoRandom


{-| Parse a quiz with the `attr` of its preceding HTML comment. `blocks` is the
parser for nested Markdown (options of choice quizzes and hints). The order
matters, a matrix header looks like a single option.
-}
parse : Parser Context Markdown.Block -> Parameters -> Parser Context (Quiz Markdown.Block)
parse blocks attr =
    [ map Matrix_Type Matrix.parse
    , map Vector_Type (Vector.parse blocks)
    , onsuccess Generic_Type generic
    , map Block_Type (Block.parse parse_inlines)
    ]
        |> choice
        |> andThen (adds blocks)
        |> andThen (modify_State Nothing attr)


{-| A paragraph with inputs (`[[...]]`) becomes a gap-text quiz. The inputs
have been collected by the inline parser (`Input.pop`), `scriptID` is a script
that directly follows the paragraph.
-}
gapText : Parser Context Markdown.Block -> Maybe Int -> Parameters -> Markdown.Block -> Parser Context (Quiz Markdown.Block)
gapText blocks scriptID attr block =
    Input.pop
        |> map (\q -> { q | elements = [ block ] })
        |> map Multi_Type
        |> andThen (adds blocks)
        |> andThen (modify_State scriptID attr)


{-| **private:** A random order of all options (`data-randomize`), a gap-text
shuffles the options of all its inputs as one sequence.
-}
randomize : Type x -> Int -> Maybe (List Int)
randomize typeOf seed =
    Maybe.map (\n -> PseudoRandom.integerSequence n seed) <|
        case typeOf of
            Vector_Type vec ->
                Just (List.length vec.options)

            Matrix_Type vec ->
                Just (List.length vec.options)

            Block_Type vec ->
                Just (List.length vec.options)

            Multi_Type vec ->
                Just (Array.foldl (List.length >> (+)) 0 vec.options)

            Generic_Type ->
                Nothing


{-| **private:** Add the `id` and the hints to the quiz type.
-}
adds : Parser Context Markdown.Block -> Type Markdown.Block -> Parser Context (Quiz Markdown.Block)
adds blocks type_ =
    map (Quiz type_) get_counter
        |> andMap (hints blocks)


{-| **private:** The `id` of the next quiz.
-}
get_counter : Parser Context Int
get_counter =
    withState (.quiz_vector >> Array.length >> succeed)


{-| **private:** A quiz without input `[[!]]`, it is solved by a script or by
the solution button.
-}
generic : Parser Context ()
generic =
    maybe Indent.check
        |> ignore spaces
        |> ignore (regex "(?:- )?\\[\\[!\\]\\]")
        |> ignore newline
        |> skip


{-| **private:** Hints are a list of `[[?]]` entries below the quiz.
-}
hints : Parser Context Markdown.Block -> Parser Context (Hints Markdown.Block)
hints blocks =
    Indent.maybeCheck
        |> keep (Vector.blockGroup blocks (string "[?]"))
        |> map Tuple.second
        |> optional []


{-| **private:** Add the initial state of the quiz to the `quiz_vector`. The
checking script is either the one following a gap-text (`scriptID`) or the one
following the quiz, which is hidden.
-}
modify_State : Maybe Int -> Parameters -> Quiz x -> Parser Context (Quiz x)
modify_State scriptID attr q =
    let
        add_state id seed s =
            { s
                | quiz_vector =
                    Array.push
                        { solved = Solution.Open
                        , state = initState q.quiz
                        , trial = 0
                        , hint = 0
                        , error_msg = ""
                        , scriptID =
                            case scriptID of
                                Just _ ->
                                    scriptID

                                Nothing ->
                                    id
                        , opt = getOptions s q.quiz seed attr
                        , partiallySolved = Array.empty
                        , deactivated = False
                        }
                        s.quiz_vector
                , effect_model =
                    scriptID
                        |> Maybe.map (setScriptToHidden s.effect_model)
                        |> Maybe.withDefault s.effect_model
            }
    in
    maybeJS
        |> map add_state
        |> andMap Context.getSeed
        |> andThen modifyState
        |> keep (succeed q)


{-| **private:** A checking script is not rendered, it only runs on checks.
-}
setScriptToHidden : Effect.Model SubSection -> Int -> Effect.Model SubSection
setScriptToHidden effect_model scriptID =
    { effect_model
        | javascript =
            Array.update scriptID hide effect_model.javascript
    }


{-| **private:** Render a script as hidden block.
-}
hide : Script SubSection -> Script SubSection
hide js =
    let
        input =
            js.input
    in
    { js | block = True, input = { input | type_ = Just Input.Hidden_ } }


{-| **private:** Read the `Options` from the `data-*` attributes.
-}
getOptions : Context -> Type x -> Int -> Parameters -> Options
getOptions state quiz seed attr =
    let
        text name =
            attr
                |> Attributes.get name
                |> Maybe.map (parse_inlines state)
    in
    { randomize =
        if Attributes.isSet "data-randomize" attr then
            randomize quiz seed

        else
            Nothing
    , maxTrials =
        attr
            |> Attributes.get "data-max-trials"
            |> Maybe.andThen String.toInt
    , score =
        attr
            |> Attributes.get "data-score"
            |> Maybe.andThen String.toFloat
    , showResolveAt =
        attr
            |> Attributes.get "data-solution-button"
            |> Maybe.map revealAt
            |> Maybe.withDefault 0
    , showHintsAt =
        attr
            |> Attributes.get "data-hint-button"
            |> Maybe.map revealAt
            |> Maybe.withDefault 0
    , showPartialSolution =
        Attributes.isSet "data-show-partial-solution" attr
            || Attributes.isSet "data-show-partials" attr
    , text_solved = text "data-text-solved"
    , text_failed = text "data-text-failed"
    , text_resolved = text "data-text-resolved"
    }


{-| **private:** The number of trials before a button appears: a number of
trials, `off` (`false`, `disable`, ...) hides it, every other value (`on`)
shows it immediately.
-}
revealAt : String -> Int
revealAt value =
    case String.toInt value of
        Just trial ->
            abs trial

        Nothing ->
            if Utils.checkFalse value then
                0

            else
                100000


{-| An optional script that follows a quiz, survey or task and checks it.
-}
maybeJS : Parser Context (Maybe Int)
maybeJS =
    macro
        |> ignore (maybe Indent.check)
        |> keep
            (maybe
                (spaces
                    |> keep
                        (eScript
                            [ ( "input", "hidden" )
                            , ( "block", "true" )
                            , ( "default", "undefined" )
                            ]
                        )
                    |> ignore spaces
                    |> map Tuple.second
                    |> ignore newline
                )
            )
