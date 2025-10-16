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
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (eScript, parse_inlines)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Matrix.Parser as Matrix
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types
    exposing
        ( Options
        , Quiz
        , Type(..)
        , initState
        )
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent
import Lia.Parser.Input as Input
import Lia.Section exposing (SubSection)
import Lia.Utils as Utils
import PseudoRandom


parse : Parameters -> Parser Context (Quiz x)
parse attr =
    [ map Matrix_Type Matrix.parse
    , map Vector_Type Vector.parse
    , onsuccess Generic_Type generic
    , map Block_Type (Block.parse parse_inlines)
    ]
        |> choice
        |> andThen adds
        |> andThen (modify_State Nothing attr)


gapText scriptID attr block =
    Input.pop
        |> map (\q -> { q | elements = [ block ] })
        |> map Multi_Type
        |> andThen adds
        |> andThen (modify_State scriptID attr)


randomize :
    Type x
    -> Int
    -> Maybe (List Int)
randomize typeOf seed =
    case typeOf of
        Vector_Type vec ->
            Just
                (PseudoRandom.integerSequence
                    (List.length vec.options)
                    seed
                )

        Matrix_Type vec ->
            Just
                (PseudoRandom.integerSequence
                    (List.length vec.options)
                    seed
                )

        Block_Type vec ->
            Just
                (PseudoRandom.integerSequence
                    (List.length vec.options)
                    seed
                )

        Multi_Type vec ->
            Just
                (PseudoRandom.integerSequence
                    (vec.options
                        |> Array.map List.length
                        |> Array.foldl (+) 0
                    )
                    seed
                )

        _ ->
            Nothing


adds : Type x -> Parser Context (Quiz x)
adds type_ =
    map (Quiz type_) get_counter
        |> andMap hints


get_counter : Parser Context Int
get_counter =
    withState (.quiz_vector >> Array.length >> succeed)


generic : Parser Context ()
generic =
    maybe Indent.check
        |> ignore spaces
        |> ignore (regex "(?:- )?\\[\\[!\\]\\]")
        |> ignore newline
        |> skip


hints : Parser Context (List Inlines)
hints =
    string "[?]"
        |> Vector.group
        |> map Tuple.second
        |> optional []


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
                            if scriptID /= Nothing then
                                scriptID

                            else
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


setScriptToHidden : Effect.Model SubSection -> Int -> Effect.Model SubSection
setScriptToHidden effect_model scriptID =
    case Array.get scriptID effect_model.javascript of
        Just js ->
            let
                input =
                    js.input
            in
            { effect_model
                | javascript =
                    effect_model.javascript
                        |> Array.set scriptID
                            { js
                                | block = True
                                , input = { input | type_ = Just Input.Hidden_ }
                            }
            }

        Nothing ->
            effect_model


getOptions : Context -> Type x -> Int -> Parameters -> Options
getOptions state quiz seed attr =
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
    , text_solved = attr |> Attributes.get "data-text-solved" |> Maybe.map (parse_inlines state)
    , text_failed = attr |> Attributes.get "data-text-failed" |> Maybe.map (parse_inlines state)
    , text_resolved = attr |> Attributes.get "data-text-resolved" |> Maybe.map (parse_inlines state)
    }


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
                    |> map Tuple.second
                    |> ignore newline
                )
            )
