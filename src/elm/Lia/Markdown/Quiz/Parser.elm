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
import Lia.Markdown.Inline.Parser exposing (eScript)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Block.Parser as Block
import Lia.Markdown.Quiz.Matrix.Parser as Matrix
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Types
    exposing
        ( Quiz
        , State(..)
        , Type(..)
        , initState
        )
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent
import PseudoRandom


parse :
    { randomize : Maybe Int
    , maxTrials : Maybe Int
    , score : Maybe Float
    }
    -> Parser Context Quiz
parse options =
    [ map Matrix_Type Matrix.parse
    , map Vector_Type Vector.parse
    , onsuccess Generic_Type generic
    , map Block_Type Block.parse
    ]
        |> choice
        |> andThen adds
        |> andThen (modify_State options)


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


modify_State :
    { randomize : Maybe Int
    , maxTrials : Maybe Int
    , score : Maybe Float
    }
    -> Quiz
    -> Parser Context Quiz
modify_State options q =
    let
        add_state id s =
            { s
                | quiz_vector =
                    Array.push
                        { solved = Solution.Open
                        , state = initState q.quiz
                        , trial = 0
                        , maxTrials = options.maxTrials
                        , hint = 0
                        , error_msg = ""
                        , scriptID = id
                        , randomize =
                            options.randomize
                                |> Maybe.andThen (randomize q.quiz)
                        , score = options.score
                        }
                        s.quiz_vector
            }
    in
    maybeJS
        |> map add_state
        |> andThen modifyState
        |> keep (succeed q)


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
