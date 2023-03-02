module Lia.Markdown.Quiz.Parser exposing
    ( maybeJS
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
import Lia.Markdown.HTML.Attributes as Attributes exposing (Parameters)
import Lia.Markdown.Inline.Parser exposing (eScript)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Matrix.Parser as Matrix
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types
    exposing
        ( Options
        , Quiz
        , State(..)
        , Type(..)
        , initState
        )
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Parser.Context as Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent
import Lia.Utils as Utils
import PseudoRandom


parse : Parameters -> Parser Context Quiz
parse attr =
    [ map Matrix_Type Matrix.parse
    , map Vector_Type Vector.parse
    , onsuccess Generic_Type generic
    , map Block_Type Block.parse
    ]
        |> choice
        |> andThen adds
        |> andThen (modify_State attr)


randomize :
    Type
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

        _ ->
            Nothing


adds : Type -> Parser Context Quiz
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


modify_State : Parameters -> Quiz -> Parser Context Quiz
modify_State attr q =
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
                        , scriptID = id
                        , opt = getOptions q.quiz seed attr
                        }
                        s.quiz_vector
            }
    in
    maybeJS
        |> map add_state
        |> andMap Context.getSeed
        |> andThen modifyState
        |> keep (succeed q)


getOptions : Type -> Int -> Parameters -> Options
getOptions quiz seed attr =
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
