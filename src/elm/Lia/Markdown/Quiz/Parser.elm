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
        ( Element
        , Quiz
        , State(..)
        , Type(..)
        , initState
        )
import Lia.Markdown.Quiz.Vector.Parser as Vector
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (newline, spaces)
import Lia.Parser.Indentation as Indent


parse : Parser Context Quiz
parse =
    [ map Matrix_Type Matrix.parse
    , map Vector_Type Vector.parse
    , onsuccess Generic_Type generic
    , map Block_Type Block.parse
    ]
        |> choice
        |> andThen adds
        |> andThen (modify_State Nothing)



--andThen maybeJS


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
        |> ignore (string "[[!]]")
        |> ignore newline
        |> skip


hints : Parser Context (List Inlines)
hints =
    string "[?]"
        |> Vector.group
        |> map Tuple.second
        |> optional []


modify_State : Maybe Int -> Quiz -> Parser Context Quiz
modify_State id q =
    let
        add_state e s =
            { s
                | quiz_vector =
                    Array.push
                        ( Element Solution.Open e 0 0 "", id )
                        s.quiz_vector
            }
    in
    q.quiz
        |> initState
        |> add_state
        |> modifyState
        |> keep (succeed q)


maybeJS : Parser Context (Maybe Int)
maybeJS =
    macro
        |> ignore (maybe Indent.check)
        |> keep
            (maybe
                (spaces
                    |> keep (eScript [ ( "input", "hidden" ) ])
                    |> map Tuple.second
                    |> ignore newline
                )
            )
